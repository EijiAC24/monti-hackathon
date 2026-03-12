import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';

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
  static const _model = 'gemini-2.5-flash-preview-native-audio-dialog';
  static const _wsBase =
      'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent';

  WebSocketChannel? _channel;
  final _eventController = StreamController<GeminiLiveEvent>.broadcast();
  bool _isConnected = false;

  Stream<GeminiLiveEvent> get events => _eventController.stream;
  bool get isConnected => _isConnected;

  /// Connect to Gemini Live API and send setup message.
  Future<void> connect({
    required String apiKey,
    required String systemPrompt,
    String voiceName = 'Aoede',
  }) async {
    if (_isConnected) await disconnect();

    final uri = Uri.parse('$_wsBase?key=$apiKey');

    try {
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;
      _isConnected = true;

      // Listen for messages
      _channel!.stream.listen(
        _handleMessage,
        onError: (Object error) {
          _eventController.add(GeminiError(error.toString()));
          _isConnected = false;
        },
        onDone: () {
          _isConnected = false;
          _eventController.add(GeminiDisconnected());
        },
      );

      // Send setup message
      _sendJson({
        'setup': {
          'model': 'models/$_model',
          'generationConfig': {
            'responseModalities': ['AUDIO'],
            'speechConfig': {
              'voiceConfig': {
                'prebuiltVoiceConfig': {
                  'voiceName': voiceName,
                },
              },
            },
          },
          'systemInstruction': {
            'parts': [
              {'text': systemPrompt},
            ],
          },
        },
      });
    } catch (e) {
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
      final data = jsonDecode(rawMessage as String) as Map<String, dynamic>;

      // Setup complete
      if (data.containsKey('setupComplete')) {
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

              // Text
              final text = partMap['text'] as String?;
              if (text != null) {
                _eventController.add(GeminiTextChunk(text));
              }
            }
          }
        }
        return;
      }

      // Tool call response (P1 - scenario_completed)
      // TODO: Handle function calling for goal detection
    } catch (e) {
      _eventController.add(GeminiError('Parse error: $e'));
    }
  }
}
