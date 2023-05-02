import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_ii/model/RoomBookingModel.dart';

class GuestListView extends StatelessWidget {
  const GuestListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: 1200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [StayingTable()],
          ),
        ),
      ),
    );
  }
}

class StayingTable extends StatelessWidget {
  const StayingTable({super.key});

  @override
  Widget build(BuildContext context) {
    List<RoomBooking> bookingDataForAllRooms =
        Get.arguments["bookingDataForAllRooms"];
    int colorChanger = 0;
    return Container(
      decoration: const BoxDecoration(
          border: Border.fromBorderSide(
              BorderSide(width: 1, color: Color(0xff68b6ef)))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 30,
                decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(width: 1, color: Color(0xff68b6ef)),
                        bottom:
                            BorderSide(width: 1, color: Color(0xff68b6ef)))),
                child: const Align(
                    alignment: Alignment.center, child: Text("Phòng")),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                height: 30,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(width: 1, color: Color(0xff68b6ef)))),
                child: const Text("Hạng ăn"),
              ),
            ),
            Expanded(
              flex: 8,
              child: Container(
                height: 30,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(width: 1, color: Color(0xff68b6ef)))),
                child: const Text("Thông tin"),
              ),
            ),
            const Expanded(
              flex: 10,
              child: SizedBox(
                height: 30,
                child: Align(alignment: Alignment.center, child: Text("Chú ý")),
              ),
            ),
          ],
        ),
        ...List.generate(
            bookingDataForAllRooms.length,
            (index) =>
                createRow(bookingDataForAllRooms[index], colorChanger++)),
      ]),
    );
  }

  Widget createRow(RoomBooking bookingDataForARoom, int colorChanger) {
    DateTime guestListDay = DateTime(int.parse(Get.parameters["year"]!),
        int.parse(Get.parameters["month"]!), int.parse(Get.parameters["day"]!));

    List<Map<String, dynamic>> listForRow = [];

    for (var bd in bookingDataForARoom.bookingData) {
      if (guestListDay.isAfter(ignoreHour(bd.checkInDate)) &&
          guestListDay.isBefore(ignoreHour(bd.checkOutDate))) {
        listForRow.add({
          "subNumber": bd.subNumber,
          "eatingRank": bd.eatingRank,
          "bookingServiceList": bd.bookingServiceList,
          "attention": bd.attention
        });
      }
    }

    return (listForRow.isNotEmpty)
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                    decoration: const BoxDecoration(
                        border: Border(
                            right: BorderSide(
                                width: 1, color: Color(0xff68b6ef)))),
                    child: Text(bookingDataForARoom.roomData.roomID)),
              ),
              Expanded(
                flex: 22,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    listForRow.length,
                    (index) => Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: (colorChanger == 0)
                                      ? const Color(0xffE3F2FD)
                                      : null,
                                  border: const Border(
                                      right: BorderSide(
                                          width: 1, color: Color(0xff68b6ef)))),
                              child: Text(
                                  listForRow[index]["subNumber"].toString())),
                        ),
                        const Expanded(flex: 21, child: Text("Sometext"))
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
        : Container();
  }

  DateTime ignoreHour(DateTime time) {
    return DateTime(time.year, time.month, time.day);
  }
}
