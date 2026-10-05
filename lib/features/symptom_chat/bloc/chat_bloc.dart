import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/chat_repository.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../shared/services/audio_service.dart';
import '../../../shared/services/tts_service.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatStarted extends ChatEvent {}

class ChatMessageSent extends ChatEvent {
  ChatMessageSent({required this.text, this.isVoice = false});
  final String text;
  final bool isVoice;
  @override
  List<Object?> get props => [text, isVoice];
}

class ChatVoiceRecordStarted extends ChatEvent {}

class ChatVoiceRecordStopped extends ChatEvent {}

class ChatTokenReceived extends ChatEvent {
  ChatTokenReceived(this.token);
  final String token;
  @override
  List<Object?> get props => [token];
}

class ChatResponseCompleted extends ChatEvent {
  ChatResponseCompleted({required this.fullResponse, this.urgencyLevel});
  final String fullResponse;
  final int? urgencyLevel;
  @override
  List<Object?> get props => [fullResponse, urgencyLevel];
}

class ChatErrorOccurred extends ChatEvent {
  ChatErrorOccurred(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ChatCleared extends ChatEvent {}

class ChatInputCleared extends ChatEvent {}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  ChatLoaded({
    required this.messages,
    this.isRecording = false,
    this.isTranscribing = false,
    this.isGenerating = false,
    this.streamingToken = '',
    this.inputText = '',
    this.error,
  });

  final List<ChatMessage> messages;
  final bool isRecording;
  final bool isTranscribing;
  final bool isGenerating;
  final String streamingToken;
  final String inputText;
  final String? error;

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isRecording,
    bool? isTranscribing,
    bool? isGenerating,
    String? streamingToken,
    String? inputText,
    String? error,
  }) =>
      ChatLoaded(
        messages: messages ?? this.messages,
        isRecording: isRecording ?? this.isRecording,
        isTranscribing: isTranscribing ?? this.isTranscribing,
        isGenerating: isGenerating ?? this.isGenerating,
        streamingToken: streamingToken ?? this.streamingToken,
        inputText: inputText ?? this.inputText,
        error: error,
      );

  @override
  List<Object?> get props => [
    messages,
    isRecording,
    isTranscribing,
    isGenerating,
    streamingToken,
    inputText,
    error,
  ];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required ChatRepository chatRepository,
    required AudioService audioService,
    required TtsService ttsService,
    required SharedPreferences prefs,
  })  : _repo = chatRepository,
        _audio = audioService,
        _tts = ttsService,
        _prefs = prefs,
        super(ChatInitial()) {
    on<ChatStarted>(_onStarted);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatVoiceRecordStarted>(_onVoiceRecordStarted);
    on<ChatVoiceRecordStopped>(_onVoiceRecordStopped);
    on<ChatTokenReceived>(_onTokenReceived);
    on<ChatResponseCompleted>(_onResponseCompleted);
    on<ChatErrorOccurred>(_onError);
    on<ChatCleared>(_onCleared);
    on<ChatInputCleared>(_onInputCleared);
  }

  final ChatRepository _repo;
  final AudioService _audio;
  final TtsService _tts;
  final SharedPreferences _prefs;

  final _uuid = const Uuid();
  String _currentSessionId = '';
  final StringBuffer _streamBuffer = StringBuffer();

  String get _langCode {
    final code = _prefs.getString('selected_language') ?? 'hi';
    return code == 'en' ? 'en' : 'hi';
  }

  // ─── Handlers ──────────────────────────────────────────────────────────

  Future<void> _onStarted(ChatStarted event, Emitter<ChatState> emit) async {
    _currentSessionId = _uuid.v4();
    final history = await _repo.getSessionMessages(_currentSessionId);
    emit(ChatLoaded(messages: history));
  }

  Future<void> _onMessageSent(
      ChatMessageSent event,
      Emitter<ChatState> emit,
      ) async {
    final current = state as ChatLoaded;

    final userMsg = ChatMessage.user(
      id: _uuid.v4(),
      sessionId: _currentSessionId,
      content: event.text,
      isVoice: event.isVoice,
    );
    await _repo.saveMessage(userMsg);

    emit(current.copyWith(
      messages: [...current.messages, userMsg],
      isGenerating: true,
      streamingToken: '',
      inputText: '',
      error: null,
    ));

    _streamBuffer.clear();

    try {
      final stream = _repo.generateResponse(
        sessionId: _currentSessionId,
        userMessage: event.text,
        history: current.messages,
      );

      await emit.forEach<String>(
        stream,
        onData: (token) {
          _streamBuffer.write(token);
          return (state as ChatLoaded).copyWith(
            streamingToken: _streamBuffer.toString(),
          );
        },
        onError: (e, _) {
          add(ChatErrorOccurred(e.toString()));
          return state;
        },
      );

      final fullResponse = _streamBuffer.toString();
      final urgency = _parseUrgencyFromResponse(fullResponse);
      add(ChatResponseCompleted(
        fullResponse: fullResponse,
        urgencyLevel: urgency,
      ));
    } catch (e) {
      add(ChatErrorOccurred('AI is unavailable: ${e.toString()}'));
    }
  }

  Future<void> _onVoiceRecordStarted(
      ChatVoiceRecordStarted event,
      Emitter<ChatState> emit,
      ) async {
    final current = state as ChatLoaded;
    try {
      await _audio.startRecording();
      emit(current.copyWith(isRecording: true, error: null));
    } catch (e) {
      emit(current.copyWith(
        isRecording: false,
        error: 'Could not start recording: $e',
      ));
    }
  }

  Future<void> _onVoiceRecordStopped(
      ChatVoiceRecordStopped event,
      Emitter<ChatState> emit,
      ) async {
    // Phase 1: stop recording
    final beforeStop = state as ChatLoaded;
    final audioPath = await _audio.stopRecording();
    emit(beforeStop.copyWith(
      isRecording: false,
      isTranscribing: true,
      error: null,
    ));

    if (audioPath == null) {
      emit((state as ChatLoaded).copyWith(isTranscribing: false));
      return;
    }

    // Phase 2: transcribe
    final text = await _audio.transcribeLastRecording(
      languageCode: _langCode,
    );

    print('>>> BLoC: transcribe returned: "$text"');
    print('>>> BLoC: emit.isDone = ${emit.isDone}');

    if (emit.isDone) {
      print('>>> BLoC: emitter is DONE — state will not update');
      return;
    }

    final after = state as ChatLoaded;

    if (text == null || text.isEmpty) {
      emit(after.copyWith(
        isTranscribing: false,
        error: 'Could not understand the audio. Please try again.',
      ));
      return;
    }

    print('>>> BLoC: emitting inputText="$text"');
    emit(after.copyWith(
      isTranscribing: false,
      inputText: text,
      error: null,
    ));
  }

  Future<void> _onTokenReceived(
      ChatTokenReceived event,
      Emitter<ChatState> emit,
      ) async {}

  Future<void> _onResponseCompleted(
      ChatResponseCompleted event,
      Emitter<ChatState> emit,
      ) async {
    final current = state as ChatLoaded;
    final reasoning = _extractReasoning(event.fullResponse);
    final cleanedResponse = _cleanResponse(event.fullResponse);

    final assistantMsg = ChatMessage.assistant(
      id: _uuid.v4(),
      sessionId: _currentSessionId,
      content: cleanedResponse,
      urgencyLevel: event.urgencyLevel,
      reasoning: reasoning,
    );
    await _repo.saveMessage(assistantMsg);

    await _tts.speak(cleanedResponse);

    emit(current.copyWith(
      messages: [...current.messages, assistantMsg],
      isGenerating: false,
      streamingToken: '',
    ));
  }

  void _onError(ChatErrorOccurred event, Emitter<ChatState> emit) {
    final current = state as ChatLoaded;
    emit(current.copyWith(isGenerating: false, error: event.message));
  }

  Future<void> _onCleared(ChatCleared event, Emitter<ChatState> emit) async {
    _currentSessionId = _uuid.v4();
    emit(ChatLoaded(messages: []));
  }

  void _onInputCleared(ChatInputCleared event, Emitter<ChatState> emit) {
    final current = state as ChatLoaded;
    emit(current.copyWith(inputText: ''));
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  int? _parseUrgencyFromResponse(String response) {
    final match = RegExp(r'\[URGENCY:(\d)\]').firstMatch(response);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }
    return null;
  }

  String _extractReasoning(String response) {
    final match =
    RegExp(r'\[REASONING:(.*?)\]', dotAll: true).firstMatch(response);
    return match?.group(1)?.trim() ?? '';
  }

  String _cleanResponse(String response) {
    return response
        .replaceAll(RegExp(r'\[URGENCY:\d\]'), '')
        .replaceAll(RegExp(r'\[REASONING:.*?\]', dotAll: true), '')
        .trim();
  }
}