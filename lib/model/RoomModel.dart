import 'package:get/get.dart';

class Room {
  final String roomID, roomType;
  final double price;
  final int subQuantity;

  Room.fromJson(Map<String, dynamic> json)
      : roomID = json["roomID"],
        roomType = json["roomType"],
        price = json["price"],
        subQuantity = json["subQuantity"];

  String getRoomDataToString() {
    return "Mã phòng: $roomID\nGía phòng: ${price.toPrecision(0)}VNĐ";
  }
}
