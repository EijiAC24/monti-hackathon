import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/child_profile.dart';
import '../../models/scenario.dart';
import '../../services/audio_service.dart';
import '../../services/gemini_live_service.dart';
import '../../services/system_prompt.dart';
import '../../shared/widgets/monty_character.dart';

class ConversationState {
  final MontyState montyState;
  final String currentText;
  final bool isConnected;
  final String? errorMessage;

  const ConversationState({
    this.montyState = MontyState.idle,
    this.currentText = '',
    this.isConnected = false,
    this.errorMessage,
  });

  ConversationState copyWith({
    MontyState? montyState,
    String? currentText,
    bool? isConnected,
    String? errorMessage,
  }) {
    return ConversationState(
      montyState: montyState ?? this.montyState,
      currentText: currentText ?? this.currentText,
      isConnected: isConnected ?? this.isConnected,
      errorMessage: errorMessage,
    );
  }
}

class ConversationNotifier extends StateNotifier<ConversationState> {
  final GeminiLiveService _gemini = GeminiLiveService();
  final AudioService _audio = AudioService();
  StreamSubscription<GeminiLiveEvent>? _eventSub;
  StreamSubscription<Uint8List>? _audioSub;
  final StringBuffer _textBuffer = StringBuffer();

  ConversationNotifier() : super(const ConversationState());

  /// Start a conversation session.
  Future<void> startSession({
    required String apiKey,
    required ChildProfile profile,
    required Scenario scenario,
  }) async {
    // Request mic permission
    final granted = await _audio.requestPermission();
    if (!granted) {
      state = state.copyWith(
        errorMessage: 'マイクの許可が必要です',
      );
      return;
    }

    state = state.copyWith(
      montyState: MontyState.thinking,
      currentText: 'つないでるよ...',
    );

    // Build system prompt
    final systemPrompt = SystemPromptBuilder.build(
      profile: profile,
      scenario: scenario,
    );

    // Listen for Gemini events
    _eventSub = _gemini.events.listen(_handleGeminiEvent);

    // Connect to Gemini
    await _gemini.connect(
      apiKey: apiKey,
      systemPrompt: systemPrompt,
    );
  }

  /// Stop the conversation session.
  Future<void> stopSession() async {
    await _audioSub?.cancel();
    _audioSub = null;
    await _eventSub?.cancel();
    _eventSub = null;
    await _audio.stopRecording();
    await _audio.stopPlayback();
    await _gemini.disconnect();

    state = const ConversationState();
  }

  /// Send a text message (for testing without audio).
  void sendText(String text) {
    _gemini.sendText(text);
    state = state.copyWith(
      montyState: MontyState.thinking,
      currentText: 'うーんと...',
    );
  }

  Future<void> _startListening() async {
    final stream = await _audio.startRecording();
    if (stream == null) return;

    state = state.copyWith(
      montyState: MontyState.listening,
      currentText: 'きいてるよ...',
    );

    _audioSub = stream.listen((chunk) {
      _gemini.sendAudio(chunk);
    });
  }

  Future<void> _stopListening() async {
    await _audioSub?.cancel();
    _audioSub = null;
    await _audio.stopRecording();
  }

  void _handleGeminiEvent(GeminiLiveEvent event) {
    switch (event) {
      case GeminiSetupComplete():
        state = state.copyWith(
          isConnected: true,
          montyState: MontyState.idle,
          currentText: 'はなしてね！',
        );
        // Start listening for audio input
        _startListening();

      case GeminiAudioChunk(pcmData: final data):
        // Buffer audio for playback
        _audio.addPlaybackChunk(data);
        state = state.copyWith(montyState: MontyState.talking);

      case GeminiTextChunk(text: final text):
        _textBuffer.write(text);
        state = state.copyWith(
          montyState: MontyState.talking,
          currentText: _textBuffer.toString(),
        );

      case GeminiTurnComplete():
        // Play buffered audio
        _playResponseAndResumeMic();

      case GeminiInterrupted():
        // Barge-in: stop playback and resume listening
        _audio.stopPlayback();
        _textBuffer.clear();
        state = state.copyWith(
          montyState: MontyState.listening,
          currentText: 'きいてるよ...',
        );

      case GeminiError(message: final msg):
        state = state.copyWith(errorMessage: msg);

      case GeminiDisconnected():
        state = state.copyWith(
          isConnected: false,
          montyState: MontyState.idle,
          currentText: '',
        );
    }
  }

  Future<void> _playResponseAndResumeMic() async {
    // Stop mic while playing to avoid feedback
    await _stopListening();

    // Play the buffered audio
    await _audio.playBuffer();

    // Clear text buffer after playback
    _textBuffer.clear();

    // Resume listening
    if (_gemini.isConnected) {
      state = state.copyWith(
        montyState: MontyState.idle,
        currentText: 'はなしてね！',
      );
      await _startListening();
    }
  }

  @override
  void dispose() {
    stopSession();
    _gemini.dispose();
    _audio.dispose();
    super.dispose();
  }
}

final conversationProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  return ConversationNotifier();
});
