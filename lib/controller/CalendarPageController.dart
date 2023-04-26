import 'dart:convert';
import 'package:get/get.dart';
import 'package:project_ii/controller/AuthController.dart';
import '../model/BookingModel.dart';
import '../model/BookingServiceModel.dart';
import '../model/RoomBookingModel.dart';
import '../model/RoomModel.dart';
import '../utils/DateUtils.dart';
import '../utils/PairUtils.dart';

class CalendarPageController extends GetxController {
  late Map<String, int> _currentMonth;
  late DateTime _today;
  late List<RoomBooking> _roomBookingData;
  late int dayForList;
  late int index;
  late bool _isClicked;

  @override
  void onInit() {
    super.onInit();
    _currentMonth = {"year": 2023, "month": 4};
    _today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _roomBookingData = [];
    dayForList = _today.day;
    index = 0;
    _isClicked = false;
  }

  DateTime get today => _today;

  Map<String, int> get currentMonth => _currentMonth;
  set currentMonth(Map<String, int> map) =>
      _currentMonth = {"year": map["year"]!, "month": map["month"]!};

  List<RoomBooking> get roomBookingData => _roomBookingData;

  void addMonths({required int month}) {
    if (_isClicked) return;
    _isClicked = true;
    print("clicked");
    (_currentMonth)["month"] = ((_currentMonth)["month"])! + month;
    if ((_currentMonth)["month"]! > 12) {
      (_currentMonth)["year"] = ((_currentMonth)["year"])! + 1;
      (_currentMonth)["month"] = ((_currentMonth)["month"])! - 12;
    }
    if ((_currentMonth)["month"]! < 1) {
      (_currentMonth)["year"] = ((_currentMonth)["year"])! - 1;
      (_currentMonth)["month"] = ((_currentMonth)["month"])! + 12;
    }
    _roomBookingData = [];
    getRoomBookingData();
    index = 0;
    update();
    _isClicked = false;
  }

  String printCurrentMonth() {
    return "${(_currentMonth["month"]! < 10) ? "0" : ""}${_currentMonth["month"]}/${_currentMonth["year"]}";
  }

  bool isBeforeToday(int day) {
    return DateTime(_currentMonth["year"]!, _currentMonth["month"]!, day)
        .isBefore(today);
  }

  bool isInCurrentMonth(DateTime date) {
    return DateTime(_currentMonth["year"]!, _currentMonth["month"]!, 1)
            .isBefore(date) &&
        DateTime(_currentMonth["year"]!, _currentMonth["month"]!,
                DateUtils.daysInMonth(_currentMonth))
            .isAfter(date);
  }

  Future<List<List<Pair>>> getDisplayList(Room roomData) async {
    List<Booking> bookingList = await getBookingData(roomData);
    if (bookingList.isEmpty) {
      return List.generate(
          roomData.subQuantity,
          (index) => List.generate(DateUtils.daysInMonth(_currentMonth),
              (index) => Pair(first: -1, second: -1)));
    }
    List<List<Pair>> list = List.generate(
        roomData.subQuantity,
        (index) => List.generate(DateUtils.daysInMonth(_currentMonth),
            (index) => Pair(first: -1, second: -1)));
    for (int i = 0; i < bookingList.length; i++) {
      int startIndex = (!isInCurrentMonth(bookingList[i].dateIn))
          ? 0
          : bookingList[i].dateIn.day - 1;
      bool earlyIn = bookingList[i].dateIn.hour < 14;
      bool roundedIn = !isInCurrentMonth(bookingList[i].dateIn);
      int endIndex = (!isInCurrentMonth(bookingList[i].dateOut))
          ? DateUtils.daysInMonth(_currentMonth) - 1
          : bookingList[i].dateOut.day - 1;
      bool lateOut = (bookingList[i].dateOut.hour > 14) ||
          (bookingList[i].dateOut.hour == 14 &&
              (bookingList[i].dateOut.minute > 0));
      bool roundedOut = !isInCurrentMonth(bookingList[i].dateOut);

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

  Future<List<Booking>> getBookingData(Room roomData) async {
    List<dynamic> bookingResList = jsonDecode((await GetConnect().post(
      "http://localhost/php-crash/getBookingForDisplay.php",
      FormData({
        "sessionID": Get.find<AuthController>().sessionID,
        "roomID": roomData.roomID,
        "month": currentMonth["month"],
        "year": currentMonth["year"]
      }),
    ))
        .body);
    List<List<BookingService>> allServiceList = [];
    for (int i = 0; i < bookingResList.length; i++) {
      List<dynamic> serviceListForABooking =
          jsonDecode((await GetConnect().post(
        "http://localhost/php-crash/getBookingServiceForDisplay.php",
        FormData({
          "sessionID": Get.find<AuthController>().sessionID,
          "bookingID": bookingResList[i]["bookingID"],
        }),
      ))
              .body);
      List<BookingService> list = [];
      for (var service in serviceListForABooking) {
        list.add(BookingService.fromJson(service));
      }
      allServiceList.add(list);
    }
    List<Booking> bookingList = List.generate(
        bookingResList.length,
        (index) => Booking.fromJson({}
          ..addAll(bookingResList[index])
          ..addAll({"bookingServiceList": allServiceList[index]})));
    return bookingList;
  }

  Future<List<Room>> getRoomList() async {
    List<dynamic> roomList = jsonDecode((await GetConnect().post(
      "http://localhost/php-crash/getRoomForDisplay.php",
      FormData({
        "sessionID": Get.find<AuthController>().sessionID,
      }),
    ))
        .body);
    List<Room> list = List.generate(
        roomList.length, (index) => Room.fromJson(roomList[index]));
    return list;
  }

  Future<void> getRoomBookingData() async {
    List<RoomBooking> roomBookingData = [];
    List<Room> roomIDList = await getRoomList();
    for (Room roomData in roomIDList) {
      List<Booking> bookingData = await getBookingData(roomData);
      List<List<Pair>> displayArray = await getDisplayList(roomData);
      roomBookingData.addAll([
        RoomBooking(
          bookingData: bookingData,
          roomData: roomData,
          displayArray: displayArray,
        )
      ]);
    }
    _roomBookingData = roomBookingData;
    update();
  }
}
