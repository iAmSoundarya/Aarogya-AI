import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.urgencyLevel,
    this.reasoning,
    required this.createdAt,
    this.isVoice = false,
  });

  final String id;
  final String sessionId;
  final String role; // 'user' | 'assistant'
  final String content;
  final int? urgencyLevel; // 1–4
  final String? reasoning;
  final DateTime createdAt;
  final bool isVoice;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  factory ChatMessage.user({
    required String id,
    required String sessionId,
    required String content,
    bool isVoice = false,
  }) =>
      ChatMessage(
        id: id,
        sessionId: sessionId,
        role: 'user',
        content: content,
        createdAt: DateTime.now(),
        isVoice: isVoice,
      );

  factory ChatMessage.assistant({
    required String id,
    required String sessionId,
    required String content,
    int? urgencyLevel,
    String? reasoning,
  }) =>
      ChatMessage(
        id: id,
        sessionId: sessionId,
        role: 'assistant',
        content: content,
        urgencyLevel: urgencyLevel,
        reasoning: reasoning,
        createdAt: DateTime.now(),
      );

  @override
  List<Object?> get props =>
      [id, sessionId, role, content, urgencyLevel, reasoning, createdAt, isVoice];
}
