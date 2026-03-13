import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Handles microphone recording (16kHz PCM) and streaming audio playback (24kHz PCM).
class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<List<int>>? _recordSubscription;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _pcmPlayerReady = false;
  int _bufferedBytes = 0; // Track total bytes fed for drain timing
  DateTime? _playbackStartTime; // When first chunk was fed

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;

  /// Initialize the PCM streaming player for 24kHz mono playback.
  Future<void> initPlayer() async {
    if (_pcmPlayerReady) return;
    try {
      await FlutterPcmSound.setLogLevel(LogLevel.error);
      await FlutterPcmSound.setup(
        sampleRate: 24000,
        channelCount: 1,
      );
      // Feed threshold: request more data when buffer gets low
      await FlutterPcmSound.setFeedThreshold(8192);
      _pcmPlayerReady = true;
      print('[Monti] PCM player initialized (24kHz mono)');
    } catch (e) {
      print('[Monti] PCM player init error: $e');
    }
  }

  /// Request microphone permission.
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Start recording from microphone. Returns stream of PCM16 chunks.
  Future<Stream<Uint8List>?> startRecording() async {
    if (_isRecording) return null;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return null;

    final controller = StreamController<Uint8List>();

    final recordStream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
        autoGain: true,
        echoCancel: true,
        noiseSuppress: true,
      ),
    );

    _isRecording = true;
    _recordSubscription = recordStream.listen(
      (chunk) {
        controller.add(Uint8List.fromList(chunk));
      },
      onError: (Object error) {
        controller.addError(error);
      },
      onDone: () {
        controller.close();
        _isRecording = false;
      },
    );

    return controller.stream;
  }

  /// Stop recording.
  Future<void> stopRecording() async {
    _isRecording = false;
    await _recordSubscription?.cancel();
    _recordSubscription = null;
    await _recorder.stop();
  }

  /// Feed a PCM audio chunk for immediate streaming playback.
  /// Call this for each GeminiAudioChunk as it arrives.
  Future<void> feedPlaybackChunk(Uint8List pcmData) async {
    if (!_pcmPlayerReady) await initPlayer();
    _isPlaying = true;
    _playbackStartTime ??= DateTime.now();
    _bufferedBytes += pcmData.length;
    // Wrap raw PCM bytes directly as PcmArrayInt16 (little-endian 16-bit)
    final pcmArray = PcmArrayInt16(bytes: pcmData.buffer.asByteData(
      pcmData.offsetInBytes,
      pcmData.lengthInBytes,
    ));
    await FlutterPcmSound.feed(pcmArray);
  }

  /// Signal that the current response is complete.
  /// Waits briefly for remaining buffer to play out.
  /// Returns estimated remaining playback duration in milliseconds.
  int get remainingPlaybackMs {
    if (!_isPlaying || _playbackStartTime == null) return 0;
    // Total audio duration: 24kHz, 16-bit mono = 48000 bytes/sec
    final totalAudioMs = (_bufferedBytes * 1000) ~/ 48000;
    // Time already elapsed since playback started
    final elapsedMs = DateTime.now().difference(_playbackStartTime!).inMilliseconds;
    final remaining = totalAudioMs - elapsedMs;
    return remaining > 0 ? remaining : 0;
  }

  /// Mark playback as finished and reset buffer counter.
  void markPlaybackDone() {
    _bufferedBytes = 0;
    _playbackStartTime = null;
    _isPlaying = false;
  }

  /// Stop current playback immediately (for barge-in).
  Future<void> stopPlayback() async {
    _isPlaying = false;
    _bufferedBytes = 0;
    _playbackStartTime = null;
    if (_pcmPlayerReady) {
      await FlutterPcmSound.release();
      _pcmPlayerReady = false;
    }
  }

  /// Clean up resources.
  Future<void> dispose() async {
    await stopRecording();
    await stopPlayback();
    _recorder.dispose();
    if (_pcmPlayerReady) {
      await FlutterPcmSound.release();
    }
  }
}
