import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ii/view/BookingPageView.dart';
import 'package:project_ii/view/calendar_page_view.dart';
import 'package:project_ii/view/RoomPageView.dart';

abstract class HomePageEvent {}

class TabChangedEvent extends HomePageEvent {
  final int selectedIndex;
  final FocusNode? primaryFocus;
  TabChangedEvent(this.selectedIndex, this.primaryFocus);
}

class HomeState extends Equatable {
  final List<Widget Function(BuildContext)> builders;
  final int selectedIndex;
  static int calendar = 0, booking = 1, room = 2, service = 3, history = 4;
  static List<Widget Function(BuildContext)> builderCalls = [
    (context) => const CalendarPage(),
    (context) => const BookingPage(),
    (context) => const RoomPage(),
    (context) => const Text("service"),
    (context) => const Text("history")
  ];

  @override
  List<Object?> get props => [builders, selectedIndex];

  const HomeState({required this.selectedIndex, required this.builders});

  HomeState copyWith(
      {List<Widget Function(BuildContext)>? builders, int? selectedIndex}) {
    return HomeState(
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
          (context) => Container()
        ], selectedIndex: 0)) {
    on<TabChangedEvent>(
      (event, emit) {
        event.primaryFocus?.unfocus();
        var list = state.builders;
        list[event.selectedIndex] = HomeState.builderCalls[event.selectedIndex];
        emit(
            state.copyWith(builders: list, selectedIndex: event.selectedIndex));
      },
    );
  }

  @override
  void onTransition(Transition<HomePageEvent, HomeState> transition) {
    super.onTransition(transition);
    print("[HomePageBloc] $transition\n");
  }
}
