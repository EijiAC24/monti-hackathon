import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/child_profile.dart';
import '../../models/scenario.dart';
import '../../services/audio_service.dart';
import '../../services/gemini_live_service.dart';
import '../../services/system_prompt.dart';
import '../../shared/widgets/monty_character.dart';

void _log(String msg) {
  if (kDebugMode) debugPrint(msg);
}

class ConversationState {
  final MontyState montyState;
  final String currentText;
  final bool isConnected;
  final bool goalComplete;
  final String? errorMessage;
  final double audioLevel; // 0.0 - 1.0, driven by incoming audio chunks

  const ConversationState({
    this.montyState = MontyState.idle,
    this.currentText = '',
    this.isConnected = false,
    this.goalComplete = false,
    this.errorMessage,
    this.audioLevel = 0.0,
  });

  ConversationState copyWith({
    MontyState? montyState,
    String? currentText,
    bool? isConnected,
    bool? goalComplete,
    String? errorMessage,
    double? audioLevel,
  }) {
    return ConversationState(
      montyState: montyState ?? this.montyState,
      currentText: currentText ?? this.currentText,
      isConnected: isConnected ?? this.isConnected,
      goalComplete: goalComplete ?? this.goalComplete,
      errorMessage: errorMessage,
      audioLevel: audioLevel ?? this.audioLevel,
    );
  }
}

class ConversationNotifier extends StateNotifier<ConversationState> {
  final GeminiLiveService _gemini = GeminiLiveService();
  final AudioService _audio = AudioService();
  StreamSubscription<GeminiLiveEvent>? _eventSub;
  StreamSubscription<Uint8List>? _audioSub;
  final StringBuffer _textBuffer = StringBuffer();
  bool _isSpeaking = false; // true while Monty is speaking - mutes mic input to Gemini
  bool _goalDetected = false;
  int _turnId = 0; // Tracks current turn to invalidate stale unmute timers
  int _completedTurns = 0; // Count completed turns to guard early function calls
  final audioLevel = ValueNotifier<double>(0.0);
  String _languageCode = 'ja';
  String _charName = 'Monty';
  String _childName = '';
  int _childAge = 5;
  Timer? _maxTimer; // Safety timer to auto-end conversation
  static const _maxDuration = Duration(minutes: 3);

  ConversationNotifier() : super(const ConversationState());

  /// Start a conversation session.
  Future<void> startSession({
    required String accessToken,
    required String projectId,
    required String location,
    required ChildProfile profile,
    required Scenario scenario,
    String languageCode = 'ja',
  }) async {
    _log('[Monti] startSession called');

    // Request mic permission
    final granted = await _audio.requestPermission();
    if (!granted) {
      state = state.copyWith(errorMessage: 'mic_required');
      return;
    }

    // Initialize streaming player
    await _audio.initPlayer();

    state = state.copyWith(
      montyState: MontyState.thinking,
      currentText: '',
    );

    // Build system prompt
    _languageCode = languageCode;
    _charName = profile.displayName;
    _childName = profile.nickname;
    _childAge = profile.age;
    final systemPrompt = SystemPromptBuilder.build(
      profile: profile,
      scenario: scenario,
      languageCode: languageCode,
    );

    // Listen for Gemini events
    _eventSub = _gemini.events.listen(_handleGeminiEvent);

    // Safety timer: auto-end after max duration
    _maxTimer?.cancel();
    _maxTimer = Timer(_maxDuration, () {
      _log('[Monti] Max duration reached, ending session');
      _triggerGoalComplete();
    });

    // Connect to Gemini with character-specific voice
    final voiceName = ChildProfile.voiceForEmoji(profile.emoji);
    await _gemini.connect(
      accessToken: accessToken,
      projectId: projectId,
      location: location,
      systemPrompt: systemPrompt,
      voiceName: voiceName,
    );
  }

  /// Reset state to initial (used after celebration screen).
  void resetState() {
    state = const ConversationState();
  }

  /// Stop the conversation session.
  Future<void> stopSession() async {
    _maxTimer?.cancel();
    _maxTimer = null;
    await _audioSub?.cancel();
    _audioSub = null;
    await _eventSub?.cancel();
    _eventSub = null;
    await _audio.stopRecording();
    await _audio.stopPlayback();
    await _gemini.disconnect();

    // Keep goalComplete if it was set, so celebration screen stays visible
    final wasGoalComplete = state.goalComplete;
    state = wasGoalComplete
        ? const ConversationState(goalComplete: true)
        : const ConversationState();
  }

  /// Send a text message (for testing without audio).
  void sendText(String text) {
    _gemini.sendText(text);
    state = state.copyWith(
      montyState: MontyState.thinking,
      currentText: '',
    );
  }

  Future<void> _startListening() async {
    final stream = await _audio.startRecording();
    if (stream == null) {
      _log('[Monti] startRecording returned null');
      return;
    }
    _log('[Monti] Mic started');

    state = state.copyWith(
      montyState: MontyState.listening,
      currentText: '',
    );

    int chunkCount = 0;
    _audioSub = stream.listen((chunk) {
      // Don't send mic audio while Monty is speaking - prevents echo barge-in
      if (!_isSpeaking) {
        _gemini.sendAudio(chunk);
        chunkCount++;
        if (chunkCount % 50 == 1) {
          _log('[Monti] Sending audio chunk #$chunkCount (${chunk.length} bytes)');
        }
      }
    });
  }

  Future<void> _stopListening() async {
    await _audioSub?.cancel();
    _audioSub = null;
    await _audio.stopRecording();
    // Give recorder time to fully release before restarting
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  void _handleGeminiEvent(GeminiLiveEvent event) {
    switch (event) {
      case GeminiSetupComplete():
        _log('[Monti] Setup complete! Monty speaks first...');
        state = state.copyWith(
          isConnected: true,
          montyState: MontyState.thinking,
          currentText: '',
        );
        // Character initiates the conversation - greet AND ask first question in same turn
        final slowNote = _childAge <= 4
            ? (_languageCode == 'ja' ? 'とてもゆっくり話して。' : 'Speak VERY slowly. ')
            : '';
        _gemini.sendText(_languageCode == 'ja'
            ? '電話がつながったよ。${slowNote}「もしもーし！$_childNameちゃん！$_charNameだよ！」と子供の名前を呼んで挨拶して、すぐにシナリオの最初の質問もしてね。挨拶だけで終わらないで。'
            : 'The call is connected. ${slowNote}Greet with "Hello $_childName! It\'s $_charName!" — always say the child\'s name first. Then immediately ask the scenario\'s first question in the same turn. Do NOT stop after just greeting.');
        // Don't start mic yet — wait until Monty's first turn completes

      case GeminiAudioChunk(pcmData: final data):
        // Reset buffer counter at start of new response
        if (state.montyState != MontyState.talking) {
          _audio.markPlaybackDone(); // Reset buffered bytes for new turn
          state = state.copyWith(montyState: MontyState.talking);
        }
        _isSpeaking = true;
        _audio.feedPlaybackChunk(data);
        // Calculate audio level from PCM data (RMS of 16-bit samples)
        final samples = data.buffer.asInt16List(data.offsetInBytes, data.lengthInBytes ~/ 2);
        double sum = 0;
        for (final s in samples) {
          sum += s * s;
        }
        final rms = math.sqrt(sum / samples.length) / 32768.0;
        audioLevel.value = (rms * 4.0).clamp(0.0, 1.0);

      case GeminiTextChunk(text: final text):
        _textBuffer.write(text);
        final fullText = _textBuffer.toString();
        if (fullText.contains('[DONE]')) {
          _goalDetected = true;
        }
        // Strip [DONE] marker from display text
        final displayText = fullText.replaceAll('[DONE]', '').trim();
        state = state.copyWith(
          montyState: MontyState.talking,
          currentText: displayText,
        );

      case GeminiToolCall(name: final name):
        if (name == 'end_conversation') {
          // Guard: ignore if conversation hasn't had enough back-and-forth
          if (_completedTurns < 2) {
            _log('[Monti] Ignoring early end_conversation (only $_completedTurns turns)');
            break;
          }
          _log('[Monti] Goal achieved via function call! Setting flag.');
          _goalDetected = true;
          // Safety: if turnComplete never arrives, trigger after 8 seconds
          Future<void>.delayed(const Duration(seconds: 8), () {
            if (_goalDetected) {
              _log('[Monti] Safety trigger: turnComplete not received');
              _triggerGoalComplete();
            }
          });
        }

      case GeminiTurnComplete():
        _completedTurns++;
        _log('[Monti] Turn complete (turn #$_completedTurns)');
        _onTurnComplete();

      case GeminiInterrupted():
        // Barge-in: stop playback immediately
        _log('[Monti] Interrupted (barge-in)');
        _isSpeaking = false;
        _audio.stopPlayback().then((_) {
          _audio.initPlayer(); // Re-init for next response
        });
        _textBuffer.clear();
        state = state.copyWith(
          montyState: MontyState.listening,
          currentText: '',
        );

      case GeminiError(message: final msg):
        _log('[Monti] ERROR: $msg');
        state = state.copyWith(errorMessage: msg);

      case GeminiDisconnected():
        state = state.copyWith(
          isConnected: false,
          montyState: MontyState.idle,
          currentText: '',
        );
    }
  }

  Future<void> _triggerGoalComplete() async {
    if (state.goalComplete) return; // Already triggered
    _log('[Monti] Goal complete!');
    _goalDetected = false;
    _maxTimer?.cancel();
    // finishPlayback is already called by _onTurnComplete, no need to wait again
    _isSpeaking = false;
    _log('[Monti] Showing celebration screen');
    state = state.copyWith(
      montyState: MontyState.happy,
      goalComplete: true,
    );
    await stopSession();
  }

  Future<void> _onTurnComplete() async {
    // Check if goal was achieved (via function call or [DONE] marker)
    if (_goalDetected) {
      // Wait for goodbye audio to finish before showing celebration
      final waitMs = _audio.remainingPlaybackMs + 500;
      _log('[Monti] Goal complete! Waiting ${waitMs}ms for goodbye audio');
      await Future<void>.delayed(Duration(milliseconds: waitMs));
      _audio.markPlaybackDone();
      _isSpeaking = false;
      _triggerGoalComplete();
      return;
    }

    // Clear text buffer
    _textBuffer.clear();

    if (_gemini.isConnected) {
      // Start mic immediately but keep _isSpeaking=true to mute sending
      // until speaker finishes draining
      final drainMs = _audio.remainingPlaybackMs + 500;
      _log('[Monti] Turn done. Mic now, unmute in ${drainMs}ms');

      await _stopListening();
      state = state.copyWith(
        montyState: MontyState.listening,
        currentText: '',
      );
      await _startListening();

      // Unmute after speaker finishes (guarded by turn ID)
      _turnId++;
      final expectedTurn = _turnId;
      Future<void>.delayed(Duration(milliseconds: drainMs), () {
        // Only unmute if no new turn has started
        if (_turnId == expectedTurn) {
          _audio.markPlaybackDone();
          _isSpeaking = false;
          _log('[Monti] Speaker done, sending mic audio now');
        } else {
          _log('[Monti] Skipping stale unmute (turn $expectedTurn, now $_turnId)');
        }
      });
    }
  }

  @override
  void dispose() {
    stopSession();
    audioLevel.dispose();
    _gemini.dispose();
    _audio.dispose();
    super.dispose();
  }
}

final conversationProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  return ConversationNotifier();
});
