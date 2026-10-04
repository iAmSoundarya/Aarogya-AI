import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/services/model_service.dart';

abstract class HomeState extends Equatable {
  @override List<Object?> get props => [];
}
class HomeInitial extends HomeState {}
class HomeLoaded extends HomeState {
  HomeLoaded({required this.isModelLoaded});
  final bool isModelLoaded;
  @override List<Object?> get props => [isModelLoaded];
}

abstract class HomeEvent extends Equatable {
  @override List<Object?> get props => [];
}
class HomeStarted extends HomeEvent {}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required ModelService modelService})
      : _modelService = modelService,
        super(HomeInitial()) {
    on<HomeStarted>(_onStarted);
  }

  final ModelService _modelService;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(HomeLoaded(isModelLoaded: _modelService.isLoaded));
  }
}
