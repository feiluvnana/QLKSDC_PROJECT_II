import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../data/generators/excel_generator.dart';
import '../data/providers/calendar_related_work_provider.dart';
import '../data/providers/service_related_work_provider.dart';
import '../data/dependencies/internal_storage.dart';
import '../data/types/render_state.dart';

abstract class CalendarPageEvent {}

class IncreaseMonthEvent extends CalendarPageEvent {}

class DecreaseMonthEvent extends CalendarPageEvent {}

class ChangeGuestListDayEvent extends CalendarPageEvent {
  final int? dayForGuestList;

  ChangeGuestListDayEvent(this.dayForGuestList);
}

class CompleteRenderEvent extends CalendarPageEvent {}

class PrintGuestListEvent extends CalendarPageEvent {}

class RequireDataEvent extends CalendarPageEvent {}

class GotoInfoPageEvent extends CalendarPageEvent {
  final int oidx, ridx;
  final BuildContext context;

  GotoInfoPageEvent(this.oidx, this.ridx, this.context);
}

class RefreshEvent extends CalendarPageEvent {}

class CalendarState extends Equatable {
  final DateTime currentMonth, today;
  final int dayForGuestList;
  final RenderState state;

  const CalendarState(
      {required this.currentMonth,
      required this.today,
      required this.dayForGuestList,
      required this.state});

  CalendarState copyWith(
      {DateTime? currentMonth,
      DateTime? today,
      int? dayForGuestList,
      RenderState? state}) {
    return CalendarState(
        currentMonth: currentMonth ?? this.currentMonth,
        today: today ?? this.today,
        dayForGuestList: dayForGuestList ?? this.dayForGuestList,
        state: state ?? this.state);
  }

  @override
  List<Object?> get props => [currentMonth, dayForGuestList, state];
}

class CalendarPageBloc extends Bloc<CalendarPageEvent, CalendarState>
    with ExcelGenerator {
  CalendarPageBloc()
      : super(CalendarState(
            currentMonth: DateTime(DateTime.now().year, DateTime.now().month),
            today: DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day),
            dayForGuestList: DateTime.now().day,
            state: RenderState.waiting)) {
    GetIt.I<InternalStorage>().expose("roomGroupsList")?.listen((data) {
      if (data == null) add(RefreshEvent());
    });
    on<PrintGuestListEvent>((event, emit) async {
      await createGuestList(state.dayForGuestList, state.currentMonth.month,
          state.currentMonth.year);
    });
    on<IncreaseMonthEvent>((event, emit) {
      if (state.state != RenderState.completed) return;
      DateTime newMonth;
      if (state.currentMonth.month == 12) {
        newMonth = DateTime(state.currentMonth.year + 1, 1);
      } else {
        newMonth =
            DateTime(state.currentMonth.year, state.currentMonth.month + 1);
      }
      emit(state.copyWith(currentMonth: newMonth, state: RenderState.waiting));
    });
    on<DecreaseMonthEvent>((event, emit) {
      if (state.state != RenderState.completed) return;
      DateTime newMonth;
      if (state.currentMonth.month == 1) {
        newMonth = DateTime(state.currentMonth.year - 1, 12);
      } else {
        newMonth =
            DateTime(state.currentMonth.year, state.currentMonth.month - 1);
      }
      emit(state.copyWith(currentMonth: newMonth, state: RenderState.waiting));
    });
    on<ChangeGuestListDayEvent>((event, emit) {
      if (state.state != RenderState.completed) return;
      emit(state.copyWith(dayForGuestList: event.dayForGuestList));
    });
    on<CompleteRenderEvent>(
      (event, emit) => emit(state.copyWith(state: RenderState.completed)),
    );
    on<RequireDataEvent>((event, emit) async {
      await CalendarRelatedWorkProvider(
              currentMonth: state.currentMonth, today: state.today)
          .getRoomGroups();
      emit(state.copyWith(state: RenderState.rendering));
    });
    on<GotoInfoPageEvent>((event, emit) async {
      if (GetIt.I<InternalStorage>().read("servicesList") == null) {
        await ServiceRelatedWorkProvider.getServicesList();
      }
      // ignore: use_build_context_synchronously
      event.context.push("/info?ridx=${event.ridx}&oidx=${event.oidx}");
    });
    on<RefreshEvent>((event, emit) {
      emit(state.copyWith(state: RenderState.waiting));
    });
  }

  @override
  void onTransition(Transition<CalendarPageEvent, CalendarState> transition) {
    super.onTransition(transition);
  }
}
