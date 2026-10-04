import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/chat_message.dart';
import '../local/database/app_database.dart';
import '../local/models/chat_message_table.dart';
import '../../shared/services/model_service.dart';

class ChatRepository {
  ChatRepository({required AppDatabase db, required ModelService modelService})
      : _db = db,
        _modelService = modelService;

  final AppDatabase _db;
  final ModelService _modelService;
  String? _clinicalPrompt;

  // ─── Prompt ─────────────────────────────────────────────────────────────

  Future<String> _getSystemPrompt() async {
    _clinicalPrompt ??=
        await rootBundle.loadString(AppConstants.clinicalPromptPath);
    return _clinicalPrompt!;
  }

  // ─── Messages ───────────────────────────────────────────────────────────

  Future<List<ChatMessage>> getSessionMessages(String sessionId) async {
    final rows = await _db.chatDao.getBySession(sessionId);
    return rows.map(_rowToEntity).toList();
  }

  Future<void> saveMessage(ChatMessage message) async {
    await _db.chatDao.insertMessage(ChatMessagesCompanion.insert(
      sessionId: message.sessionId,
      role: message.role,
      content: message.content,
      urgencyLevel: Value(message.urgencyLevel),
      reasoning: Value(message.reasoning),
      isVoice: Value(message.isVoice),
    ));
  }

  // ─── AI Inference ────────────────────────────────────────────────────────

  /// Returns a stream of tokens from the on-device model.
  Stream<String> generateResponse({
    required String sessionId,
    required String userMessage,
    required List<ChatMessage> history,
  }) async* {
    final systemPrompt = await _getSystemPrompt();

    // Build message history (last 10 turns to keep context short)
    final recentHistory = history.length > 10
        ? history.sublist(history.length - 10)
        : history;

    final messages = [
      ...recentHistory.map((m) => {'role': m.role, 'content': m.content}),
      {'role': 'user', 'content': userMessage},
    ];

    yield* _modelService.generateStream(
      systemPrompt: systemPrompt,
      messages: messages,
    );
  }

  // ─── Speech-to-Text ──────────────────────────────────────────────────────

  Future<String> transcribeAudio(String audioPath) async {
    return _modelService.transcribeAudio(
      audioFilePath: audioPath,
      languageCode: 'hi', // TODO: use selected language from prefs
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  ChatMessage _rowToEntity(ChatMessageData row) => ChatMessage(
        id: row.id.toString(),
        sessionId: row.sessionId,
        role: row.role,
        content: row.content,
        urgencyLevel: row.urgencyLevel,
        reasoning: row.reasoning,
        createdAt: row.createdAt,
        isVoice: row.isVoice,
      );
}
