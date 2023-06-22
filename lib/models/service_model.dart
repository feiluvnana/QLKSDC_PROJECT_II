class Service {
  final int id;
  final String name;
  final double price;
  final bool distanceNeed, quantityNeed, timeNeed;

  Service.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        price = json["price"],
        distanceNeed = json["d_need"] == 1,
        quantityNeed = json["q_need"] == 1,
        timeNeed = json["t_need"] == 1;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "price": price,
      "d_need": distanceNeed ? 1 : 0,
      "t_need": timeNeed ? 1 : 0,
      "q_need": quantityNeed ? 1 : 0,
    };
  }
}
