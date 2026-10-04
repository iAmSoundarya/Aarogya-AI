import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/onboarding_screen.dart';
import '../../features/symptom_chat/screens/chat_screen.dart';
import '../../features/emergency/screens/emergency_screen.dart';
import '../../features/emergency/screens/emergency_detail_screen.dart';
import '../../features/medicine_reminder/screens/reminder_screen.dart';
import '../../features/medicine_reminder/screens/add_medicine_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../shared/screens/model_download_screen.dart';
import '../../shared/screens/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.modelDownload,
        builder: (_, __) => const ModelDownloadScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomeTabView(),
          ),
          GoRoute(
            path: AppRoutes.chat,
            builder: (_, __) => const ChatScreen(),
          ),
          GoRoute(
            path: AppRoutes.emergency,
            builder: (_, __) => const EmergencyScreen(),
          ),
          GoRoute(
            path: '${AppRoutes.emergency}/:type',
            builder: (_, state) => EmergencyDetailScreen(
              emergencyType: state.pathParameters['type']!,
            ),
          ),
          GoRoute(
            path: AppRoutes.reminders,
            builder: (_, __) => const ReminderScreen(),
          ),
          GoRoute(
            path: AppRoutes.addMedicine,
            builder: (_, __) => const AddMedicineScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String modelDownload = '/model-download';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String emergency = '/emergency';
  static const String reminders = '/reminders';
  static const String addMedicine = '/reminders/add';
  static const String settings = '/settings';
}
