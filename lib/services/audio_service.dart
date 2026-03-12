import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Handles microphone recording (16kHz PCM) and audio playback (24kHz PCM).
class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<List<int>>? _recordSubscription;
  bool _isRecording = false;
  bool _isPlaying = false;

  // Buffered PCM data for current response
  final List<int> _playbackBuffer = [];

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;

  /// Request microphone permission.
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Start recording from microphone. Returns stream of PCM16 chunks.
  ///
  /// Each chunk is 16kHz, 16-bit PCM, mono.
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

  /// Add audio chunk to playback buffer.
  void addPlaybackChunk(Uint8List pcmData) {
    _playbackBuffer.addAll(pcmData);
  }

  /// Play buffered audio as WAV (24kHz PCM mono).
  Future<void> playBuffer() async {
    if (_playbackBuffer.isEmpty) return;

    _isPlaying = true;
    final wavBytes = _createWav(
      Uint8List.fromList(_playbackBuffer),
      sampleRate: 24000,
    );
    _playbackBuffer.clear();

    await _player.play(BytesSource(wavBytes));

    // Wait for playback to complete
    await _player.onPlayerComplete.first;
    _isPlaying = false;
  }

  /// Stop current playback (for barge-in).
  Future<void> stopPlayback() async {
    _isPlaying = false;
    _playbackBuffer.clear();
    await _player.stop();
  }

  /// Clean up resources.
  Future<void> dispose() async {
    await stopRecording();
    await stopPlayback();
    _recorder.dispose();
    _player.dispose();
  }

  /// Create WAV file bytes from raw PCM data.
  Uint8List _createWav(Uint8List pcmData, {required int sampleRate}) {
    const channels = 1;
    const bitsPerSample = 16;
    final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    final blockAlign = channels * bitsPerSample ~/ 8;
    final dataSize = pcmData.length;
    final fileSize = 36 + dataSize;

    final buffer = ByteData(44 + dataSize);
    var offset = 0;

    // RIFF header
    buffer.setUint8(offset++, 0x52); // R
    buffer.setUint8(offset++, 0x49); // I
    buffer.setUint8(offset++, 0x46); // F
    buffer.setUint8(offset++, 0x46); // F
    buffer.setUint32(offset, fileSize, Endian.little);
    offset += 4;
    buffer.setUint8(offset++, 0x57); // W
    buffer.setUint8(offset++, 0x41); // A
    buffer.setUint8(offset++, 0x56); // V
    buffer.setUint8(offset++, 0x45); // E

    // fmt chunk
    buffer.setUint8(offset++, 0x66); // f
    buffer.setUint8(offset++, 0x6D); // m
    buffer.setUint8(offset++, 0x74); // t
    buffer.setUint8(offset++, 0x20); // (space)
    buffer.setUint32(offset, 16, Endian.little); // chunk size
    offset += 4;
    buffer.setUint16(offset, 1, Endian.little); // PCM format
    offset += 2;
    buffer.setUint16(offset, channels, Endian.little);
    offset += 2;
    buffer.setUint32(offset, sampleRate, Endian.little);
    offset += 4;
    buffer.setUint32(offset, byteRate, Endian.little);
    offset += 4;
    buffer.setUint16(offset, blockAlign, Endian.little);
    offset += 2;
    buffer.setUint16(offset, bitsPerSample, Endian.little);
    offset += 2;

    // data chunk
    buffer.setUint8(offset++, 0x64); // d
    buffer.setUint8(offset++, 0x61); // a
    buffer.setUint8(offset++, 0x74); // t
    buffer.setUint8(offset++, 0x61); // a
    buffer.setUint32(offset, dataSize, Endian.little);
    offset += 4;

    // PCM data
    for (var i = 0; i < pcmData.length; i++) {
      buffer.setUint8(offset++, pcmData[i]);
    }

    return buffer.buffer.asUint8List();
  }
}
