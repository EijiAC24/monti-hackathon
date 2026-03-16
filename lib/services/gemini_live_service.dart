import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';

void _log(String msg) {
  if (kDebugMode) debugPrint(msg);
}

/// Events emitted by the Gemini Live API session.
sealed class GeminiLiveEvent {}

class GeminiAudioChunk extends GeminiLiveEvent {
  final Uint8List pcmData;
  GeminiAudioChunk(this.pcmData);
}

class GeminiTextChunk extends GeminiLiveEvent {
  final String text;
  GeminiTextChunk(this.text);
}

class GeminiTurnComplete extends GeminiLiveEvent {}

class GeminiInterrupted extends GeminiLiveEvent {}

class GeminiSetupComplete extends GeminiLiveEvent {}

class GeminiToolCall extends GeminiLiveEvent {
  final String name;
  final Map<String, dynamic> args;
  GeminiToolCall(this.name, this.args);
}

class GeminiError extends GeminiLiveEvent {
  final String message;
  GeminiError(this.message);
}

class GeminiDisconnected extends GeminiLiveEvent {}

/// Service for real-time audio conversation via Gemini Live API.
///
/// Protocol: WebSocket with JSON messages containing base64-encoded PCM audio.
/// Input: 16kHz 16-bit PCM mono
/// Output: 24kHz 16-bit PCM mono
class GeminiLiveService {
  static const _model = 'gemini-live-2.5-flash-native-audio';

  IOWebSocketChannel? _channel;
  final _eventController = StreamController<GeminiLiveEvent>.broadcast();
  bool _isConnected = false;

  Stream<GeminiLiveEvent> get events => _eventController.stream;
  bool get isConnected => _isConnected;

  /// Connect to Gemini Live API via Vertex AI.
  Future<void> connect({
    required String accessToken,
    required String projectId,
    required String location,
    required String systemPrompt,
    String voiceName = 'Zephyr',
  }) async {
    if (_isConnected) await disconnect();

    final uri = Uri.parse(
      'wss://$location-aiplatform.googleapis.com/ws/google.cloud.aiplatform.v1beta1.LlmBidiService/BidiGenerateContent',
    );
    _log('[Monti] WS URI: $uri');

    try {
      _channel = IOWebSocketChannel.connect(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      await _channel!.ready;
      _isConnected = true;
      _log('[Monti] WebSocket connected');

      // Listen for messages
      _channel!.stream.listen(
        _handleMessage,
        onError: (Object error) {
          _log('[Monti] WS error: $error');
          _eventController.add(GeminiError(error.toString()));
          _isConnected = false;
        },
        onDone: () {
          final code = _channel?.closeCode;
          final reason = _channel?.closeReason;
          _log('[Monti] WS closed (code=$code, reason=$reason)');
          _isConnected = false;
          _eventController.add(GeminiDisconnected());
        },
      );

      // Send setup message (matches Google GenAI SDK format)
      _sendJson({
        'setup': {
          'model': 'projects/$projectId/locations/$location/publishers/google/models/$_model',
          'generationConfig': {
            'responseModalities': ['AUDIO'],
            'speechConfig': {
              'voiceConfig': {
                'prebuiltVoiceConfig': {
                  'voiceName': voiceName,
                },
              },
            },
            // Disable thinking to reduce latency
            'thinkingConfig': {
              'thinkingBudget': 0,
            },
          },
          'systemInstruction': {
            'parts': [
              {'text': systemPrompt},
            ],
          },
          'tools': [
            {
              'functionDeclarations': [
                {
                  'name': 'end_conversation',
                  'description':
                      'Call this ONLY after a full conversation has happened (at least 3 exchanges back and forth) AND the child has explicitly agreed to take action AND you have said goodbye. NEVER call this on the first turn or before the child has spoken.',
                  'parameters': {
                    'type': 'object',
                    'properties': {},
                  },
                },
              ],
            },
          ],
        },
      });
      _log('[Monti] Setup message sent');
    } catch (e) {
      _log('[Monti] Connection failed: $e');
      _isConnected = false;
      _eventController.add(GeminiError('Connection failed: $e'));
    }
  }

  /// Send audio chunk to Gemini (16kHz PCM mono, base64 encoded).
  void sendAudio(Uint8List pcmData) {
    if (!_isConnected) return;

    _sendJson({
      'realtimeInput': {
        'mediaChunks': [
          {
            'mimeType': 'audio/pcm;rate=16000',
            'data': base64Encode(pcmData),
          },
        ],
      },
    });
  }

  /// Send text message to Gemini (for testing without audio).
  void sendText(String text) {
    if (!_isConnected) return;

    _sendJson({
      'clientContent': {
        'turns': [
          {
            'role': 'user',
            'parts': [
              {'text': text},
            ],
          },
        ],
        'turnComplete': true,
      },
    });
  }

  /// Disconnect from the API.
  Future<void> disconnect() async {
    _isConnected = false;
    await _channel?.sink.close();
    _channel = null;
  }

  /// Clean up resources.
  void dispose() {
    disconnect();
    _eventController.close();
  }

  void _sendJson(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void _handleMessage(dynamic rawMessage) {
    try {
      // WebSocket may send String or Uint8List (binary frames)
      final String msgStr;
      if (rawMessage is String) {
        msgStr = rawMessage;
      } else if (rawMessage is Uint8List) {
        msgStr = utf8.decode(rawMessage);
      } else {
        _log('[Monti] Unknown message type: ${rawMessage.runtimeType}');
        return;
      }
      // Log first 500 chars of message for debugging
      final logLen = msgStr.length > 500 ? 500 : msgStr.length;
      _log('[Monti] WS recv: ${msgStr.substring(0, logLen)}');
      final data = jsonDecode(msgStr) as Map<String, dynamic>;

      // Server error response
      if (data.containsKey('error')) {
        final error = data['error'];
        final errorMsg = error is Map ? '${error['message'] ?? error}' : '$error';
        _log('[Monti] SERVER ERROR: $errorMsg');
        _eventController.add(GeminiError('Server: $errorMsg'));
        return;
      }

      // Setup complete
      if (data.containsKey('setupComplete')) {
        _log('[Monti] Setup complete received!');
        _eventController.add(GeminiSetupComplete());
        return;
      }

      // Server content (audio/text response, interruption, turn complete)
      final serverContent = data['serverContent'] as Map<String, dynamic>?;
      if (serverContent != null) {
        // Interrupted
        if (serverContent['interrupted'] == true) {
          _eventController.add(GeminiInterrupted());
          return;
        }

        // Generation complete (informational, ignore)
        if (serverContent['generationComplete'] == true) {
          _log('[Monti] Generation complete (awaiting turnComplete)');
          return;
        }

        // Turn complete
        if (serverContent['turnComplete'] == true) {
          _eventController.add(GeminiTurnComplete());
          return;
        }

        // Model turn with parts
        final modelTurn = serverContent['modelTurn'] as Map<String, dynamic>?;
        if (modelTurn != null) {
          final parts = modelTurn['parts'] as List<dynamic>?;
          if (parts != null) {
            for (final part in parts) {
              final partMap = part as Map<String, dynamic>;

              // Audio data
              final inlineData =
                  partMap['inlineData'] as Map<String, dynamic>?;
              if (inlineData != null) {
                final audioData = inlineData['data'] as String?;
                if (audioData != null) {
                  final bytes = base64Decode(audioData);
                  _eventController
                      .add(GeminiAudioChunk(Uint8List.fromList(bytes)));
                }
              }

              // Function call
              final functionCall =
                  partMap['functionCall'] as Map<String, dynamic>?;
              if (functionCall != null) {
                final name = functionCall['name'] as String? ?? '';
                final args = functionCall['args'] as Map<String, dynamic>? ?? {};
                _log('[Monti] TOOL CALL: $name');
                _eventController.add(GeminiToolCall(name, args));
              }

              // Text (skip internal thinking)
              final isThought = partMap['thought'] == true;
              final text = partMap['text'] as String?;
              if (text != null && !isThought) {
                _eventController.add(GeminiTextChunk(text));
              }
            }
          }
        }
        return;
      }

      // Tool call (sent at top level, not inside serverContent)
      final toolCall = data['toolCall'] as Map<String, dynamic>?;
      if (toolCall != null) {
        final calls = toolCall['functionCalls'] as List<dynamic>?;
        if (calls != null) {
          for (final call in calls) {
            final callMap = call as Map<String, dynamic>;
            final name = callMap['name'] as String? ?? '';
            final args = callMap['args'] as Map<String, dynamic>? ?? {};
            _log('[Monti] TOOL CALL (top-level): $name');
            _eventController.add(GeminiToolCall(name, args));
          }
        }
        return;
      }

      // Unrecognized message - log it
      _log('[Monti] UNRECOGNIZED MSG keys: ${data.keys.toList()}');
      _log('[Monti] UNRECOGNIZED MSG: $msgStr');
    } catch (e) {
      _log('[Monti] Parse error: $e');
      _eventController.add(GeminiError('Parse error: $e'));
    }
  }
}
