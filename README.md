# AarogyaAI — Flutter Project

> Offline-first multilingual healthcare intelligence for rural India.
> Powered by Gemma 4 (llama.cpp) + Whisper Tiny, running entirely on-device.

---

## Quick Start

### 1. Prerequisites
```bash
flutter --version   # 3.16+
dart --version      # 3.2+
java -version       # JDK 17
ndk-build --version # NDK 25.2+
```

### 2. Install Flutter dependencies
```bash
cd aarogya_ai
flutter pub get
```

### 3. Generate Drift database code
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Clone native AI libraries
```bash
cd android/app/src/main/cpp
git clone https://github.com/ggerganov/llama.cpp --depth 1
git clone https://github.com/ggerganov/whisper.cpp --depth 1
```

### 5. Download AI models (for development)
```bash
# Gemma 4 Q4_K_M (from HuggingFace — requires login)
huggingface-cli download google/gemma-4-gguf gemma-3-1b-it-Q4_K_M.gguf

# Whisper small Hindi-tuned
wget https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin
```
Place models in `android/app/src/main/assets/models/` for dev testing,
or host on Firebase Storage and configure the download URL in `app_constants.dart`.

### 6. Add fonts
Download Noto Sans Devanagari from Google Fonts:
```
https://fonts.google.com/noto/specimen/Noto+Sans+Devanagari
```
Place in `assets/fonts/`:
- `NotoSansDevanagari-Regular.ttf`
- `NotoSansDevanagari-Bold.ttf`

### 7. Run on device
```bash
flutter run --release        # Release mode (AI runs faster)
flutter run --debug          # Debug mode
```

---

## Project Structure

```
lib/
├── core/
│   ├── constants/       app_constants.dart
│   ├── di/              service_locator.dart (GetIt)
│   ├── router/          app_router.dart (GoRouter)
│   └── theme/           app_theme.dart
├── data/
│   ├── local/
│   │   ├── dao/         chat_dao.dart, medicine_dao.dart
│   │   ├── database/    app_database.dart (Drift)
│   │   └── models/      table definitions
│   └── repositories/    chat_repository.dart, medicine_repository.dart
├── domain/
│   └── entities/        ChatMessage, Medicine
├── features/
│   ├── home/            HomeScreen, OnboardingScreen, HomeBloc
│   ├── symptom_chat/    ChatScreen, ChatBloc, widgets
│   ├── emergency/       EmergencyScreen, EmergencyDetailScreen
│   ├── medicine_reminder/ ReminderScreen, AddMedicineScreen, ReminderBloc
│   └── settings/        SettingsScreen
├── l10n/                AppLocalizations
├── shared/
│   ├── ffi/             llama_bindings.dart
│   ├── screens/         SplashScreen, ModelDownloadScreen
│   └── services/        ModelService, AudioService, TtsService, NotificationService
└── main.dart

android/app/src/main/
├── cpp/
│   ├── CMakeLists.txt
│   ├── llama_bridge.cpp    (Gemma inference — JNI)
│   ├── whisper_bridge.cpp  (STT — JNI)
│   ├── llama.cpp/          (clone from github)
│   └── whisper.cpp/        (clone from github)
├── kotlin/com/aarogya/ai/
│   ├── MainActivity.kt
│   ├── LlamaBridge.kt
│   └── WhisperBridge.kt
└── AndroidManifest.xml

assets/
├── prompts/   clinical_system.txt
├── first_aid/ choking.json, burns.json, snakebite.json, …
└── fonts/     NotoSansDevanagari-*.ttf
```

---

## App Flow

```
Launch → SplashScreen
  ↓  (first time)
OnboardingScreen (3 pages)
  ↓
ModelDownloadScreen (download Gemma 4 GGUF ~1.5GB once)
  ↓
HomeScreen (bottom nav shell)
  ├── /home       → Dashboard + quick actions
  ├── /chat       → Voice/text symptom AI chat
  ├── /emergency  → Offline first-aid playbooks (7 types)
  ├── /reminders  → Medicine schedule + notifications
  └── /settings   → Language, privacy, version
```

---

## Key Environment Variables

Update these in `lib/core/constants/app_constants.dart`:
```dart
static const String modelDownloadUrl = 'YOUR_FIREBASE_STORAGE_URL/gemma-3-1b-it-Q4_K_M.gguf';
static const String whisperDownloadUrl = 'YOUR_FIREBASE_STORAGE_URL/ggml-small.bin';
```

---

## Build Release APK
```bash
# Generate keystore (first time)
keytool -genkey -v -keystore aarogya.keystore \
  -alias aarogya -keyalg RSA -keysize 2048 -validity 10000

# Build release APK
flutter build apk --release --split-per-abi

# Output: build/app/outputs/flutter-apk/
```

---

## Legal

This application provides preliminary health guidance only.
It is NOT a substitute for professional medical advice, diagnosis, or treatment.
Always seek the advice of a qualified healthcare professional.

---

Built with ❤️ for rural India
