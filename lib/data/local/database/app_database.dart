import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../dao/chat_dao.dart';
import '../dao/medicine_dao.dart';
import '../models/chat_message_table.dart';
import '../models/medicine_table.dart';
import '../models/dose_log_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [ChatMessages, Medicines, DoseLogs],
  daos: [ChatDao, MedicineDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Future migrations go here
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'aarogya_db');
  }
}
