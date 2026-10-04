import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/services/tts_service.dart';

abstract class EmergencyState extends Equatable {
  @override List<Object?> get props => [];
}
class EmergencyIdle extends EmergencyState {}
abstract class EmergencyEvent extends Equatable {
  @override List<Object?> get props => [];
}
class EmergencyStarted extends EmergencyEvent {}
class EmergencyBloc extends Bloc<EmergencyEvent, EmergencyState> {
  EmergencyBloc({required TtsService ttsService})
      : _tts = ttsService, super(EmergencyIdle()) {
    on<EmergencyStarted>((_, emit) => emit(EmergencyIdle()));
  }
  final TtsService _tts;
}
