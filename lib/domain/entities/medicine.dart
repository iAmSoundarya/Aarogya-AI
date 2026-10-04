import 'package:equatable/equatable.dart';

class Medicine extends Equatable {
  const Medicine({
    required this.id,
    required this.name,
    this.nameHindi,
    required this.dosage,
    required this.frequency,
    required this.times,
    this.durationDays,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.notes,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String? nameHindi;
  final String dosage;
  final String frequency; // 'daily' | 'twice_daily' | 'thrice_daily' | 'custom'
  final List<String> times; // ["08:00", "20:00"]
  final int? durationDays;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;

  String get displayName => nameHindi ?? name;

  bool get isCompleted =>
      endDate != null && DateTime.now().isAfter(endDate!);

  @override
  List<Object?> get props => [id, name, dosage, frequency, times, isActive];
}
