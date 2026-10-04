import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/chat_message_table.dart';

part 'chat_dao.g.dart';

@DriftAccessor(tables: [ChatMessages])
class ChatDao extends DatabaseAccessor<AppDatabase> with _$ChatDaoMixin {
  ChatDao(super.db);

  Future<List<ChatMessageData>> getBySession(String sessionId) =>
      (select(chatMessages)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<List<ChatMessageData>> getRecentSessions({int limit = 5}) =>
      (select(chatMessages)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit * 20))
          .get();

  Future<int> insertMessage(ChatMessagesCompanion message) =>
      into(chatMessages).insert(message);

  Future<void> deleteSession(String sessionId) =>
      (delete(chatMessages)..where((t) => t.sessionId.equals(sessionId))).go();

  Future<void> deleteAll() => delete(chatMessages).go();
}
