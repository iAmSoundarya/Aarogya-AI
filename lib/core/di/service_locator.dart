import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/database/app_database.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/medicine_repository.dart';
import '../../features/home/bloc/home_bloc.dart';
import '../../features/symptom_chat/bloc/chat_bloc.dart';
import '../../features/medicine_reminder/bloc/reminder_bloc.dart';
import '../../features/emergency/bloc/emergency_bloc.dart';
import '../../shared/services/model_service.dart';
import '../../shared/services/audio_service.dart';
import '../../shared/services/tts_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Database
  sl.registerSingleton<AppDatabase>(AppDatabase());

  // Services (singletons — expensive to create)
  sl.registerSingletonAsync<ModelService>(() async {
    final service = ModelService(prefs: sl());
    await service.initialize();
    return service;
  });

  sl.registerSingleton<AudioService>(AudioService());
  sl.registerSingleton<TtsService>(TtsService());

  // Repositories
  sl.registerLazySingleton<ChatRepository>(
        () => ChatRepository(db: sl(), modelService: sl()),
  );
  sl.registerLazySingleton<MedicineRepository>(
        () => MedicineRepository(db: sl()),
  );

  // BLoCs (factories — new instance per use)
  sl.registerFactory(() => HomeBloc(modelService: sl()));
  sl.registerFactory(() => ChatBloc(
    chatRepository: sl(),
    audioService: sl(),
    ttsService: sl(),
    prefs: sl(),          // ← ADDED
  ));
  sl.registerFactory(() => ReminderBloc(medicineRepository: sl()));
  sl.registerFactory(() => EmergencyBloc(ttsService: sl()));

  await sl.allReady();
}