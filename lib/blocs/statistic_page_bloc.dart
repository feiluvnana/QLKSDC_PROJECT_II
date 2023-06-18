import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../data/dependencies/internal_storage.dart';
import '../data/providers/service_related_work_provider.dart';
import '../data/providers/statistic_related_work_provider.dart';
import '../data/types/render_state.dart';

abstract class StatisticPageEvent {}

class RequireDataEvent extends StatisticPageEvent {}

class CompleteRenderEvent extends StatisticPageEvent {}

class RefreshEvent extends StatisticPageEvent {}

class StatisticState extends Equatable {
  final RenderState renderState;

  const StatisticState({required this.renderState});

  StatisticState copyWith(
      {RenderState? renderState, Set<int>? currentIndexes}) {
    return StatisticState(renderState: renderState ?? this.renderState);
  }

  @override
  List<Object?> get props => [renderState];
}

class StatisticPageBloc extends Bloc<StatisticPageEvent, StatisticState> {
  StatisticPageBloc()
      : super(const StatisticState(renderState: RenderState.waiting)) {
    GetIt.I<InternalStorage>().expose("statistic")?.listen((data) {
      if (data == null) add(RefreshEvent());
    });
    GetIt.I<InternalStorage>().expose("servicesList")?.listen((data) {
      if (data == null) add(RefreshEvent());
    });
    GetIt.I<InternalStorage>().expose("roomGroupsList")?.listen((data) {
      if (data == null) add(RefreshEvent());
    });
    on<RefreshEvent>((event, emit) {
      emit(state.copyWith(renderState: RenderState.waiting));
    });
    on<RequireDataEvent>((event, emit) async {
      await StatisticRelatedWorkProvider.getStatistic();
      await ServiceRelatedWorkProvider.getServicesList();
      emit(state.copyWith(renderState: RenderState.rendering));
    });
    on<CompleteRenderEvent>((event, emit) {
      emit(state.copyWith(renderState: RenderState.completed));
    });
  }
}
