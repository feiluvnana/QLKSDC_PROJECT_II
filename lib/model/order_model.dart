import 'dart:convert';
import 'package:intl/intl.dart';

import 'cat_model.dart';
import 'addition_model.dart';
import 'room_model.dart';

class Order {
  final DateTime date, checkIn, checkOut;
  final Room room;
  final Cat cat;
  final String inCharge;
  final String? note, attention;
  final int subRoomNum, eatingRank, billNum;
  final List<Addition>? additionsList;
  final bool isOut;

  Order.fromJson(Map<String, dynamic> json)
      : date = DateTime.parse(json["date"]),
        checkIn = DateTime.parse(json["checkin"]),
        checkOut = DateTime.parse(json["checkout"]),
        attention = json["attention"],
        note = json["note"],
        inCharge = json["incharge"],
        subRoomNum = json["subroom_num"],
        eatingRank = json["eating_rank"],
        additionsList = List.generate(json["additions_list"].length,
            (index) => Addition.fromJson(json["additions_list"][index])),
        cat = Cat.fromJson(json["cat"]),
        room = Room.fromJson(json["room"]),
        billNum = json["bill_num"],
        isOut = json["is_out"] == 0 ? false : true;

  Order.empty()
      : date = DateTime.now(),
        checkIn = DateTime.now(),
        checkOut = DateTime.now(),
        attention = null,
        note = null,
        inCharge = "",
        subRoomNum = -1,
        eatingRank = -1,
        cat = Cat.empty(),
        room = Room.empty(),
        billNum = -1,
        additionsList = null,
        isOut = false;

  Map<String, dynamic> toJson() {
    return {
      "room_id": room.id,
      "subroom_num": subRoomNum,
      "date": date.toString(),
      "checkin": checkIn.toString(),
      "checkout": checkOut.toString(),
      "attention": attention ?? "",
      "note": note ?? "",
      "eating_rank": eatingRank,
      "additions_list": (additionsList == null)
          ? null
          : List.generate(additionsList?.length ?? 0,
              (index) => additionsList?[index].toJson()),
      "cat": cat.toJson(),
      "room": room.toJson(),
    };
  }

  String getBookingInfoToString() {
    return "Mèo: ${cat.name}\nCheck-in:${DateFormat("dd/MM/yyyy HH:mm").format(checkIn)} \nCheck-out:${DateFormat("dd/MM/yyyy HH:mm").format(checkOut)} \nGhi chú: $note\nLễ tân tiếp nhận: $inCharge\nNgày đặt phòng: ${DateFormat("dd/MM/yyyy HH:mm").format(date)}";
  }
}
