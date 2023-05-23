import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../model/AdditionModel.dart';
import '../../model/CatModel.dart';
import '../../model/OrderModel.dart';
import '../../model/OwnerModel.dart';
import '../../model/RoomGroupModel.dart';
import '../../model/RoomModel.dart';
import '../../utils/InternalStorage.dart';
import '../../utils/PairUtils.dart';

class BackendDataProvider {
  final DateTime currentMonth;
  final DateTime today;

  const BackendDataProvider({required this.currentMonth, required this.today});

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
    return await GetConnect()
        .post(
            "http://localhost/php-crash/getRoomFromID.php",
            FormData({
              "sessionID": GetStorage().read("sessionID"),
              "roomID": rid,
            }))
        .then((res) {
      if (res.body == null) return Room.empty();
      if (jsonDecode(res.body)["status"] == "successed") {
        return Room.fromJson(jsonDecode(jsonDecode(res.body)["result"]));
      }
      return Room.empty();
    });
  }

  Future<Owner> getOwnerFromID(int oid) async {
    return await GetConnect()
        .post(
            "http://localhost/php-crash/getOwnerFromID.php",
            FormData({
              "sessionID": GetStorage().read("sessionID"),
              "ownerID": oid,
            }))
        .then((res) {
      if (res.body == null) return Owner.empty();
      if (jsonDecode(res.body)["status"] == "successed") {
        return Owner.fromJson(jsonDecode(jsonDecode(res.body)["result"]));
      }
      return Owner.empty();
    });
  }

  Future<Cat> getCatFromID(int cid) async {
    return await GetConnect()
        .post(
            "http://localhost/php-crash/getCatFromID.php",
            FormData({
              "sessionID": GetStorage().read("sessionID"),
              "catID": cid,
            }))
        .then((res) async {
      if (res.body == null) return Cat.empty();
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
