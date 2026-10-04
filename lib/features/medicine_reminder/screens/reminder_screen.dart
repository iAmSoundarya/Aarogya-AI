import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/medicine_repository.dart';
import '../../../domain/entities/medicine.dart';
import '../../../shared/services/notification_service.dart';

// ─── BLoC ────────────────────────────────────────────────────────────────────

abstract class ReminderEvent extends Equatable {
  @override List<Object?> get props => [];
}
class ReminderStarted extends ReminderEvent {}
class ReminderMedicineAdded extends ReminderEvent {
  ReminderMedicineAdded(this.medicine);
  final Medicine medicine;
  @override List<Object?> get props => [medicine];
}
class ReminderMedicineDeleted extends ReminderEvent {
  ReminderMedicineDeleted(this.id);
  final int id;
  @override List<Object?> get props => [id];
}

abstract class ReminderState extends Equatable {
  @override List<Object?> get props => [];
}
class ReminderInitial extends ReminderState {}
class ReminderLoaded extends ReminderState {
  ReminderLoaded(this.medicines);
  final List<Medicine> medicines;
  @override List<Object?> get props => [medicines];
}

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  ReminderBloc({required MedicineRepository medicineRepository})
      : _repo = medicineRepository,
        super(ReminderInitial()) {
    on<ReminderStarted>(_onStarted);
    on<ReminderMedicineAdded>(_onAdded);
    on<ReminderMedicineDeleted>(_onDeleted);
  }
  final MedicineRepository _repo;

  Future<void> _onStarted(ReminderStarted _, Emitter<ReminderState> emit) async {
    final medicines = await _repo.getActiveMedicines();
    emit(ReminderLoaded(medicines));
  }

  Future<void> _onAdded(ReminderMedicineAdded event, Emitter<ReminderState> emit) async {
    final id = await _repo.addMedicine(event.medicine);
    // Schedule notifications for each time
    for (int i = 0; i < event.medicine.times.length; i++) {
      final parts = event.medicine.times[i].split(':');
      await NotificationService.instance.scheduleMedicineReminder(
        notificationId: id * 10 + i,
        medicineName: event.medicine.displayName,
        dosage: event.medicine.dosage,
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    final medicines = await _repo.getActiveMedicines();
    emit(ReminderLoaded(medicines));
  }

  Future<void> _onDeleted(ReminderMedicineDeleted event, Emitter<ReminderState> emit) async {
    await _repo.deactivateMedicine(event.id);
    final medicines = await _repo.getActiveMedicines();
    emit(ReminderLoaded(medicines));
  }
}

// ─── Reminder Screen ─────────────────────────────────────────────────────────

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});
  @override State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReminderBloc>().add(ReminderStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Reminders')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
        onPressed: () => context.push(AppRoutes.addMedicine),
      ),
      body: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          if (state is ReminderInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReminderLoaded) {
            if (state.medicines.isEmpty) {
              return _EmptyReminders(
                onAdd: () => context.push(AppRoutes.addMedicine),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: state.medicines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _MedicineCard(
                medicine: state.medicines[i],
                onDelete: (id) =>
                    context.read<ReminderBloc>().add(ReminderMedicineDeleted(id)),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({required this.medicine, required this.onDelete});
  final Medicine medicine;
  final void Function(int) onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.medication_rounded,
              color: AppTheme.primaryGreen, size: 22),
        ),
        title: Text(medicine.displayName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${medicine.dosage} · ${medicine.times.join(", ")}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Remove medicine?'),
              content: Text('Stop reminders for ${medicine.name}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete(medicine.id);
                  },
                  child: const Text('Remove',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyReminders extends StatelessWidget {
  const _EmptyReminders({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.medication_outlined,
              size: 64, color: AppTheme.primaryGreen),
          const SizedBox(height: 16),
          const Text('No medicines added',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Add medicines to get daily reminders',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add Medicine'),
          ),
        ],
      ),
    );
  }
}
