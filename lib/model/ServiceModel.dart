class Service {
  final int id;
  final String name;
  final double price;
  final bool distanceNeed, quantityNeed, timeNeed;

  Service.fromJson(Map<String, dynamic> json)
      : id = json["service_id"],
        name = json["service_name"],
        price = json["service_price"],
        distanceNeed = json["service_distance_need"] == 1,
        quantityNeed = json["service_quantity_need"] == 1,
        timeNeed = json["service_time_need"] == 1;
}
