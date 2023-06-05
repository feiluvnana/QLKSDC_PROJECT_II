import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../data/dependencies/internal_storage.dart';
import '../data/types/render_state.dart';
import '../data/providers/history_related_work_provider.dart';

abstract class HistoryPageEvent {}

class RequireDataEvent extends HistoryPageEvent {}

class CompleteRenderEvent extends HistoryPageEvent {}

class RefreshEvent extends HistoryPageEvent {}

class HistoryState extends Equatable {
  final RenderState renderState;

  const HistoryState({required this.renderState});

  HistoryState copyWith({RenderState? renderState, Set<int>? currentIndexes}) {
    return HistoryState(renderState: renderState ?? this.renderState);
  }

  @override
  List<Object?> get props => [renderState];
}

class HistoryPageBloc extends Bloc<HistoryPageEvent, HistoryState> {
  HistoryPageBloc()
      : super(const HistoryState(renderState: RenderState.waiting)) {
    GetIt.I<InternalStorage>().expose("historiesList")?.listen((data) {
      if (data == null) add(RefreshEvent());
    });
    on<RefreshEvent>((event, emit) {
      emit(state.copyWith(renderState: RenderState.waiting));
    });
    on<RequireDataEvent>((event, emit) async {
      await HistoryRelatedWorkProvider.getHistoriesList();
      emit(state.copyWith(renderState: RenderState.rendering));
    });
    on<CompleteRenderEvent>((event, emit) {
      emit(state.copyWith(renderState: RenderState.completed));
    });
  }
}
