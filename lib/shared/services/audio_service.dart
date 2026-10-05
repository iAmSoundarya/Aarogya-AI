import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:whisper_ggml/whisper_ggml.dart';

class AudioService {
  final _recorder = AudioRecorder();
  final _whisper = WhisperController();
  final _log = Logger();
  String? _currentPath;

  // ─── Recording ──────────────────────────────────────────────────────────

  Future<void> startRecording() async {
    print('>>> [AudioService] startRecording called');
    try {
      print('>>> [AudioService] Requesting permission...');
      final hasPermission = await _recorder.hasPermission();
      print('>>> [AudioService] hasPermission: $hasPermission');
      if (!hasPermission) throw Exception('Microphone permission denied');

      final dir = await getTemporaryDirectory();
      _currentPath = '${dir.path}/aarogya_recording.wav';
      print('>>> [AudioService] Path: $_currentPath');

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _currentPath!,
      );
      print('>>> [AudioService] Recording started');
    } catch (e) {
      print('>>> [AudioService] ERROR: $e');
      rethrow;
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _log.d('Recording stopped: $path');
      return path;
    } catch (e) {
      _log.e('Stop recording failed: $e');
      return null;
    }
  }

  // ─── Transcription ───────────────────────────────────────────────────────

  /// Transcribe the last recording.
  /// [languageCode] should be 'hi' for Hindi or 'en' for English.
  /// Returns the transcribed text, or null if transcription failed.
  Future<String?> transcribeLastRecording({
    required String languageCode,
    void Function(int percent)? onProgress,
  }) async {
    if (_currentPath == null || !File(_currentPath!).existsSync()) {
      _log.w('No recording file to transcribe');
      return null;
    }

    try {
      _log.i('Transcribing $_currentPath with lang=$languageCode');

      final result = await _whisper.transcribe(
        model: WhisperModel.base,
        audioPath: _currentPath!,
        lang: languageCode,        // 'hi' or 'en'
        onProgress: onProgress,
      );

      final text = result?.transcription.text?.trim();
      _log.i('Transcription result: $text');
      return text;
    } catch (e) {
      _log.e('Transcription failed: $e');
      return null;
    }
  }

  // ─── Cleanup ─────────────────────────────────────────────────────────────

  Future<void> cancelRecording() async {
    await _recorder.cancel();
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }

  bool get isRecording => _recorder.isRecording() as bool;
}