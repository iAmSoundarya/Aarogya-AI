import 'package:drift/drift.dart';

// ─── Chat Messages ──────────────────────────────────────────────────────────
@DataClassName('ChatMessageData')
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text()();
  TextColumn get role => text()(); // 'user' | 'assistant'
  TextColumn get content => text()();
  IntColumn get urgencyLevel => integer().nullable()(); // 1-4, only for assistant
  TextColumn get reasoning => text().nullable()(); // explainable AI reasoning
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isVoice => boolean().withDefault(const Constant(false))();
}

// ─── Medicines ───────────────────────────────────────────────────────────────
@DataClassName('MedicineData')
class Medicines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get nameHindi => text().nullable()(); // localised name
  TextColumn get dosage => text()(); // e.g. "500mg"
  TextColumn get frequency => text()(); // 'daily' | 'twice_daily' | 'custom'
  TextColumn get times => text()(); // JSON array of TimeOfDay strings
  IntColumn get durationDays => integer().nullable()(); // null = ongoing
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ─── Dose Logs ───────────────────────────────────────────────────────────────
class DoseLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicineId => integer().references(Medicines, #id)();
  DateTimeColumn get scheduledAt => dateTime()();
  DateTimeColumn get takenAt => dateTime().nullable()();
  BoolColumn get taken => boolean().withDefault(const Constant(false))();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();
}
