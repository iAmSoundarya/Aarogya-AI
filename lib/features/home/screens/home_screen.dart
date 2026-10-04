import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/home_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    AppRoutes.home,
    AppRoutes.chat,
    AppRoutes.emergency,
    AppRoutes.reminders,
    AppRoutes.settings,
  ];

  int _indexFromLocation(String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => context.go(_tabs[i]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Symptoms',
          ),
          NavigationDestination(
            icon: Icon(Icons.emergency_outlined),
            selectedIcon: Icon(Icons.emergency_rounded),
            label: 'Emergency',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication_rounded),
            label: 'Medicines',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ─── Home Tab View ────────────────────────────────────────────────────────────

class HomeTabView extends StatelessWidget {
  const HomeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('AarogyaAI'),
            actions: [
              if (state is HomeLoaded)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Chip(
                    avatar: Icon(
                      state.isModelLoaded
                          ? Icons.circle
                          : Icons.circle_outlined,
                      size: 10,
                      color: state.isModelLoaded
                          ? Colors.greenAccent
                          : Colors.orange,
                    ),
                    label: Text(
                      state.isModelLoaded ? 'AI Ready' : 'Loading AI...',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white),
                    ),
                    backgroundColor: Colors.white.withOpacity(0.2),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GreetingCard(),
                const SizedBox(height: 20),
                const Text('Quick Actions',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _QuickActionsGrid(),
                const SizedBox(height: 24),
                const Text('Emergencies',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _EmergencyQuickList(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GreetingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.primaryGreenMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.health_and_safety_rounded,
                color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              _greeting(),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ]),
          const SizedBox(height: 8),
          const Text(
            'How can I help\nyou today?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          const Row(children: [
            _Pill('🌐 Offline'),
            SizedBox(width: 8),
            _Pill('🗣️ Hindi'),
            SizedBox(width: 8),
            _Pill('🔒 Private'),
          ]),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      );
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action('Symptom Check', Icons.search_rounded,
          AppTheme.primaryGreen, AppRoutes.chat),
      _Action('Emergency Aid', Icons.emergency_rounded,
          Colors.red.shade700, AppRoutes.emergency),
      _Action('Medicines', Icons.medication_rounded,
          Colors.blue.shade700, AppRoutes.reminders),
      _Action('Settings', Icons.settings_rounded,
          Colors.grey.shade700, AppRoutes.settings),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: actions
          .map((a) => _ActionCard(action: a))
          .toList(),
    );
  }
}

class _Action {
  const _Action(this.label, this.icon, this.color, this.route);
  final String label;
  final IconData icon;
  final Color color;
  final String route;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});
  final _Action action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(action.route),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: action.color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(action.icon, color: action.color, size: 28),
            Text(action.label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: action.color)),
          ],
        ),
      ),
    );
  }
}

class _EmergencyQuickList extends StatelessWidget {
  static const _emergencies = [
    ('🐍', 'Snake Bite', 'snakebite'),
    ('🔥', 'Burns', 'burns'),
    ('💧', 'Dehydration', 'dehydration'),
    ('🫁', 'Choking', 'choking'),
    ('❤️', 'Cardiac', 'cardiac'),
    ('🩸', 'Bleeding', 'bleeding'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.3,
      ),
      itemCount: _emergencies.length,
      itemBuilder: (context, i) {
        final (emoji, label, type) = _emergencies[i];
        return InkWell(
          onTap: () => context.go('${AppRoutes.emergency}/$type'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade800)),
              ],
            ),
          ),
        );
      },
    );
  }
}
