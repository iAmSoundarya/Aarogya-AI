import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/tts_service.dart';
import '../../../core/di/service_locator.dart';

// ─── Emergency List Screen ────────────────────────────────────────────────────

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  static const _emergencies = [
    _EmergencyItem('choking', '🫁', 'Choking', 'दम घुटना', Colors.red),
    _EmergencyItem('burns', '🔥', 'Burns', 'जलना', Colors.orange),
    _EmergencyItem('dehydration', '💧', 'Dehydration', 'निर्जलीकरण', Colors.blue),
    _EmergencyItem('heatstroke', '☀️', 'Heatstroke', 'लू लगना', Colors.amber),
    _EmergencyItem('snakebite', '🐍', 'Snake Bite', 'सांप का काटना', Colors.green),
    _EmergencyItem('bleeding', '🩸', 'Bleeding', 'खून बहना', Colors.red),
    _EmergencyItem('cardiac', '❤️', 'Cardiac', 'हृदय आघात', Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency First-Aid'),
        backgroundColor: Colors.red.shade700,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: Row(children: [
              Icon(Icons.offline_bolt, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'All first-aid guides work fully offline',
                  style: TextStyle(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _emergencies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final e = _emergencies[i];
                return _EmergencyCard(item: e);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyItem {
  const _EmergencyItem(
      this.type, this.emoji, this.label, this.labelHindi, this.color);
  final String type;
  final String emoji;
  final String label;
  final String labelHindi;
  final Color color;
}

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard({required this.item});
  final _EmergencyItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmergencyDetailScreen(emergencyType: item.type),
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: item.color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(item.labelHindi,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: item.color),
          ],
        ),
      ),
    );
  }
}

// ─── Emergency Detail Screen ─────────────────────────────────────────────────

class EmergencyDetailScreen extends StatefulWidget {
  const EmergencyDetailScreen({super.key, required this.emergencyType});
  final String emergencyType;

  @override
  State<EmergencyDetailScreen> createState() => _EmergencyDetailScreenState();
}

class _EmergencyDetailScreenState extends State<EmergencyDetailScreen> {
  Map<String, dynamic>? _playbook;
  int _currentStep = 0;
  bool _isSpeaking = false;
  final _tts = sl<TtsService>();

  @override
  void initState() {
    super.initState();
    _loadPlaybook();
  }

  Future<void> _loadPlaybook() async {
    final json = await rootBundle.loadString(
      '${AppConstants.firstAidBasePath}${widget.emergencyType}.json',
    );
    setState(() => _playbook = jsonDecode(json));
  }

  Future<void> _speakStep(String text) async {
    setState(() => _isSpeaking = true);
    await _tts.speak(text);
    setState(() => _isSpeaking = false);
  }

  Future<void> _speakAll() async {
    if (_playbook == null) return;
    final steps = List<Map<String, dynamic>>.from(_playbook!['steps']);
    setState(() => _isSpeaking = true);
    for (final step in steps) {
      await _tts.speak(step['instruction']);
    }
    setState(() => _isSpeaking = false);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_playbook == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final steps = List<Map<String, dynamic>>.from(_playbook!['steps']);
    final title = _playbook!['title'] as String;
    final warning = _playbook!['warning'] as String?;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(_isSpeaking ? Icons.stop_circle : Icons.volume_up_rounded),
            tooltip: _isSpeaking ? 'Stop' : 'Read aloud',
            onPressed: _isSpeaking ? _tts.stop : _speakAll,
          ),
        ],
      ),
      body: Column(
        children: [
          // Warning banner
          if (warning != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              color: Colors.amber.shade100,
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(warning,
                      style: TextStyle(
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w500,
                          fontSize: 13)),
                ),
              ]),
            ),

          // Steps
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: steps.length,
              itemBuilder: (context, i) {
                final step = steps[i];
                final isActive = i == _currentStep;
                return GestureDetector(
                  onTap: () {
                    setState(() => _currentStep = i);
                    _speakStep(step['instruction']);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.red.shade50
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isActive
                            ? Colors.red.shade400
                            : Colors.grey.shade200,
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? Colors.red.shade700
                                : Colors.grey.shade200,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['instruction'],
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                              if (step['hint'] != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  step['hint'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isActive)
                          Icon(Icons.volume_up_rounded,
                              color: Colors.red.shade400, size: 18),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _currentStep > 0
                      ? () => setState(() => _currentStep--)
                      : null,
                  child: const Text('← Previous'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade700),
                  onPressed: _currentStep < steps.length - 1
                      ? () => setState(() => _currentStep++)
                      : null,
                  child: const Text('Next →'),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
