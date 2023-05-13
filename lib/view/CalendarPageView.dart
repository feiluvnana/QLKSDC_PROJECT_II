import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:project_ii/controller/BookingPageController.dart';
import '../controller/CalendarPageController.dart';
import '../model/RoomGroupModel.dart';
import '../utils/InternalStorage.dart';
import '../utils/PairUtils.dart';
import '../utils/GuestList.dart';

class CalenderPage extends StatelessWidget with GuestList {
  const CalenderPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    onTap: () =>
                        Get.find<CalendarPageController>().addMonths(value: -1),
                  ),
                  GetBuilder<CalendarPageController>(
                    id: "monthText",
                    builder: (controller) => Text(
                        DateFormat("MM/yyyy").format(controller.currentMonth)),
                  ),
                  GestureDetector(
                    child: const FaIcon(FontAwesomeIcons.arrowRight),
                    onTap: () =>
                        Get.find<CalendarPageController>().addMonths(value: 1),
                  ),
                ],
              ),
              GetBuilder<CalendarPageController>(
                  id: "guestList",
                  builder: (controller) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                await createSpreadSheet(
                                    controller.dayForGuestList,
                                    controller.currentMonth.month,
                                    controller.currentMonth.year);
                              },
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    FaIcon(FontAwesomeIcons.download, size: 14),
                                    Text(" Xuất danh sách")
                                  ])),
                          DropdownButton<int>(
                            items: List.generate(
                                controller.daysInCurrentMonth,
                                (index) => DropdownMenuItem(
                                      value: index + 1,
                                      child: Text("${index + 1}"),
                                    )),
                            onChanged: (int? value) {
                              controller.dayForGuestList = value!;
                              controller.update(["guestList"]);
                            },
                            value: controller.dayForGuestList,
                          )
                        ],
                      ))
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 32,
              ),
              Flexible(
                child: GetBuilder<CalendarPageController>(
                  id: "dayLabel",
                  builder: (controller) => GridView.count(
                    shrinkWrap: true,
                    childAspectRatio: 2,
                    crossAxisCount: controller.daysInCurrentMonth,
                    children: List.generate(
                      controller.daysInCurrentMonth,
                      (index) => Container(
                        margin: const EdgeInsets.all(1),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: (DateTime(
                                            controller.currentMonth.year,
                                            controller.currentMonth.month,
                                            index + 1)
                                        .weekday >
                                    5)
                                ? const Color(0xff6b8e4e)
                                : const Color(0xffb2c5b2),
                            border:
                                Border.all(color: Colors.black, width: 0.25)),
                        child: Text(
                          DateTime(
                                          controller.currentMonth.year,
                                          controller.currentMonth.month,
                                          index + 1)
                                      .weekday ==
                                  7
                              ? "CN"
                              : "T${DateTime(controller.currentMonth.year, controller.currentMonth.month, index + 1).weekday + 1}",
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
  }
}

class BookingInfo extends StatelessWidget {
  const BookingInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CalendarPageController>(
        id: "table",
        builder: (controller) {
          if (Get.find<InternalStorage>().read("roomGroupsList") == null) {
            Future.delayed(
                const Duration(milliseconds: 300),
                () => Get.defaultDialog(
                    title: "", content: const Text("Đang tải...")));
          }
          Future.delayed(const Duration(milliseconds: 300), () => Get.back());
          List<RoomGroup> roomGroup =
              Get.find<InternalStorage>().read("roomGroupsList");

          return SingleChildScrollView(
            primary: true,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                    roomGroup.length,
                    (index1) =>
                        DisplayTable(controller: controller, index1: index1))),
          );
        });
  }
}

class DisplayTable extends StatelessWidget {
  final CalendarPageController controller;
  final int index1;

  const DisplayTable(
      {super.key, required this.controller, required this.index1});

  @override
  Widget build(BuildContext context) {
    print("build Big");
    RoomGroup roomGroup =
        Get.find<InternalStorage>().read("roomGroupsList")[index1];
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
              itemCount: controller.daysInCurrentMonth * roomGroup.room.total,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: controller.daysInCurrentMonth),
              itemBuilder: (context, index2) {
                return (getDisplayValue(controller, index1, index2).first ==
                        getDisplayValue(controller, index1, index2).second)
                    ? Cell(
                        controller: controller,
                        index1: index1,
                        index2: index2,
                        value:
                            getDisplayValue(controller, index1, index2).first)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            flex: 1,
                            child: HalfCell(
                                controller: controller,
                                index1: index1,
                                index2: index2,
                                value:
                                    getDisplayValue(controller, index1, index2)
                                        .first),
                          ),
                          Flexible(
                            flex: 1,
                            child: HalfCell(
                                controller: controller,
                                index1: index1,
                                index2: index2,
                                value:
                                    getDisplayValue(controller, index1, index2)
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

  Pair getDisplayValue(
      CalendarPageController controller, int index1, int index2) {
    RoomGroup roomGroup =
        Get.find<InternalStorage>().read("roomGroupsList")[index1];
    return roomGroup.displayArray[index2 ~/ controller.daysInCurrentMonth]
        [index2 % controller.daysInCurrentMonth];
  }
}

class Cell extends StatelessWidget {
  final CalendarPageController controller;
  final int index1;
  final int index2;
  final int value;

  const Cell(
      {super.key,
      required this.controller,
      required this.index1,
      required this.index2,
      required this.value});
  @override
  Widget build(BuildContext context) {
    RoomGroup roomGroup =
        Get.find<InternalStorage>().read("roomGroupsList")[index1];
    return (value == -1)
        ? Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
                color: (controller.isBeforeToday(
                        index2 % controller.daysInCurrentMonth + 1))
                    ? Colors.grey[400]
                    : Colors.grey[200]),
            alignment: Alignment.bottomRight,
            child: Text(
              "${index2 % controller.daysInCurrentMonth + 1}",
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
              await Get.toNamed("/info?ridx=$index1&bidx=$value")?.then(
                (value) async => await controller.getRoomGroups(),
              );
            },
            child: Tooltip(
              waitDuration: const Duration(milliseconds: 300),
              message:
                  "${roomGroup.room.getRoomDataToString()}\n${roomGroup.ordersList[value].getBookingInfoToString()}",
              child: Container(
                margin: (isTheBeginningOfABooking(
                        controller, index1, index2, value))
                    ? const EdgeInsets.only(left: 1, top: 1, bottom: 1)
                    : (isTheEndOfABooking(controller, index1, index2, value))
                        ? const EdgeInsets.only(right: 1, top: 1, bottom: 1)
                        : const EdgeInsets.only(top: 1, bottom: 1),
                decoration: const BoxDecoration(color: Color(0xff89b4f7)),
                alignment: Alignment.bottomLeft,
                child: (isSuitableForText(controller, index1, index2, value))
                    ? FittedBox(
                        child: Text(
                            "${roomGroup.ordersList[value].cat.name}\n${getNumberOfNights(controller, index1, index2, value)}"))
                    : const Text(""),
              ),
            ),
          );
  }

  Pair getDisplayValue(
      CalendarPageController controller, int index1, int index2) {
    return Get.find<InternalStorage>()
            .read("roomGroupsList")[index1]
            .displayArray[index2 ~/ controller.daysInCurrentMonth]
        [index2 % controller.daysInCurrentMonth];
  }

  bool isTheEndOfABooking(
      CalendarPageController controller, int index1, int index2, int value) {
    if (index2 % controller.daysInCurrentMonth ==
        controller.daysInCurrentMonth - 1) return true;
    if (value != getDisplayValue(controller, index1, index2 + 1).first) {
      return true;
    }
    return false;
  }

  bool isTheBeginningOfABooking(
      CalendarPageController controller, int index1, int index2, int value) {
    if (index2 % controller.daysInCurrentMonth == 0) {
      return true;
    }
    if (value != getDisplayValue(controller, index1, index2 - 1).second) {
      return true;
    }
    return false;
  }

  bool isSuitableForText(
      CalendarPageController controller, int index1, int index2, int value) {
    if (index2 % controller.daysInCurrentMonth == 0) {
      return true;
    }
    if (value != getDisplayValue(controller, index1, index2 - 1).first ||
        value != getDisplayValue(controller, index1, index2 - 1).second) {
      return true;
    }
    return false;
  }

  int getNumberOfNights(
      CalendarPageController controller, int index1, int index2, int value) {
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
  final CalendarPageController controller;
  final int index1;
  final int index2;
  final int value;

  const HalfCell(
      {super.key,
      required this.controller,
      required this.index1,
      required this.index2,
      required this.value});
  @override
  Widget build(BuildContext context) {
    RoomGroup roomGroup =
        Get.find<InternalStorage>().read("roomGroupsList")[index1];
    return (value == -1)
        ? Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
                color: (controller.isBeforeToday(
                        index2 % controller.daysInCurrentMonth + 1))
                    ? Colors.grey[400]
                    : Colors.grey[200]),
            alignment: Alignment.bottomRight,
            child: Text(
              "${index2 % controller.daysInCurrentMonth + 1}",
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
              await Get.toNamed("/info?ridx=$index1&bidx=$value")?.then(
                (value) async => await controller.getRoomGroups(),
              );
            },
            child: Tooltip(
              waitDuration: const Duration(milliseconds: 300),
              message:
                  "${roomGroup.room.getRoomDataToString()}\n${roomGroup.ordersList[value].getBookingInfoToString()}",
              child: Container(
                margin: (isTheBeginningOfABooking(
                        controller, index1, index2, value))
                    ? const EdgeInsets.only(left: 1, top: 1, bottom: 1)
                    : (isTheEndOfABooking(controller, index1, index2, value))
                        ? const EdgeInsets.only(right: 1, top: 1, bottom: 1)
                        : const EdgeInsets.only(top: 1, bottom: 1),
                decoration: const BoxDecoration(color: Color(0xff89b4f7)),
                alignment: Alignment.bottomLeft,
              ),
            ),
          );
  }

  Pair getDisplayValue(
      CalendarPageController controller, int index1, int index2) {
    return Get.find<InternalStorage>()
            .read("roomGroupsList")[index1]
            .displayArray[index2 ~/ controller.daysInCurrentMonth]
        [index2 % controller.daysInCurrentMonth];
  }

  bool isTheEndOfABooking(
      CalendarPageController controller, int index1, int index2, int value) {
    int first = getDisplayValue(controller, index1, index2).first;
    if (first == value) {
      return true;
    }
    return false;
  }

  bool isTheBeginningOfABooking(
      CalendarPageController controller, int index1, int index2, int value) {
    int second = getDisplayValue(controller, index1, index2).second;
    if (second == value) {
      return true;
    }
    return false;
  }
}
