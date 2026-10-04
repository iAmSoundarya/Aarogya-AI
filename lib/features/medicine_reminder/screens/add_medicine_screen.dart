import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/medicine.dart';
import '../screens/reminder_screen.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});
  @override State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _nameHindiCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  String _frequency = 'daily';
  List<TimeOfDay> _times = [const TimeOfDay(hour: 8, minute: 0)];
  int? _durationDays;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameHindiCtrl.dispose();
    _dosageCtrl.dispose();
    super.dispose();
  }

  void _onFrequencyChanged(String? value) {
    if (value == null) return;
    setState(() {
      _frequency = value;
      _times = switch (value) {
        'twice_daily' => [
            const TimeOfDay(hour: 8, minute: 0),
            const TimeOfDay(hour: 20, minute: 0),
          ],
        'thrice_daily' => [
            const TimeOfDay(hour: 8, minute: 0),
            const TimeOfDay(hour: 14, minute: 0),
            const TimeOfDay(hour: 20, minute: 0),
          ],
        _ => [const TimeOfDay(hour: 8, minute: 0)],
      };
    });
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _times[index],
    );
    if (picked != null) {
      setState(() => _times[index] = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final medicine = Medicine(
      id: 0, // DB assigns
      name: _nameCtrl.text.trim(),
      nameHindi: _nameHindiCtrl.text.trim().isEmpty
          ? null
          : _nameHindiCtrl.text.trim(),
      dosage: _dosageCtrl.text.trim(),
      frequency: _frequency,
      times: _times
          .map((t) =>
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
          .toList(),
      durationDays: _durationDays,
      startDate: DateTime.now(),
      createdAt: DateTime.now(),
    );
    context.read<ReminderBloc>().add(ReminderMedicineAdded(medicine));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medicine')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Medicine name *',
                prefixIcon: Icon(Icons.medication_rounded),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameHindiCtrl,
              decoration: const InputDecoration(
                labelText: 'Hindi name (optional)',
                prefixIcon: Icon(Icons.translate),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dosageCtrl,
              decoration: const InputDecoration(
                labelText: 'Dosage (e.g. 500mg, 1 tablet) *',
                prefixIcon: Icon(Icons.straighten),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            const Text('Frequency',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'daily', label: Text('Once')),
                ButtonSegment(value: 'twice_daily', label: Text('Twice')),
                ButtonSegment(value: 'thrice_daily', label: Text('3×')),
              ],
              selected: {_frequency},
              onSelectionChanged: (s) => _onFrequencyChanged(s.first),
            ),
            const SizedBox(height: 20),
            const Text('Reminder times',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            ..._times.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200)),
                  tileColor: AppTheme.surfaceLight,
                  leading: const Icon(Icons.access_time,
                      color: AppTheme.primaryGreen),
                  title: Text(
                    '${entry.value.hour.toString().padLeft(2, '0')}:${entry.value.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Text('Dose ${entry.key + 1}'),
                  trailing: const Icon(Icons.edit_outlined, size: 18),
                  onTap: () => _pickTime(entry.key),
                ),
              );
            }),
            const SizedBox(height: 20),
            const Text('Duration (optional)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [7, 14, 30, 60, 90].map((days) {
                return ChoiceChip(
                  label: Text('$days days'),
                  selected: _durationDays == days,
                  onSelected: (sel) =>
                      setState(() => _durationDays = sel ? days : null),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.alarm_add_rounded),
              label: const Text('Save & Set Reminder',
                  style: TextStyle(fontSize: 16)),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
