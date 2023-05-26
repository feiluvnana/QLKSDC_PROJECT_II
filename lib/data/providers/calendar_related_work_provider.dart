import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/AdditionModel.dart';
import '../../model/CatModel.dart';
import '../../model/OrderModel.dart';
import '../../model/OwnerModel.dart';
import '../../model/RoomGroupModel.dart';
import '../../model/RoomModel.dart';
import '../../utils/PairUtils.dart';
import '../dependencies/internal_storage.dart';
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

  Future<Room> getRoomFromID(String rid) async {
    return await http
        .post(Uri.http("localhost", "php-crash/getRoomFromID.php"), body: {
      "sessionID":
          (await SharedPreferences.getInstance()).getString("sessionID"),
      "roomID": rid,
    }).then((res) {
      if (jsonDecode(res.body)["status"] == "successed") {
        return Room.fromJson(jsonDecode(jsonDecode(res.body)["result"]));
      }
      return Room.empty();
    });
  }

  Future<Owner> getOwnerFromID(int oid) async {
    return await http
        .post(Uri.http("localhost", "php-crash/getOwnerFromID.php"), body: {
      "sessionID":
          (await SharedPreferences.getInstance()).getString("sessionID"),
      "ownerID": oid.toString(),
    }).then((res) {
      if (jsonDecode(res.body)["status"] == "successed") {
        return Owner.fromJson(jsonDecode(jsonDecode(res.body)["result"]));
      }
      return Owner.empty();
    });
  }

  Future<Cat> getCatFromID(int cid) async {
    return await http
        .post(Uri.http("localhost", "php-crash/getCatFromID.php"), body: {
      "sessionID":
          (await SharedPreferences.getInstance()).getString("sessionID"),
      "catID": cid.toString(),
    }).then((res) async {
      if (jsonDecode(res.body)["status"] == "successed") {
        return Cat.fromJson(
            jsonDecode(jsonDecode(res.body)["result"]),
            await getOwnerFromID(
                jsonDecode(jsonDecode(res.body)["result"])["owner_id"]));
      }
      return Cat.empty();
    });
  }

  Future<List<Order>> getOrdersForOneRoom(Room room) async {
    var resList = await http.post(
      Uri.http("localhost", "php-crash/getOrderInfo.php"),
      body: {
        "sessionID":
            (await SharedPreferences.getInstance()).getString("sessionID"),
        "roomID": room.id,
        "month": currentMonth.month.toString(),
        "year": currentMonth.year.toString()
      },
    ).then((res) {
      if (jsonDecode(res.body)["status"] == "successed") {
        return jsonDecode(jsonDecode(res.body)["result"]);
      }
      return [];
    });
    List<List<Addition>> additionsListForOneRoom = [];
    for (int i = 0; i < resList.length; i++) {
      List<dynamic> additionListForOneOrder = await http.post(
        Uri.http("localhost", "php-crash/getAdditionInfo.php"),
        body: {
          "sessionID":
              (await SharedPreferences.getInstance()).getString("sessionID"),
          "orderID": resList[i]["order_id"].toString(),
        },
      ).then((res) {
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
    List<Order> ordersListForOneRoom = [];
    for (int i = 0; i < resList.length; i++) {
      Cat cat = await getCatFromID(resList[i]["cat_id"]);
      Room room = await getRoomFromID(resList[i]["room_id"]);
      ordersListForOneRoom.add(Order.fromJson(
          {}
            ..addAll(resList[i])
            ..addAll({"additionsList": additionsListForOneRoom[i]}),
          room,
          cat));
    }
    return ordersListForOneRoom;
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
}
