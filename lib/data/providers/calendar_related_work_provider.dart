import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/order_model.dart';
import '../../models/room_group_model.dart';
import '../../models/room_model.dart';
import '../dependencies/internal_storage.dart';
import '../types/pair.dart';
import 'room_related_work_provider.dart';
import 'package:http/http.dart' as http;

class CalendarRelatedWorkProvider {
  final DateTime currentMonth;
  final DateTime today;

  const CalendarRelatedWorkProvider(
      {required this.currentMonth, required this.today});

  bool isInCurrentMonth(DateTime date) {
    return currentMonth.year == date.year && currentMonth.month == date.month;
  }

  Future<List<List<Pair>>> createDisplayListForOneRoom(
      Room roomData, List<Order> ordersList) async {
    if (ordersList.isEmpty) {
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
    for (int i = 0; i < ordersList.length; i++) {
      int startIndex = (!isInCurrentMonth(ordersList[i].checkIn))
          ? 0
          : ordersList[i].checkIn.day - 1;
      bool earlyIn = ordersList[i].checkIn.hour < 14;
      bool roundedIn = !isInCurrentMonth(ordersList[i].checkIn);
      int endIndex = (!isInCurrentMonth(ordersList[i].checkOut))
          ? DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month) - 1
          : ordersList[i].checkOut.day - 1;
      bool lateOut = (ordersList[i].checkOut.hour > 14) ||
          (ordersList[i].checkOut.hour == 14 &&
              (ordersList[i].checkOut.minute > 0));
      bool roundedOut = !isInCurrentMonth(ordersList[i].checkOut);

      for (int k = startIndex; k <= endIndex; k++) {
        if (startIndex == endIndex) {
          if (earlyIn || roundedIn) {
            list[ordersList[i].subRoomNum - 1][k].first = i;
          }
          if (lateOut || roundedOut) {
            list[ordersList[i].subRoomNum - 1][k].second = i;
          }
          continue;
        }
        if (earlyIn && k == startIndex) {
          list[ordersList[i].subRoomNum - 1][k].first = i;
        }
        if (startIndex == k) list[ordersList[i].subRoomNum - 1][k].second = i;
        if (startIndex == k && roundedIn) {
          list[ordersList[i].subRoomNum - 1][k].first = i;
        }
        if (lateOut && k == endIndex) {
          list[ordersList[i].subRoomNum - 1][k].second = i;
        }
        if (endIndex == k) list[ordersList[i].subRoomNum - 1][k].first = i;
        if (endIndex == k && roundedOut) {
          list[ordersList[i].subRoomNum - 1][k].second = i;
        }
        if (k > startIndex && k < endIndex) {
          list[ordersList[i].subRoomNum - 1][k] = Pair(first: i, second: i);
        }
      }
    }
    return list;
  }

  Future<List<Order>> getOrdersForOneRoom(Room room) async {
    var resList = await http.post(
      Uri.http("localhost", "php-crash/order.php"),
      body: {
        "session_id":
            (await SharedPreferences.getInstance()).getString("session_id"),
        "data": jsonEncode({
          "room_id": room.id,
          "time": jsonEncode(
              {"month": currentMonth.month, "year": currentMonth.year})
        })
      },
    ).then((res) {
      if (jsonDecode(res.body)["errors"].isEmpty) {
        return jsonDecode(res.body)["results"];
      }
      return [];
    });

    List<Order> ans = [];
    for (int i = 0; i < resList.length; i++) {
      ans.add(Order.fromJson(resList[i]));
    }
    return ans;
  }

  Future<void> getRoomGroups() async {
    List<RoomGroup> roomGroupsList = [];
    List<Room> roomList = await RoomRelatedWorkProvider.getRoomsList();
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
    GetIt.I<InternalStorage>().write("roomGroupsList", roomGroupsList);
  }

  static void clearRoomGroupsList() {
    GetIt.I<InternalStorage>().remove("roomGroupsList");
  }
}
