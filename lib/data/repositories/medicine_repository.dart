import 'dart:convert';
import 'package:drift/drift.dart';

import '../../domain/entities/medicine.dart';
import '../local/database/app_database.dart';
import '../local/models/chat_message_table.dart';

class MedicineRepository {
  MedicineRepository({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  Stream<List<Medicine>> watchActiveMedicines() =>
      _db.medicineDao.watchAllActive().map(
            (rows) => rows.map(_rowToEntity).toList(),
          );

  Future<List<Medicine>> getActiveMedicines() async {
    final rows = await _db.medicineDao.getAllActive();
    return rows.map(_rowToEntity).toList();
  }

  Future<int> addMedicine(Medicine medicine) =>
      _db.medicineDao.insertMedicine(MedicinesCompanion.insert(
        name: medicine.name,
        nameHindi: Value(medicine.nameHindi),
        dosage: medicine.dosage,
        frequency: medicine.frequency,
        times: jsonEncode(medicine.times),
        durationDays: Value(medicine.durationDays),
        startDate: medicine.startDate,
        endDate: Value(medicine.endDate),
        notes: Value(medicine.notes),
      ));

  Future<void> deactivateMedicine(int id) =>
      _db.medicineDao.deactivateMedicine(id);

  Future<void> markDoseTaken(int logId) =>
      _db.medicineDao.markTaken(logId);

  Future<void> markDoseSkipped(int logId) =>
      _db.medicineDao.markSkipped(logId);

  Medicine _rowToEntity(MedicineData row) => Medicine(
        id: row.id,
        name: row.name,
        nameHindi: row.nameHindi,
        dosage: row.dosage,
        frequency: row.frequency,
        times: List<String>.from(jsonDecode(row.times)),
        durationDays: row.durationDays,
        startDate: row.startDate,
        endDate: row.endDate,
        isActive: row.isActive,
        notes: row.notes,
        createdAt: row.createdAt,
      );
}
