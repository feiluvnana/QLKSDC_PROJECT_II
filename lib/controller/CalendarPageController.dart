import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../model/BookingModel.dart';
import '../model/BookingServiceModel.dart';
import '../model/RoomBookingModel.dart';
import '../model/RoomModel.dart';
import '../utils/PairUtils.dart';

class CalendarPageController extends GetxController {
  late DateTime _currentMonth, _today;
  late List<RoomBooking> _bookingDataForAllRooms;
  late bool _isAddMonthClicked;
  late int _dayForGuestList;
  late int _daysInCurrentMonth;

  @override
  void onInit() {
    super.onInit();
    _today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _currentMonth = DateTime(_today.year, _today.month);
    _bookingDataForAllRooms = [];
    _isAddMonthClicked = false;
    _dayForGuestList = _today.day;
    _daysInCurrentMonth =
        DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    Future.delayed(const Duration(seconds: 0),
            () async => await getBookingDataForAllRooms())
        .then(
            (value) => update(["guestList", "table", "dayLabel", "monthText"]));
  }

  DateTime get currentMonth => _currentMonth;
  set currentMonth(DateTime value) => _currentMonth = value;
  int get dayForGuestList => _dayForGuestList;
  set dayForGuestList(int value) => _dayForGuestList = value;
  int get daysInCurrentMonth => _daysInCurrentMonth;
  DateTime get today => _today;
  List<RoomBooking> get bookingDataForAllRooms => _bookingDataForAllRooms;

  void addMonths({required int value}) async {
    if (_isAddMonthClicked) return;
    _isAddMonthClicked = true;
    print("clicked");
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
    _bookingDataForAllRooms = [];
    await getBookingDataForAllRooms();
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
      Room roomData, List<Booking> bookingList) async {
    if (bookingList.isEmpty) {
      return List.generate(
          roomData.subQuantity,
          (index) => List.generate(
              DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month),
              (index) => Pair(first: -1, second: -1)));
    }
    List<List<Pair>> list = List.generate(
        roomData.subQuantity,
        (index) => List.generate(
            DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month),
            (index) => Pair(first: -1, second: -1)));
    for (int i = 0; i < bookingList.length; i++) {
      int startIndex = (!isInCurrentMonth(bookingList[i].checkInDate))
          ? 0
          : bookingList[i].checkInDate.day - 1;
      bool earlyIn = bookingList[i].checkInDate.hour < 14;
      bool roundedIn = !isInCurrentMonth(bookingList[i].checkInDate);
      int endIndex = (!isInCurrentMonth(bookingList[i].checkOutDate))
          ? DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month) -
              1
          : bookingList[i].checkOutDate.day - 1;
      bool lateOut = (bookingList[i].checkOutDate.hour > 14) ||
          (bookingList[i].checkOutDate.hour == 14 &&
              (bookingList[i].checkOutDate.minute > 0));
      bool roundedOut = !isInCurrentMonth(bookingList[i].checkOutDate);

      for (int k = startIndex; k <= endIndex; k++) {
        if (earlyIn && k == startIndex) {
          list[bookingList[i].subNumber - 1][k].first = i;
        }
        if (startIndex == k) list[bookingList[i].subNumber - 1][k].second = i;
        if (startIndex == k && roundedIn)
          list[bookingList[i].subNumber - 1][k].first = i;
        if (lateOut && k == endIndex) {
          list[bookingList[i].subNumber - 1][k].second = i;
        }
        if (endIndex == k) list[bookingList[i].subNumber - 1][k].first = i;
        if (endIndex == k && roundedOut)
          list[bookingList[i].subNumber - 1][k].second = i;
        if (k > startIndex && k < endIndex) {
          list[bookingList[i].subNumber - 1][k] = Pair(first: i, second: i);
        }
      }
    }
    return list;
  }

  Future<List<Booking>> getBookingDataForOneRoom(Room roomData) async {
    List<dynamic> oneRoomBookingListFromRes =
        jsonDecode((await GetConnect().post(
      "http://localhost/php-crash/getBookingForDisplay.php",
      FormData({
        "sessionID": GetStorage().read("sessionID"),
        "roomID": roomData.roomID,
        "month": currentMonth.month,
        "year": currentMonth.year
      }),
    ))
            .body);
    List<List<BookingService>> allServiceListForOneRoom = [];
    for (int i = 0; i < oneRoomBookingListFromRes.length; i++) {
      List<dynamic> serviceListForOneRoomBooking =
          jsonDecode((await GetConnect().post(
        "http://localhost/php-crash/getBookingServiceForDisplay.php",
        FormData({
          "sessionID": GetStorage().read("sessionID"),
          "bookingID": oneRoomBookingListFromRes[i]["bookingID"],
        }),
      ))
              .body);
      List<BookingService> list = [];
      for (var service in serviceListForOneRoomBooking) {
        list.add(BookingService.fromJson(service));
      }
      allServiceListForOneRoom.add(list);
    }
    List<Booking> oneRoomBookingList = List.generate(
        oneRoomBookingListFromRes.length,
        (index) => Booking.fromJson({}
          ..addAll(oneRoomBookingListFromRes[index])
          ..addAll({"bookingServiceList": allServiceListForOneRoom[index]})));
    return oneRoomBookingList;
  }

  Future<List<Room>> getRoomList() async {
    List<dynamic> roomList = jsonDecode((await GetConnect().post(
      "http://localhost/php-crash/getRoomForDisplay.php",
      FormData({
        "sessionID": GetStorage().read("sessionID"),
      }),
    ))
        .body);
    List<Room> list = List.generate(
        roomList.length, (index) => Room.fromJson(roomList[index]));
    return list;
  }

  Future<void> getBookingDataForAllRooms() async {
    List<RoomBooking> roomBookingData = [];
    List<Room> roomIDList = await getRoomList();
    for (Room roomData in roomIDList) {
      List<Booking> bookingData = await getBookingDataForOneRoom(roomData);
      List<List<Pair>> displayArray =
          await createDisplayListForOneRoom(roomData, bookingData);
      roomBookingData.addAll([
        RoomBooking(
          bookingData: bookingData,
          roomData: roomData,
          displayArray: displayArray,
        )
      ]);
    }
    _bookingDataForAllRooms = roomBookingData;
    update(["guestList", "table", "dayLabel", "monthText"]);
  }
}
