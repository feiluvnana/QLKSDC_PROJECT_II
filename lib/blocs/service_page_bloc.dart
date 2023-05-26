import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/enums/RenderState.dart';
import '../data/providers/Service_related_work_provider.dart';

abstract class ServicePageEvent {}

class RequireDataEvent extends ServicePageEvent {}

class AddServiceEvent extends ServicePageEvent {}

class ModifyServiceEvent extends ServicePageEvent {}

class DeleteServiceEvent extends ServicePageEvent {}

class CompleteRenderEvent extends ServicePageEvent {}

class ChooseRowEvent extends ServicePageEvent {
  int index;

  ChooseRowEvent(this.index);
}

class UnchooseRowEvent extends ServicePageEvent {
  int index;

  UnchooseRowEvent(this.index);
}

class ServiceState extends Equatable {
  final RenderState renderState;
  final Set<int> currentIndexes;

  const ServiceState({required this.renderState, required this.currentIndexes});

  ServiceState copyWith({RenderState? renderState, Set<int>? currentIndexes}) {
    return ServiceState(
        renderState: renderState ?? this.renderState,
        currentIndexes: currentIndexes ?? this.currentIndexes);
  }

  @override
  List<Object?> get props => [renderState, currentIndexes];
}

class ServicePageBloc extends Bloc<ServicePageEvent, ServiceState> {
  ServicePageBloc()
      : super(const ServiceState(
            renderState: RenderState.waiting, currentIndexes: <int>{})) {
    on<RequireDataEvent>((event, emit) async {
      await ServiceRelatedWorkProvider.getServicesList();
      emit(state.copyWith(renderState: RenderState.rendering));
    });
    on<CompleteRenderEvent>((event, emit) {
      emit(state.copyWith(renderState: RenderState.completed));
    });
    on<ChooseRowEvent>((event, emit) {
      Set<int> newIndexes = state.currentIndexes.toSet();
      newIndexes.add(event.index);
      emit(state.copyWith(currentIndexes: newIndexes));
    });
    on<UnchooseRowEvent>((event, emit) {
      Set<int> newIndexes = state.currentIndexes.toSet();
      newIndexes.remove(event.index);
      emit(state.copyWith(currentIndexes: newIndexes));
    });
    on<AddServiceEvent>((event, emit) {});
    on<ModifyServiceEvent>((event, emit) {});
    on<DeleteServiceEvent>((event, emit) {});
  }
}
