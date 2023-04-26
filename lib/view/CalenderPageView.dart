import 'package:flutter/material.dart' hide DateUtils;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:project_ii/view/InformationPageView.dart';
import '../controller/CalendarPageController.dart';
import '../utils/DateUtils.dart';
import '../utils/PairUtils.dart';
import 'GuestListView.dart';

class CalenderPage extends StatelessWidget {
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
                        Get.find<CalendarPageController>().addMonths(month: -1),
                  ),
                  GetBuilder<CalendarPageController>(
                    builder: (controller) =>
                        Text(" ${controller.printCurrentMonth()}"),
                  ),
                  GestureDetector(
                    child: const FaIcon(FontAwesomeIcons.arrowRight),
                    onTap: () =>
                        Get.find<CalendarPageController>().addMonths(month: 1),
                  ),
                ],
              ),
              GetBuilder<CalendarPageController>(
                  builder: (controller) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                {} /*Get.to(GuestList(), arguments: {
                              "roomBookingData": controller.roomBookingData,
                              "day": controller.dayForList,
                            })*/
                            ,
                            child: const Text("Xuất danh sách"),
                          ),
                          DropdownButton<int>(
                            items: List.generate(
                                DateUtils.daysInMonth(controller.currentMonth),
                                (index) => DropdownMenuItem(
                                      value: index + 1,
                                      child: Text("${index + 1}"),
                                    )),
                            onChanged: (int? value) {
                              controller.dayForList = value!;
                            },
                            value: controller.dayForList,
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
                  builder: (controller) => GridView.count(
                    shrinkWrap: true,
                    childAspectRatio: 2,
                    crossAxisCount:
                        DateUtils.daysInMonth(controller.currentMonth),
                    children: List.generate(
                      DateUtils.daysInMonth(controller.currentMonth),
                      (index) => Container(
                        margin: const EdgeInsets.all(1),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: (DateTime(
                                            controller.currentMonth["year"]!,
                                            controller.currentMonth["month"]!,
                                            index + 1)
                                        .weekday >
                                    5)
                                ? const Color(0xff6b8e4e)
                                : const Color(0xffb2c5b2),
                            border:
                                Border.all(color: Colors.black, width: 0.25)),
                        child: Text(
                          DateUtils.daysInWeek(DateTime(
                                      controller.currentMonth["year"]!,
                                      controller.currentMonth["month"]!,
                                      index + 1)
                                  .weekday %
                              7),
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
    print(Get.find<CalendarPageController>().roomBookingData);
    return GetBuilder<CalendarPageController>(
      builder: (controller) {
        var splashScreen = Column(
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
        Future.delayed(const Duration(seconds: 2), () {
          controller.index = 1;
          controller.update();
        });
        return IndexedStack(
          alignment: Alignment.center,
          index: controller.index,
          children: [
            splashScreen,
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  controller.roomBookingData.length,
                  (index1) {
                    return Container(
                      decoration:
                          BoxDecoration(border: Border.all(width: 0.45)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 32,
                            child: Text(controller
                                .roomBookingData[index1].roomData.roomID),
                          ),
                          Flexible(
                            child: GridView.count(
                              primary: false,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              crossAxisCount: DateUtils.daysInMonth(
                                  controller.currentMonth),
                              children: List.generate(
                                  (DateUtils.daysInMonth(
                                          controller.currentMonth) *
                                      (controller.roomBookingData[index1]
                                          .roomData.subQuantity)), (index2) {
                                return (getDisplayValue(
                                                controller, index1, index2)
                                            .first ==
                                        getDisplayValue(
                                                controller, index1, index2)
                                            .second)
                                    ? HalfCell(
                                        controller: controller,
                                        index1: index1,
                                        index2: index2,
                                        value: getDisplayValue(
                                                controller, index1, index2)
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
                                                        controller,
                                                        index1,
                                                        index2)
                                                    .first),
                                          ),
                                          Flexible(
                                            flex: 1,
                                            child: HalfCell(
                                                controller: controller,
                                                index1: index1,
                                                index2: index2,
                                                value: getDisplayValue(
                                                        controller,
                                                        index1,
                                                        index2)
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
            ),
          ],
        );
      },
    );
  }

  Pair getDisplayValue(
      CalendarPageController controller, int index1, int index2) {
    return controller.roomBookingData[index1].displayArray[
            index2 ~/ DateUtils.daysInMonth(controller.currentMonth)]
        [index2 % DateUtils.daysInMonth(controller.currentMonth)];
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
                color: (controller.isBeforeToday(index2 %
                            DateUtils.daysInMonth(controller.currentMonth) +
                        1))
                    ? Colors.grey[400]
                    : Colors.grey[200]),
            alignment: Alignment.bottomRight,
            child: Text(
              "${index2 % DateUtils.daysInMonth(controller.currentMonth) + 1}",
              style: const TextStyle(fontSize: 10),
            ),
          )
        : InkWell(
            mouseCursor: MaterialStateMouseCursor.clickable,
            onTap: () => Get.toNamed("/home/info", arguments: {
              "bookingData":
                  controller.roomBookingData[index1].bookingData[value],
              "roomData": controller.roomBookingData[index1].roomData
            }),
            child: Tooltip(
              waitDuration: const Duration(seconds: 1),
              message:
                  "${controller.roomBookingData[index1].roomData.getRoomDataToString()}\n${controller.roomBookingData[index1].bookingData[value].getBookingInfoToString()}",
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
                              text: controller.roomBookingData[index1]
                                  .bookingData[value].catData.catName,
                              style: TextStyle(
                                  fontSize: (controller
                                              .roomBookingData[index1]
                                              .bookingData[value]
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
    return controller.roomBookingData[index1].displayArray[
            index2 ~/ DateUtils.daysInMonth(controller.currentMonth)]
        [index2 % DateUtils.daysInMonth(controller.currentMonth)];
  }

  bool isTheEndOfABooking(
      CalendarPageController controller, int index1, int index2, int value) {
    if (getDisplayValue(controller, index1, index2).first ==
        getDisplayValue(controller, index1, index2).second) {
      if (index2 % DateUtils.daysInMonth(controller.currentMonth) ==
          DateUtils.daysInMonth(controller.currentMonth) - 1) return true;
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
      if (index2 % DateUtils.daysInMonth(controller.currentMonth) == 0) {
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
      if (index2 % DateUtils.daysInMonth(controller.currentMonth) == 0) {
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
            controller.roomBookingData[index1].bookingData[value].dateOut.year,
            controller.roomBookingData[index1].bookingData[value].dateOut.month,
            controller.roomBookingData[index1].bookingData[value].dateOut.day)
        .difference(DateTime(
            controller.roomBookingData[index1].bookingData[value].dateIn.year,
            controller.roomBookingData[index1].bookingData[value].dateIn.month,
            controller.roomBookingData[index1].bookingData[value].dateIn.day))
        .inDays;
  }
}
