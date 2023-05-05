import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:project_ii/controller/BookingPageController.dart';
import '../controller/CalendarPageController.dart';
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
          if (Get.find<InternalStorage>().read("bookingDataForAllRooms") ==
              null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
                Text('Đang tải...'),
              ],
            );
          }
          return displayTable(controller, context);
        });
  }

  Widget displayTable(CalendarPageController controller, BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          (Get.find<InternalStorage>().read("bookingDataForAllRooms") as List)
              .length,
          (index1) {
            return Container(
              decoration: BoxDecoration(border: Border.all(width: 0.45)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 32,
                    child: Text(Get.find<InternalStorage>()
                        .read("bookingDataForAllRooms")[index1]
                        .roomData
                        .roomID),
                  ),
                  Flexible(
                    child: GridView.count(
                      primary: false,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      crossAxisCount: controller.daysInCurrentMonth,
                      children: List.generate(
                          (controller.daysInCurrentMonth *
                              (Get.find<InternalStorage>()
                                  .read("bookingDataForAllRooms")[index1]
                                  .roomData
                                  .subQuantity as int)), (index2) {
                        return (getDisplayValue(controller, index1, index2)
                                    .first ==
                                getDisplayValue(controller, index1, index2)
                                    .second)
                            ? HalfCell(
                                controller: controller,
                                index1: index1,
                                index2: index2,
                                value:
                                    getDisplayValue(controller, index1, index2)
                                        .first)
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: HalfCell(
                                        controller: controller,
                                        index1: index1,
                                        index2: index2,
                                        value: getDisplayValue(
                                                controller, index1, index2)
                                            .first),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: HalfCell(
                                        controller: controller,
                                        index1: index1,
                                        index2: index2,
                                        value: getDisplayValue(
                                                controller, index1, index2)
                                            .second),
                                  ),
                                ],
                              );
                      }),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Pair getDisplayValue(
      CalendarPageController controller, int index1, int index2) {
    return Get.find<InternalStorage>()
            .read("bookingDataForAllRooms")[index1]
            .displayArray[index2 ~/ controller.daysInCurrentMonth]
        [index2 % controller.daysInCurrentMonth];
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
              if (Get.find<InternalStorage>().read("allServiceList") == null) {
                await Get.find<BookingPageController>().getServiceInfo();
                await Get.delete<BookingPageController>();
              }
              await Get.toNamed("/info?ridx=$index1&bidx=$value")?.then(
                (value) async => await controller.getBookingDataForAllRooms(),
              );
            },
            child: Tooltip(
              waitDuration: const Duration(milliseconds: 600),
              message:
                  "${Get.find<InternalStorage>().read("bookingDataForAllRooms")[index1].roomData.getRoomDataToString()}\n${Get.find<InternalStorage>().read("bookingDataForAllRooms")[index1].bookingDataList[value].getBookingInfoToString()}",
              child: Container(
                margin: (isTheBeginningOfABooking(
                        controller, index1, index2, value))
                    ? const EdgeInsets.only(left: 1, top: 1, bottom: 1)
                    : (isTheEndOfABooking(controller, index1, index2, value))
                        ? const EdgeInsets.only(right: 1, top: 1, bottom: 1)
                        : const EdgeInsets.only(top: 1, bottom: 1),
                decoration: const BoxDecoration(color: Color(0xff89b4f7)),
                alignment: Alignment.bottomLeft,
                child: (isSuitableForText(controller, index1, index2))
                    ? RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: Get.find<InternalStorage>()
                                  .read("bookingDataForAllRooms")[index1]
                                  .bookingDataList[value]
                                  .catData
                                  .catName,
                              style: TextStyle(
                                  fontSize: (Get.find<InternalStorage>()
                                              .read("bookingDataForAllRooms")[
                                                  index1]
                                              .bookingDataList[value]
                                              .catData
                                              .catName
                                              .length >
                                          4)
                                      ? 10
                                      : 14,
                                  fontWeight: FontWeight.w600)),
                          TextSpan(
                              text:
                                  "\n${getNumberOfNights(controller, index1, index2, value)}",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600))
                        ]),
                      )
                    : const Text(""),
              ),
            ),
          );
  }

  Pair getDisplayValue(
      CalendarPageController controller, int index1, int index2) {
    return Get.find<InternalStorage>()
            .read("bookingDataForAllRooms")[index1]
            .displayArray[index2 ~/ controller.daysInCurrentMonth]
        [index2 % controller.daysInCurrentMonth];
  }

  bool isTheEndOfABooking(
      CalendarPageController controller, int index1, int index2, int value) {
    if (getDisplayValue(controller, index1, index2).first ==
        getDisplayValue(controller, index1, index2).second) {
      if (index2 % controller.daysInCurrentMonth ==
          controller.daysInCurrentMonth - 1) return true;
      if (getDisplayValue(controller, index1, index2).second !=
          getDisplayValue(controller, index1, index2 + 1).first) return true;
      return false;
    } else {
      if (getDisplayValue(controller, index1, index2).first == value) {
        return true;
      }
      return false;
    }
  }

  bool isTheBeginningOfABooking(
      CalendarPageController controller, int index1, int index2, int value) {
    if (getDisplayValue(controller, index1, index2).first ==
        getDisplayValue(controller, index1, index2).second) {
      if (index2 % controller.daysInCurrentMonth == 0) {
        return true;
      }
      if (getDisplayValue(controller, index1, index2).first !=
          getDisplayValue(controller, index1, index2 - 1).second) return true;
      return false;
    } else {
      if (getDisplayValue(controller, index1, index2).second == value) {
        return true;
      }
      return false;
    }
  }

  bool isSuitableForText(
    CalendarPageController controller,
    int index1,
    int index2,
  ) {
    if (getDisplayValue(controller, index1, index2).first ==
        getDisplayValue(controller, index1, index2).second) {
      if (index2 % controller.daysInCurrentMonth == 0) {
        return true;
      }
      if (getDisplayValue(controller, index1, index2).first !=
              getDisplayValue(controller, index1, index2 - 1).first ||
          getDisplayValue(controller, index1, index2).second !=
              getDisplayValue(controller, index1, index2 - 1).second)
        return true;
      return false;
    }

    return false;
  }

  int getNumberOfNights(
      CalendarPageController controller, int index1, int index2, int value) {
    return DateTime(
            Get.find<InternalStorage>()
                .read("bookingDataForAllRooms")[index1]
                .bookingDataList[value]
                .checkOutDate
                .year,
            Get.find<InternalStorage>()
                .read("bookingDataForAllRooms")[index1]
                .bookingDataList[value]
                .checkOutDate
                .month,
            Get.find<InternalStorage>()
                .read("bookingDataForAllRooms")[index1]
                .bookingDataList[value]
                .checkOutDate
                .day)
        .difference(DateTime(
            Get.find<InternalStorage>()
                .read("bookingDataForAllRooms")[index1]
                .bookingDataList[value]
                .checkInDate
                .year,
            Get.find<InternalStorage>()
                .read("bookingDataForAllRooms")[index1]
                .bookingDataList[value]
                .checkInDate
                .month,
            Get.find<InternalStorage>()
                .read("bookingDataForAllRooms")[index1]
                .bookingDataList[value]
                .checkInDate
                .day))
        .inDays;
  }
}
