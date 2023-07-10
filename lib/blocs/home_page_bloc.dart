import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:project_ii/data/providers/login_related_work_provider.dart';
import 'package:project_ii/views/booking_page_view.dart';
import 'package:project_ii/views/history_page_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/walkin_page_view.dart';
import '../views/calendar_page_view.dart';
import '../views/room_page_view.dart';
import '../views/service_page_view.dart';
import '../views/statistic_page_view.dart';

abstract class HomePageEvent {}

class ChangeTabEvent extends HomePageEvent {
  final int selectedIndex;
  final FocusNode? primaryFocus;
  ChangeTabEvent(this.selectedIndex, this.primaryFocus);
}

class LogoutEvent extends HomePageEvent {
  final BuildContext context;
  LogoutEvent(this.context);
}

class RequireDataEvent extends HomePageEvent {}

class HomeState extends Equatable {
  final List<Widget Function(BuildContext)> builders;
  final int selectedIndex;
  final String infoString;
  static List<Widget Function(BuildContext)> builderCalls = [
    (context) => const CalendarPage(),
    (context) => const WalkinPage(),
    (context) => const BookingPage(),
    (context) => const RoomPage(),
    (context) => const ServicePage(),
    (context) => const StatisticPage(),
    (context) => const HistoryPage(),
  ];

  @override
  List<Object?> get props => [builders, selectedIndex];

  const HomeState(
      {required this.selectedIndex,
      required this.builders,
      required this.infoString});

  HomeState copyWith(
      {List<Widget Function(BuildContext)>? builders,
      int? selectedIndex,
      String? infoString}) {
    return HomeState(
        infoString: infoString ?? this.infoString,
        builders: builders ?? this.builders,
        selectedIndex: selectedIndex ?? this.selectedIndex);
  }
}

class HomePageBloc extends Bloc<HomePageEvent, HomeState> {
  HomePageBloc()
      : super(HomeState(builders: [
          (context) => const CalendarPage(),
          (context) => Container(),
          (context) => Container(),
          (context) => Container(),
          (context) => Container(),
          (context) => Container(),
          (context) => Container()
        ], selectedIndex: 0, infoString: "")) {
    on<RequireDataEvent>((event, emit) async {
      emit(state.copyWith(
          infoString:
              "Tên: ${(await SharedPreferences.getInstance()).getString("name")}\nQuyền hạn: ${(await SharedPreferences.getInstance()).getString("role") == "ADMIN" ? "Quản lý" : "Lễ tân"}"));
    });
    on<ChangeTabEvent>(
      (event, emit) {
        event.primaryFocus?.unfocus();
        var list = state.builders;
        list[event.selectedIndex] = HomeState.builderCalls[event.selectedIndex];
        emit(
            state.copyWith(builders: list, selectedIndex: event.selectedIndex));
      },
    );
    on<LogoutEvent>((event, emit) async {
      await LoginRelatedWorkProvider.logout();
      await (await SharedPreferences.getInstance()).clear();
      // ignore: use_build_context_synchronously
      event.context.go("/login");
    });
  }

  @override
  void onTransition(Transition<HomePageEvent, HomeState> transition) {
    super.onTransition(transition);
  }
}
