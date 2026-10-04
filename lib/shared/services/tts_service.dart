import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';

class TtsService {
  final _tts = FlutterTts();
  final _log = Logger();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _tts.setLanguage('hi-IN');
    await _tts.setSpeechRate(0.45);   // Slower for rural users
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    _initialized = true;
  }

  Future<void> speak(String text, {String language = 'hi-IN'}) async {
    try {
      await _ensureInitialized();
      await _tts.setLanguage(language);
      // Strip markdown before speaking
      final cleaned = text
          .replaceAll(RegExp(r'\*\*?(.*?)\*\*?'), r'\1')
          .replaceAll(RegExp(r'#+\s'), '')
          .replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '');
      await _tts.speak(cleaned);
    } catch (e) {
      _log.e('TTS speak failed: $e');
    }
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> setLanguage(String languageCode) async {
    await _ensureInitialized();
    await _tts.setLanguage(languageCode);
  }

  Future<List<dynamic>> getAvailableLanguages() async {
    await _ensureInitialized();
    return await _tts.getLanguages;
  }

  void dispose() {
    _tts.stop();
  }
}
