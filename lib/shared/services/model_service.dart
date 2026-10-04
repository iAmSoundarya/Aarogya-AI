import 'dart:async';
import 'dart:io';

import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

/// Manages the on-device GGUF model lifecycle using llama_flutter_android.
class ModelService {
  ModelService({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;
  final _log = Logger();

  final _controller = LlamaController();
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  // ─── Initialise ─────────────────────────────────────────────────────────

  Future<void> initialize() async {
    final modelExists = await _checkModelExists();
    if (modelExists) {
      await _loadModel();
    }
  }

  Future<bool> _checkModelExists() async {
    final path = await _getModelPath();
    final file = File(path);
    return file.existsSync() &&
        _prefs.getBool(AppConstants.keyModelDownloaded) == true;
  }

  Future<String> _getModelPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/${AppConstants.modelFileName}';
  }

  // ─── Download (no-op if file is already present) ────────────────────────

  Future<void> downloadModel({
    required void Function(double progress, String status) onProgress,
  }) async {
    final path = await _getModelPath();

    if (!File(path).existsSync()) {
      throw Exception(
        'Model file not found at $path. '
            'Push it manually via adb, or provide a real download URL.',
      );
    }

    onProgress(1.0, 'Using existing model');
    await _prefs.setBool(AppConstants.keyModelDownloaded, true);
    await _loadModel();
  }

  // ─── Load / Unload ──────────────────────────────────────────────────────

  Future<void> _loadModel() async {
    final modelPath = await _getModelPath();
    try {
      await _controller.loadModel(
        modelPath: modelPath,
        threads: 4, // A good default for mobile
        contextSize: AppConstants.modelContextLength,
      );
      _isLoaded = true;
      _log.i('Model loaded from $modelPath');
    } catch (e) {
      _isLoaded = false;
      _log.e('Model load failed: $e');
      rethrow;
    }
  }

  Future<void> unloadModel() async {
    await _controller.dispose();
    _isLoaded = false;
    _log.i('Model unloaded');
  }

  // ─── Inference ──────────────────────────────────────────────────────────

  Stream<String> generateStream({
    required String systemPrompt,
    required List<Map<String, String>> messages,
  }) async* {
    if (!_isLoaded) {
      throw StateError('Model not loaded');
    }

    // Read the user's language preference
    final langCode =
        _prefs.getString(AppConstants.keySelectedLanguage) ?? 'hi';
    final languageName = langCode == 'en' ? 'English' : 'Hindi';

    // Build a proper chat-message list.
    // The package auto-detects Gemma's chat template from the model filename
    // ('gemma-3-1b-it-Q4_K_M.gguf' → gemma template).
    final chatMessages = <ChatMessage>[
      ChatMessage(
        role: 'system',
        content:
        '$systemPrompt\n\n'
            'IMPORTANT: Respond ONLY in $languageName. '
            'Never mix languages. Never translate.',
      ),
      ...messages.map((m) => ChatMessage(
        role: (m['role'] ?? 'user') == 'user' ? 'user' : 'assistant',
        content: m['content'] ?? '',
      )),
    ];

    await for (final token in _controller.generateChat(
      messages: chatMessages,
      // template: null → auto-detect from model filename
      maxTokens: AppConstants.modelMaxTokens,
      temperature: 0.7,
      repeatPenalty: 1.15,     // prevents the 5-6 loop
      repeatLastN: 64,
    )) {
      // Filter out any special tokens that might leak through
      if (token.contains('<end_of_turn>') || token.contains('<eos>')) {
        break;
      }
      yield token;
    }
  }

  // ─── Voice (not implemented) ────────────────────────────────────────────

  Future<String> transcribeAudio({
    required String audioFilePath,
    required String languageCode,
  }) async {
    throw UnimplementedError(
      'Voice transcription is not wired yet. '
          'Use the speech_to_text package instead.',
    );
  }
}