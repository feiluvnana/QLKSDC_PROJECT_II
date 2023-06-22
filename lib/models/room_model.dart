class Room {
  final String id, type;
  final double price;
  final int total;

  Room.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        type = json["type"],
        price = json["price"],
        total = json["total"];

  Room.empty()
      : id = "",
        type = "",
        price = 0,
        total = 0;

  Map<String, dynamic> toJson() {
    return {"id": id, "type": type, "price": price, "total": total};
  }

  String getRoomDataToString() {
    return "Mã phòng: $id\nGía phòng: ${price.toInt()}VNĐ";
  }
}
