import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' hide Transition;
import 'package:go_router/go_router.dart';
import 'package:project_ii/data/providers/backend_data_provider.dart';
import 'package:project_ii/data/providers/service_data_provider.dart';
import 'package:project_ii/utils/InternalStorage.dart';
import '../data/enums/RenderState.dart';

abstract class CalendarPageEvent {}

class MonthIncreasedEvent extends CalendarPageEvent {}

class MonthDecreasedEvent extends CalendarPageEvent {}

class GuestListDayChangedEvent extends CalendarPageEvent {
  final int? dayForGuestList;

  GuestListDayChangedEvent(this.dayForGuestList);
}

class RenderCompletedEvent extends CalendarPageEvent {}

class DataNeededEvent extends CalendarPageEvent {}

class GotoInformationPageEvent extends CalendarPageEvent {
  final int oidx, ridx;
  final BuildContext context;

  GotoInformationPageEvent(this.oidx, this.ridx, this.context);
}

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

class CalendarPageBloc extends Bloc<CalendarPageEvent, CalendarState> {
  CalendarPageBloc()
      : super(CalendarState(
            currentMonth: DateTime(DateTime.now().year, DateTime.now().month),
            today: DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day),
            dayForGuestList: DateTime.now().day,
            state: RenderState.waiting)) {
    on<MonthIncreasedEvent>((event, emit) {
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
    on<MonthDecreasedEvent>((event, emit) {
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
    on<GuestListDayChangedEvent>((event, emit) {
      if (state.state != RenderState.completed) return;
      emit(state.copyWith(dayForGuestList: event.dayForGuestList));
    });
    on<RenderCompletedEvent>(
      (event, emit) => emit(state.copyWith(state: RenderState.completed)),
    );
    on<DataNeededEvent>((event, emit) async {
      await BackendDataProvider(
              currentMonth: state.currentMonth, today: state.today)
          .getRoomGroups();
      emit(state.copyWith(state: RenderState.rendering));
    });
    on<GotoInformationPageEvent>((event, emit) async {
      print("fired");
      if (Get.find<InternalStorage>().read("servicesList") == null) {
        await ServiceDataProvider.getServices();
      }
      event.context.go("/info?rid=${event.ridx}&oid=${event.oidx}");
    });
  }

  @override
  void onTransition(Transition<CalendarPageEvent, CalendarState> transition) {
    super.onTransition(transition);
    print("[CalendarPageBlock] $transition");
  }
}
