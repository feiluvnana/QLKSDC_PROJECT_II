import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:project_ii/controller/BookingPageController.dart';
import 'package:project_ii/controller/login_page_bloc.dart';
import '../controller/calendar_page_bloc.dart';
import '../model/RoomGroupModel.dart';
import '../utils/InternalStorage.dart';
import '../utils/PairUtils.dart';
import '../utils/ExcelGenerator.dart';

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
                          child: const FaIcon(FontAwesomeIcons.arrowLeft),
                          onTap: () => context
                              .read<CalendarPageBloc>()
                              .add(MonthDecreasedEvent())),
                      BlocBuilder<CalendarPageBloc, CalendarState>(
                        buildWhen: (previous, current) =>
                            previous.currentMonth != current.currentMonth,
                        builder: (context, state) => Text(
                            DateFormat("MM/yyyy").format(state.currentMonth)),
                      ),
                      GestureDetector(
                        child: const FaIcon(FontAwesomeIcons.arrowRight),
                        onTap: () => context
                            .read<CalendarPageBloc>()
                            .add(MonthIncreasedEvent()),
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
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                FaIcon(FontAwesomeIcons.download, size: 14),
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
                                .add(GuestListDayChangedEvent(value));
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
    return BlocConsumer<CalendarPageBloc, CalendarState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state.state == RenderState.waiting) {
            BlocProvider.of<CalendarPageBloc>(context).add(DataNeededEvent());
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
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
              const Duration(milliseconds: 100),
              () => BlocProvider.of<CalendarPageBloc>(context)
                  .add(RenderCompletedEvent()));
          List<RoomGroup> roomGroup =
              Get.find<InternalStorage>().read("roomGroupsList");
          return SingleChildScrollView(
            primary: true,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(roomGroup.length,
                    (index1) => DisplayTable(index1: index1))),
          );
        });
  }
}

class DisplayTable extends StatelessWidget {
  final int index1;

  const DisplayTable({super.key, required this.index1});

  @override
  Widget build(BuildContext context) {
    RoomGroup roomGroup =
        Get.find<InternalStorage>().read("roomGroupsList")[index1];
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
              itemBuilder: (context, index2) {
                return (getDisplayValue(days, index1, index2).first ==
                        getDisplayValue(days, index1, index2).second)
                    ? Cell(
                        index1: index1,
                        index2: index2,
                        value: getDisplayValue(
                                DateUtils.getDaysInMonth(
                                    bloc.state.currentMonth.year,
                                    bloc.state.currentMonth.month),
                                index1,
                                index2)
                            .first)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            flex: 1,
                            child: HalfCell(
                                index1: index1,
                                index2: index2,
                                value: getDisplayValue(days, index1, index2)
                                    .first),
                          ),
                          Flexible(
                            flex: 1,
                            child: HalfCell(
                                index1: index1,
                                index2: index2,
                                value: getDisplayValue(days, index1, index2)
                                    .second),
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

  Pair getDisplayValue(int days, int index1, int index2) {
    RoomGroup roomGroup =
        Get.find<InternalStorage>().read("roomGroupsList")[index1];
    return roomGroup.displayArray[index2 ~/ days][index2 % days];
  }
}

class Cell extends StatelessWidget {
  final int index1;
  final int index2;
  final int value;

  const Cell(
      {super.key,
      required this.index1,
      required this.index2,
      required this.value});
  @override
  Widget build(BuildContext context) {
    RoomGroup roomGroup =
        Get.find<InternalStorage>().read("roomGroupsList")[index1];
    CalendarPageBloc bloc = BlocProvider.of<CalendarPageBloc>(context);
    int days = DateUtils.getDaysInMonth(
        bloc.state.currentMonth.year, bloc.state.currentMonth.month);
    return (value == -1)
        ? Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
                color: (isBeforeToday(bloc.state.currentMonth, bloc.state.today,
                        index2 % days + 1))
                    ? Colors.grey[400]
                    : Colors.grey[200]),
            alignment: Alignment.bottomRight,
            child: Text(
              "${index2 % days + 1}",
              style: const TextStyle(fontSize: 10),
            ),
          )
        : InkWell(
            mouseCursor: MaterialStateMouseCursor.clickable,
            onTap: () async {
              if (Get.find<InternalStorage>().read("servicesList") == null) {
                await Get.find<BookingPageController>().getServices();
                await Get.delete<BookingPageController>();
              }
              await Get.toNamed("/info?ridx=$index1&bidx=$value");
            },
            child: Tooltip(
              waitDuration: const Duration(milliseconds: 300),
              message:
                  "${roomGroup.room.getRoomDataToString()}\n${roomGroup.ordersList[value].getBookingInfoToString()}",
              child: Container(
                margin: (isTheBeginningOfABooking(days, index1, index2, value))
                    ? const EdgeInsets.only(left: 1, top: 1, bottom: 1)
                    : (isTheEndOfABooking(days, index1, index2, value))
                        ? const EdgeInsets.only(right: 1, top: 1, bottom: 1)
                        : const EdgeInsets.only(top: 1, bottom: 1),
                decoration: const BoxDecoration(color: Color(0xff89b4f7)),
                alignment: Alignment.bottomLeft,
                child: (isSuitableForText(days, index1, index2, value))
                    ? FittedBox(
                        child: Text(
                            "${roomGroup.ordersList[value].cat.name}\n${getNumberOfNights(index1, index2, value)}"))
                    : const Text(""),
              ),
            ),
          );
  }

  bool isBeforeToday(DateTime currentMonth, DateTime today, int day) {
    return DateTime(currentMonth.year, currentMonth.month, day).isBefore(today);
  }

  Pair getDisplayValue(int days, int index1, int index2) {
    RoomGroup roomGroup =
        Get.find<InternalStorage>().read("roomGroupsList")[index1];
    return roomGroup.displayArray[index2 ~/ days][index2 % days];
  }

  bool isTheEndOfABooking(int days, int index1, int index2, int value) {
    if (index2 % days == days - 1) return true;
    if (value != getDisplayValue(days, index1, index2 + 1).first) {
      return true;
    }
    return false;
  }

  bool isTheBeginningOfABooking(int days, int index1, int index2, int value) {
    if (index2 % days == 0) {
      return true;
    }
    if (value != getDisplayValue(days, index1, index2 - 1).second) {
      return true;
    }
    return false;
  }

  bool isSuitableForText(int days, int index1, int index2, int value) {
    if (index2 % days == 0) {
      return true;
    }
    if (value != getDisplayValue(days, index1, index2 - 1).first ||
        value != getDisplayValue(days, index1, index2 - 1).second) {
      return true;
    }
    return false;
  }

  int getNumberOfNights(int index1, int index2, int value) {
    RoomGroup roomGroup =
        Get.find<InternalStorage>().read("roomGroupsList")[index1];
    DateTime checkOut = roomGroup.ordersList[value].checkOut;
    DateTime checkIn = roomGroup.ordersList[value].checkIn;
    return DateTime(checkOut.year, checkOut.month, checkOut.day)
        .difference(DateTime(checkIn.year, checkIn.month, checkIn.day))
        .inDays;
  }
}

class HalfCell extends StatelessWidget {
  final int index1;
  final int index2;
  final int value;

  const HalfCell(
      {super.key,
      required this.index1,
      required this.index2,
      required this.value});
  @override
  Widget build(BuildContext context) {
    RoomGroup roomGroup =
        Get.find<InternalStorage>().read("roomGroupsList")[index1];
    CalendarPageBloc bloc = BlocProvider.of<CalendarPageBloc>(context);
    int days = DateUtils.getDaysInMonth(
        bloc.state.currentMonth.year, bloc.state.currentMonth.month);
    return (value == -1)
        ? Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
                color: (isBeforeToday(bloc.state.currentMonth, bloc.state.today,
                        index2 % days + 1))
                    ? Colors.grey[400]
                    : Colors.grey[200]),
            alignment: Alignment.bottomRight,
            child: Text(
              "${index2 % days + 1}",
              style: const TextStyle(fontSize: 10),
            ),
          )
        : InkWell(
            mouseCursor: MaterialStateMouseCursor.clickable,
            onTap: () async {
              if (Get.find<InternalStorage>().read("servicesList") == null) {
                await Get.find<BookingPageController>().getServices();
                await Get.delete<BookingPageController>();
              }
              await Get.toNamed("/info?ridx=$index1&bidx=$value");
            },
            child: Tooltip(
              waitDuration: const Duration(milliseconds: 300),
              message:
                  "${roomGroup.room.getRoomDataToString()}\n${roomGroup.ordersList[value].getBookingInfoToString()}",
              child: Container(
                margin: (isTheBeginningOfABooking(days, index1, index2, value))
                    ? const EdgeInsets.only(left: 1, top: 1, bottom: 1)
                    : (isTheEndOfABooking(days, index1, index2, value))
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
    return Get.find<InternalStorage>()
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
