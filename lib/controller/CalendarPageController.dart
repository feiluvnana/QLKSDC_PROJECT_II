import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:project_ii/utils/InternalStorage.dart';
import '../model/OrderModel.dart';
import '../model/AdditionModel.dart';
import '../model/RoomGroupModel.dart';
import '../model/RoomModel.dart';
import '../utils/PairUtils.dart';

class CalendarPageController extends GetxController {
  late DateTime _currentMonth, _today;
  late bool _isAddMonthClicked;
  late int _dayForGuestList;
  late int _daysInCurrentMonth;

  @override
  void onInit() {
    super.onInit();
    _today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _currentMonth = DateTime(_today.year, _today.month);
    _isAddMonthClicked = false;
    _dayForGuestList = _today.day;
    _daysInCurrentMonth =
        DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);

    Future.delayed(
            const Duration(seconds: 0), () async => await getRoomGroups())
        .then(
            (value) => update(["guestList", "table", "dayLabel", "monthText"]));
  }

  DateTime get currentMonth => _currentMonth;
  set currentMonth(DateTime value) => _currentMonth = value;
  int get dayForGuestList => _dayForGuestList;
  set dayForGuestList(int value) => _dayForGuestList = value;
  int get daysInCurrentMonth => _daysInCurrentMonth;
  DateTime get today => _today;

  void addMonths({required int value}) async {
    Get.find<InternalStorage>().remove("bookingDataForAllRooms");
    if (_isAddMonthClicked) return;
    _isAddMonthClicked = true;
    if (_currentMonth.month == 12 && value == 1) {
      _currentMonth = DateTime(_currentMonth.year + 1, 1);
    } else if (_currentMonth.month == 1 && value == -1) {
      _currentMonth = DateTime(_currentMonth.year - 1, 12);
    } else {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + value);
    }
    _dayForGuestList = 1;
    _daysInCurrentMonth =
        DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    await getRoomGroups();
    update(["guestList", "table", "dayLabel", "monthText"]);
    _isAddMonthClicked = false;
  }

  bool isBeforeToday(int day) {
    return DateTime(_currentMonth.year, _currentMonth.month, day)
        .isBefore(today);
  }

  bool isInCurrentMonth(DateTime date) {
    return _currentMonth.year == date.year && _currentMonth.month == date.month;
  }

  Future<List<List<Pair>>> createDisplayListForOneRoom(
      Room roomData, List<Order> bookingList) async {
    if (bookingList.isEmpty) {
      return List.generate(
          roomData.total,
          (index) => List.generate(
              DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month),
              (index) => Pair(first: -1, second: -1)));
    }
    List<List<Pair>> list = List.generate(
        roomData.total,
        (index) => List.generate(
            DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month),
            (index) => Pair(first: -1, second: -1)));
    for (int i = 0; i < bookingList.length; i++) {
      int startIndex = (!isInCurrentMonth(bookingList[i].checkIn))
          ? 0
          : bookingList[i].checkIn.day - 1;
      bool earlyIn = bookingList[i].checkIn.hour < 14;
      bool roundedIn = !isInCurrentMonth(bookingList[i].checkIn);
      int endIndex = (!isInCurrentMonth(bookingList[i].checkOut))
          ? DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month) -
              1
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
    update(["guestList", "table", "dayLabel", "monthText"]);
  }
}
