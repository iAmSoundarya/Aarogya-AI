import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/chat_message_table.dart';

part 'medicine_dao.g.dart';

@DriftAccessor(tables: [Medicines, DoseLogs])
class MedicineDao extends DatabaseAccessor<AppDatabase>
    with _$MedicineDaoMixin {
  MedicineDao(super.db);

  // ─── Medicines ──────────────────────────────────────────────────────────

  Future<List<MedicineData>> getAllActive() =>
      (select(medicines)..where((t) => t.isActive.equals(true))).get();

  Stream<List<MedicineData>> watchAllActive() =>
      (select(medicines)..where((t) => t.isActive.equals(true))).watch();

  Future<MedicineData?> getById(int id) =>
      (select(medicines)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertMedicine(MedicinesCompanion medicine) =>
      into(medicines).insert(medicine);

  Future<bool> updateMedicine(MedicinesCompanion medicine) =>
      update(medicines).replace(medicine);

  Future<int> deactivateMedicine(int id) => (update(medicines)
        ..where((t) => t.id.equals(id)))
      .write(const MedicinesCompanion(isActive: Value(false)));

  // ─── Dose Logs ──────────────────────────────────────────────────────────

  Future<List<DoseLog>> getLogsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(doseLogs)
          ..where((t) =>
              t.scheduledAt.isBiggerOrEqualValue(start) &
              t.scheduledAt.isSmallerThanValue(end)))
        .get();
  }

  Stream<List<DoseLog>> watchTodayLogs() {
    final now = DateTime.now();
    return getLogsForDate(now).asStream();
  }

  Future<int> insertLog(DoseLogsCompanion log) =>
      into(doseLogs).insert(log);

  Future<int> markTaken(int logId) => (update(doseLogs)
        ..where((t) => t.id.equals(logId)))
      .write(DoseLogsCompanion(
        taken: const Value(true),
        takenAt: Value(DateTime.now()),
      ));

  Future<int> markSkipped(int logId) => (update(doseLogs)
        ..where((t) => t.id.equals(logId)))
      .write(const DoseLogsCompanion(skipped: Value(true)));
}
