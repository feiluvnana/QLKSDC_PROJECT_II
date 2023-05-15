import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../model/AdditionModel.dart';
import '../../model/OrderModel.dart';
import '../../model/RoomGroupModel.dart';
import '../../model/RoomModel.dart';
import '../../utils/InternalStorage.dart';
import '../../utils/PairUtils.dart';

class RoomGroupDataProvider {
  final DateTime currentMonth;
  final DateTime today;

  const RoomGroupDataProvider(
      {required this.currentMonth, required this.today});

  bool isInCurrentMonth(DateTime date) {
    return currentMonth.year == date.year && currentMonth.month == date.month;
  }

  Future<List<List<Pair>>> createDisplayListForOneRoom(
      Room roomData, List<Order> bookingList) async {
    if (bookingList.isEmpty) {
      return List.generate(
          roomData.total,
          (index) => List.generate(
              DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month),
              (index) => Pair(first: -1, second: -1)));
    }
    List<List<Pair>> list = List.generate(
        roomData.total,
        (index) => List.generate(
            DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month),
            (index) => Pair(first: -1, second: -1)));
    for (int i = 0; i < bookingList.length; i++) {
      int startIndex = (!isInCurrentMonth(bookingList[i].checkIn))
          ? 0
          : bookingList[i].checkIn.day - 1;
      bool earlyIn = bookingList[i].checkIn.hour < 14;
      bool roundedIn = !isInCurrentMonth(bookingList[i].checkIn);
      int endIndex = (!isInCurrentMonth(bookingList[i].checkOut))
          ? DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month) - 1
          : bookingList[i].checkOut.day - 1;
      bool lateOut = (bookingList[i].checkOut.hour > 14) ||
          (bookingList[i].checkOut.hour == 14 &&
              (bookingList[i].checkOut.minute > 0));
      bool roundedOut = !isInCurrentMonth(bookingList[i].checkOut);

      for (int k = startIndex; k <= endIndex; k++) {
        if (earlyIn && k == startIndex) {
          list[bookingList[i].subRoomNum - 1][k].first = i;
        }
        if (startIndex == k) list[bookingList[i].subRoomNum - 1][k].second = i;
        if (startIndex == k && roundedIn)
          list[bookingList[i].subRoomNum - 1][k].first = i;
        if (lateOut && k == endIndex) {
          list[bookingList[i].subRoomNum - 1][k].second = i;
        }
        if (endIndex == k) list[bookingList[i].subRoomNum - 1][k].first = i;
        if (endIndex == k && roundedOut)
          list[bookingList[i].subRoomNum - 1][k].second = i;
        if (k > startIndex && k < endIndex) {
          list[bookingList[i].subRoomNum - 1][k] = Pair(first: i, second: i);
        }
      }
    }
    return list;
  }

  Future<List<Order>> getOrdersForOneRoom(Room room) async {
    var resList = await GetConnect()
        .post(
      "http://localhost/php-crash/getOrderInfo.php",
      FormData({
        "sessionID": GetStorage().read("sessionID"),
        "roomID": room.id,
        "month": currentMonth.month,
        "year": currentMonth.year
      }),
    )
        .then((res) {
      if (res.body == null) return [];
      if (jsonDecode(res.body)["status"] == "successed") {
        return jsonDecode(jsonDecode(res.body)["result"]);
      }
      return [];
    });
    List<List<Addition>> additionsListForOneRoom = [];
    for (int i = 0; i < resList.length; i++) {
      List<dynamic> additionListForOneOrder = await GetConnect()
          .post(
        "http://localhost/php-crash/getAdditionInfo.php",
        FormData({
          "sessionID": GetStorage().read("sessionID"),
          "orderID": resList[i]["order_id"],
        }),
      )
          .then((res) {
        if (res.body == null) return [];
        if (jsonDecode(res.body)["status"] == "successed") {
          return jsonDecode(jsonDecode(res.body)["result"]);
        }
        return [];
      });
      List<Addition> list = [];
      for (var service in additionListForOneOrder) {
        list.add(Addition.fromJson(service));
      }
      additionsListForOneRoom.add(list);
    }
    List<Order> oneRoomBookingList = List.generate(
        resList.length,
        (index) => Order.fromJson({}
          ..addAll(resList[index])
          ..addAll({"additionsList": additionsListForOneRoom[index]})));
    return oneRoomBookingList;
  }

  Future<List<Room>> getRoomList() async {
    var roomList = await GetConnect()
        .post(
      "http://localhost/php-crash/getRoom.php",
      FormData({
        "sessionID": GetStorage().read("sessionID"),
      }),
    )
        .then(
      (res) {
        if (res.body == null) return [];
        if (jsonDecode(res.body)["status"] == "successed") {
          return jsonDecode(jsonDecode(res.body)["result"]);
        }
        return [];
      },
    );
    List<Room> list = List.generate(
        roomList.length, (index) => Room.fromJson(roomList[index]));
    return list;
  }

  Future<void> getRoomGroups() async {
    List<RoomGroup> roomGroupsList = [];
    List<Room> roomList = await getRoomList();
    for (Room room in roomList) {
      List<Order> bookingData = await getOrdersForOneRoom(room);
      List<List<Pair>> displayArray =
          await createDisplayListForOneRoom(room, bookingData);
      roomGroupsList.addAll([
        RoomGroup(
          ordersList: bookingData,
          room: room,
          displayArray: displayArray,
        )
      ]);
    }
    Get.find<InternalStorage>().write("roomGroupsList", roomGroupsList);
  }
}
