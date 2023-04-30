import 'package:get/get.dart';

class Room {
  final String roomID, roomType;
  final double roomPrice;
  final int subQuantity;

  Room.fromJson(Map<String, dynamic> json)
      : roomID = json["roomID"],
        roomType = json["roomType"],
        roomPrice = json["roomPrice"],
        subQuantity = json["subQuantity"];

  String getRoomDataToString() {
    return "Mã phòng: $roomID\nGía phòng: ${roomPrice.toPrecision(0)}VNĐ";
  }
}
