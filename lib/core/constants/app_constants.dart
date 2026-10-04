import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'AarogyaAI';
  static const String appVersion = '1.0.0';

  // Model config
  static const String modelFileName = 'gemma-3-1b-it-Q4_K_M.gguf';
  static const String whisperModelFileName = 'ggml-small.bin'; // Hindi-tuned
  static const int modelContextLength = 2048;
  static const int modelMaxTokens = 512;
  static const double modelTemperature = 0.3; // Low temp for medical accuracy

  // Storage keys
  static const String keyModelDownloaded = 'model_downloaded';
  static const String keyModelVersion = 'model_version';
  static const String keySelectedLanguage = 'selected_language';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyUserProfile = 'user_profile';

  // Model download
  // TODO: Replace with your Firebase Storage or CDN URL
  static const String modelDownloadUrl =
      'https://storage.googleapis.com/aarogya-models/gemma-3-1b-it-Q4_K_M.gguf';
  static const String whisperDownloadUrl =
      'https://storage.googleapis.com/aarogya-models/ggml-small.bin';

  // Urgency levels
  static const int urgencyLow = 1;
  static const int urgencyMedium = 2;
  static const int urgencyHigh = 3;
  static const int urgencyCritical = 4;

  // Supported languages
  static const List<Locale> supportedLocales = [
    Locale('hi', 'IN'), // Hindi
    Locale('bho'),      // Bhojpuri
    Locale('mai'),      // Maithili
    Locale('bn', 'IN'), // Bengali
    Locale('en', 'IN'), // English (fallback)
  ];

  // Emergency types
  static const List<String> emergencyTypes = [
    'choking',
    'burns',
    'snakebite',
    'dehydration',
    'heatstroke',
    'bleeding',
    'cardiac',
  ];

  // Clinical system prompt path
  static const String clinicalPromptPath = 'assets/prompts/clinical_system.txt';

  // First aid playbooks path
  static const String firstAidBasePath = 'assets/first_aid/';
}
