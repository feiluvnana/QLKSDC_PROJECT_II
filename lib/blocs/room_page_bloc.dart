import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/enums/RenderState.dart';
import '../data/providers/room_related_work_provider.dart';

abstract class RoomPageEvent {}

class RequireDataEvent extends RoomPageEvent {}

class AddRoomEvent extends RoomPageEvent {}

class ModifyRoomEvent extends RoomPageEvent {}

class DeleteRoomEvent extends RoomPageEvent {}

class CompleteRenderEvent extends RoomPageEvent {}

class ChooseRowEvent extends RoomPageEvent {
  int index;

  ChooseRowEvent(this.index);
}

class UnchooseRowEvent extends RoomPageEvent {
  int index;

  UnchooseRowEvent(this.index);
}

class RoomState extends Equatable {
  final RenderState renderState;
  final Set<int> currentIndexes;

  const RoomState({required this.renderState, required this.currentIndexes});

  RoomState copyWith({RenderState? renderState, Set<int>? currentIndexes}) {
    return RoomState(
        renderState: renderState ?? this.renderState,
        currentIndexes: currentIndexes ?? this.currentIndexes);
  }

  @override
  List<Object?> get props => [renderState, currentIndexes];
}

class RoomPageBloc extends Bloc<RoomPageEvent, RoomState> {
  RoomPageBloc()
      : super(const RoomState(
            renderState: RenderState.waiting, currentIndexes: <int>{})) {
    on<RequireDataEvent>((event, emit) async {
      await RoomRelatedWorkProvider.getRoomsList();
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
    on<AddRoomEvent>((event, emit) {});
    on<ModifyRoomEvent>((event, emit) {});
    on<DeleteRoomEvent>((event, emit) {});
  }
}
