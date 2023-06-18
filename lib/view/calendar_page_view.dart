import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../blocs/calendar_page_bloc.dart';
import '../data/dependencies/internal_storage.dart';
import '../data/types/pair.dart';
import '../data/types/render_state.dart';
import '../model/room_group_model.dart';
import '../data/generators/excel_generator.dart';

class CalendarPage extends StatelessWidget with ExcelGenerator {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CalendarPageBloc(),
      child: Builder(builder: (context) {
        return Container(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                          child: const Icon(Icons.keyboard_arrow_left),
                          onTap: () => context
                              .read<CalendarPageBloc>()
                              .add(DecreaseMonthEvent())),
                      BlocBuilder<CalendarPageBloc, CalendarState>(
                        buildWhen: (previous, current) =>
                            previous.currentMonth != current.currentMonth,
                        builder: (context, state) => Text(
                            DateFormat("MM/yyyy").format(state.currentMonth)),
                      ),
                      GestureDetector(
                        child: const Icon(Icons.keyboard_arrow_right),
                        onTap: () => context
                            .read<CalendarPageBloc>()
                            .add(IncreaseMonthEvent()),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            await createGuestList(
                                BlocProvider.of<CalendarPageBloc>(context)
                                    .state
                                    .dayForGuestList,
                                BlocProvider.of<CalendarPageBloc>(context)
                                    .state
                                    .currentMonth
                                    .month,
                                BlocProvider.of<CalendarPageBloc>(context)
                                    .state
                                    .currentMonth
                                    .year);
                          },
                          child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.download, size: 14),
                                Text(" Xuất danh sách")
                              ])),
                      BlocBuilder<CalendarPageBloc, CalendarState>(
                        buildWhen: (previous, current) =>
                            previous.dayForGuestList != current.dayForGuestList,
                        builder: (context, state) => DropdownButton<int>(
                          items: List.generate(
                              DateUtils.getDaysInMonth(state.currentMonth.year,
                                  state.currentMonth.month),
                              (index) => DropdownMenuItem(
                                    value: index + 1,
                                    child: Text("${index + 1}"),
                                  )),
                          onChanged: (int? value) {
                            context
                                .read<CalendarPageBloc>()
                                .add(ChangeGuestListDay(value));
                          },
                          value: state.dayForGuestList,
                        ),
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 32,
                  ),
                  Flexible(
                    child: BlocBuilder<CalendarPageBloc, CalendarState>(
                      builder: (context, state) => GridView.count(
                        shrinkWrap: true,
                        childAspectRatio: 2,
                        crossAxisCount: DateUtils.getDaysInMonth(
                            state.currentMonth.year, state.currentMonth.month),
                        children: List.generate(
                          DateUtils.getDaysInMonth(state.currentMonth.year,
                              state.currentMonth.month),
                          (index) => Container(
                            margin: const EdgeInsets.all(1),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: (DateTime(
                                                state.currentMonth.year,
                                                state.currentMonth.month,
                                                index + 1)
                                            .weekday >
                                        5)
                                    ? const Color(0xff6b8e4e)
                                    : const Color(0xffb2c5b2),
                                border: Border.all(
                                    color: Colors.black, width: 0.25)),
                            child: Text(
                              DateTime(
                                              state.currentMonth.year,
                                              state.currentMonth.month,
                                              index + 1)
                                          .weekday ==
                                      7
                                  ? "CN"
                                  : "T${DateTime(state.currentMonth.year, state.currentMonth.month, index + 1).weekday + 1}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Expanded(child: BookingInfo()),
            ],
          ),
        );
      }),
    );
  }
}

class BookingInfo extends StatelessWidget {
  const BookingInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarPageBloc, CalendarState>(
        builder: (context, state) {
      if (state.state == RenderState.waiting) {
        BlocProvider.of<CalendarPageBloc>(context).add(RequireDataEvent());
        return const Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
              Text('Đang tải...'),
            ],
          ),
        );
      }
      Future.delayed(
          Duration.zero,
          () =>
              BlocProvider.of<CalendarPageBloc>(context).add(CompleteRender()));

      return SizedBox.expand(
        child: SingleChildScrollView(
          primary: true,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                  GetIt.I<InternalStorage>().read("roomGroupsList").length,
                  (rid) => DisplayTable(rid: rid))),
        ),
      );
    });
  }
}

class DisplayTable extends StatelessWidget {
  final int rid;

  const DisplayTable({super.key, required this.rid});

  @override
  Widget build(BuildContext context) {
    RoomGroup roomGroup =
        GetIt.I<InternalStorage>().read("roomGroupsList")[rid];
    CalendarPageBloc bloc = BlocProvider.of<CalendarPageBloc>(context);
    int days = DateUtils.getDaysInMonth(
        bloc.state.currentMonth.year, bloc.state.currentMonth.month);
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 0.45)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 32,
            child: Text(roomGroup.room.id),
          ),
          Flexible(
            child: GridView.builder(
              primary: false,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: days * roomGroup.room.total,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: days),
              itemBuilder: (context, index) {
                return (getDisplayValue(days, rid, index).first ==
                        getDisplayValue(days, rid, index).second)
                    ? Cell(
                        rid: rid,
                        index: index,
                        oid: getDisplayValue(
                                DateUtils.getDaysInMonth(
                                    bloc.state.currentMonth.year,
                                    bloc.state.currentMonth.month),
                                rid,
                                index)
                            .first)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            flex: 1,
                            child: HalfCell(
                                rid: rid,
                                index: index,
                                oid: getDisplayValue(days, rid, index).first),
                          ),
                          Flexible(
                            flex: 1,
                            child: HalfCell(
                                rid: rid,
                                index: index,
                                oid: getDisplayValue(days, rid, index).second),
                          ),
                        ],
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Pair getDisplayValue(int days, int rid, int index) {
    RoomGroup roomGroup =
        GetIt.I<InternalStorage>().read("roomGroupsList")[rid];
    return roomGroup.displayArray[index ~/ days][index % days];
  }
}

class Cell extends StatelessWidget {
  final int rid;
  final int index;
  final int oid;

  const Cell(
      {super.key, required this.rid, required this.index, required this.oid});
  @override
  Widget build(BuildContext context) {
    RoomGroup roomGroup =
        GetIt.I<InternalStorage>().read("roomGroupsList")[rid];
    CalendarPageBloc bloc = BlocProvider.of<CalendarPageBloc>(context);
    int days = DateUtils.getDaysInMonth(
        bloc.state.currentMonth.year, bloc.state.currentMonth.month);
    return (oid == -1)
        ? Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
                color: (isBeforeToday(bloc.state.currentMonth, bloc.state.today,
                        index % days + 1))
                    ? Colors.grey[400]
                    : Colors.grey[200]),
            alignment: Alignment.bottomRight,
            child: Text(
              "${index % days + 1}",
              style: const TextStyle(fontSize: 10),
            ),
          )
        : InkWell(
            mouseCursor: MaterialStateMouseCursor.clickable,
            onTap: () {
              context
                  .read<CalendarPageBloc>()
                  .add(GotoInfoPageEvent(oid, rid, context));
            },
            child: Tooltip(
              waitDuration: const Duration(milliseconds: 300),
              message:
                  "${GetIt.I<InternalStorage>().read("roomGroupsList")[rid].room.getRoomDataToString()}\n${roomGroup.ordersList[oid].getBookingInfoToString()}",
              child: Container(
                margin: (isTheBeginningOfABooking(days, rid, index, oid))
                    ? const EdgeInsets.only(left: 1, top: 1, bottom: 1)
                    : (isTheEndOfABooking(days, rid, index, oid))
                        ? const EdgeInsets.only(right: 1, top: 1, bottom: 1)
                        : const EdgeInsets.only(top: 1, bottom: 1),
                decoration: const BoxDecoration(color: Color(0xff89b4f7)),
                alignment: Alignment.bottomLeft,
                child: (isSuitableForText(days, rid, index, oid))
                    ? FittedBox(
                        child: Text(
                            "${roomGroup.ordersList[oid].cat.name}\n${getNumberOfNights(rid, index, oid)}"))
                    : const Text(""),
              ),
            ),
          );
  }

  bool isBeforeToday(DateTime currentMonth, DateTime today, int day) {
    return DateTime(currentMonth.year, currentMonth.month, day).isBefore(today);
  }

  Pair getDisplayValue(int days, int rid, int index) {
    RoomGroup roomGroup =
        GetIt.I<InternalStorage>().read("roomGroupsList")[rid];
    return roomGroup.displayArray[index ~/ days][index % days];
  }

  bool isTheEndOfABooking(int days, int rid, int index, int oid) {
    if (index % days == days - 1) return true;
    if (oid != getDisplayValue(days, rid, index + 1).first) {
      return true;
    }
    return false;
  }

  bool isTheBeginningOfABooking(int days, int rid, int index, int oid) {
    if (index % days == 0) {
      return true;
    }
    if (oid != getDisplayValue(days, rid, index - 1).second) {
      return true;
    }
    return false;
  }

  bool isSuitableForText(int days, int rid, int index, int oid) {
    if (index % days == 0) {
      return true;
    }
    if (oid != getDisplayValue(days, rid, index - 1).first ||
        oid != getDisplayValue(days, rid, index - 1).second) {
      return true;
    }
    return false;
  }

  int getNumberOfNights(int index1, int index2, int value) {
    RoomGroup roomGroup =
        GetIt.I<InternalStorage>().read("roomGroupsList")[index1];
    DateTime checkOut = roomGroup.ordersList[value].checkOut;
    DateTime checkIn = roomGroup.ordersList[value].checkIn;
    return DateTime(checkOut.year, checkOut.month, checkOut.day)
        .difference(DateTime(checkIn.year, checkIn.month, checkIn.day))
        .inDays;
  }
}

class HalfCell extends StatelessWidget {
  final int rid;
  final int index;
  final int oid;

  const HalfCell(
      {super.key, required this.rid, required this.index, required this.oid});
  @override
  Widget build(BuildContext context) {
    RoomGroup roomGroup =
        GetIt.I<InternalStorage>().read("roomGroupsList")[rid];
    CalendarPageBloc bloc = BlocProvider.of<CalendarPageBloc>(context);
    int days = DateUtils.getDaysInMonth(
        bloc.state.currentMonth.year, bloc.state.currentMonth.month);
    return (oid == -1)
        ? Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
                color: (isBeforeToday(bloc.state.currentMonth, bloc.state.today,
                        index % days + 1))
                    ? Colors.grey[400]
                    : Colors.grey[200]),
            alignment: Alignment.bottomRight,
            child: Text(
              "${index % days + 1}",
              style: const TextStyle(fontSize: 10),
            ),
          )
        : InkWell(
            mouseCursor: MaterialStateMouseCursor.clickable,
            onTap: () {
              context
                  .read<CalendarPageBloc>()
                  .add(GotoInfoPageEvent(rid, index, context));
            },
            child: Tooltip(
              waitDuration: const Duration(milliseconds: 300),
              message:
                  "${GetIt.I<InternalStorage>().read("roomGroupsList")[rid].room.getRoomDataToString()}\n${roomGroup.ordersList[oid].getBookingInfoToString()}",
              child: Container(
                margin: (isTheBeginningOfABooking(days, rid, index, oid))
                    ? const EdgeInsets.only(left: 1, top: 1, bottom: 1)
                    : (isTheEndOfABooking(days, rid, index, oid))
                        ? const EdgeInsets.only(right: 1, top: 1, bottom: 1)
                        : const EdgeInsets.only(top: 1, bottom: 1),
                decoration: const BoxDecoration(color: Color(0xff89b4f7)),
                alignment: Alignment.bottomLeft,
              ),
            ),
          );
  }

  bool isBeforeToday(DateTime currentMonth, DateTime today, int day) {
    return DateTime(currentMonth.year, currentMonth.month, day).isBefore(today);
  }

  Pair getDisplayValue(int days, int index1, int index2) {
    return GetIt.I<InternalStorage>()
        .read("roomGroupsList")[index1]
        .displayArray[index2 ~/ days][index2 % days];
  }

  bool isTheEndOfABooking(int days, int index1, int index2, int value) {
    int first = getDisplayValue(days, index1, index2).first;
    if (first == value) {
      return true;
    }
    return false;
  }

  bool isTheBeginningOfABooking(int days, int index1, int index2, int value) {
    int second = getDisplayValue(days, index1, index2).second;
    if (second == value) {
      return true;
    }
    return false;
  }
}
