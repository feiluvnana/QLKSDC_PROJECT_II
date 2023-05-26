class Room {
  final String id, type;
  final double price;
  final int total;

  Room.fromJson(Map<String, dynamic> json)
      : id = json["room_id"],
        type = json["room_type"],
        price = json["room_price"],
        total = json["room_total"];

  Room.empty()
      : id = "",
        type = "",
        price = 0,
        total = 0;

  String getRoomDataToString() {
    return "Mã phòng: $id\nGía phòng: ${price.toInt()}VNĐ";
  }
}
