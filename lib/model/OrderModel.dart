import 'dart:convert';
import 'CatModel.dart';
import 'AdditionModel.dart';
import 'RoomModel.dart';

class Order {
  final DateTime date, checkIn, checkOut;
  final Room room;
  final Cat cat;
  final String inCharge;
  final String? note, attention;
  final int subRoomNum, eatingRank;
  final List<Addition>? additionsList;

  Order.fromJson(Map<String, dynamic> json, this.room, this.cat)
      : date = DateTime.parse(json["order_date"]),
        checkIn = DateTime.parse(json["order_checkin"]),
        checkOut = DateTime.parse(json["order_checkout"]),
        attention = json["order_attention"],
        note = json["order_note"],
        inCharge = json["order_incharge"],
        subRoomNum = json["order_subroom_num"],
        eatingRank = json["order_eating_rank"],
        additionsList = json["additionsList"];

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
        additionsList = null;

  Map<String, String> toJson(int cid) {
    return {
      "catID": cid.toString(),
      "roomID": room.id,
      "subRoomNum": subRoomNum.toString(),
      "date": date.toString(),
      "checkIn": checkIn.toString(),
      "checkOut": checkOut.toString(),
      "attention": attention ?? "",
      "note": note ?? "",
      "eatingRank": eatingRank.toString(),
      "additionsList": (additionsList == null)
          ? null.toString()
          : jsonEncode(List.generate(additionsList?.length ?? 0, (index) {
              additionsList?[index].time == checkIn;
              additionsList?[index].time == checkOut;
              return {
                "serviceID": additionsList?[index].serviceID,
                "additionTime": (additionsList?[index].time == null)
                    ? null
                    : additionsList?[index].time.toString(),
                "additionQuantity": (additionsList?[index].quantity == null)
                    ? null
                    : additionsList?[index].quantity,
                "additionDistance": (additionsList?[index].distance == null)
                    ? null
                    : additionsList?[index].distance,
              };
            }))
    };
  }

  String getBookingInfoToString() {
    return "Mèo: ${cat.name}\nCheck-in: \nCheck-out: \nGhi chú: $note\nLễ tân tiếp nhận: $inCharge\nNgày đặt phòng: ";
  }
}
