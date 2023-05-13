class Addition {
  final int serviceID;
  final String serviceName;
  final double servicePrice;
  final String? distance;
  final int? quantity;
  final DateTime? time;

  Addition.fromJson(Map<String, dynamic> json)
      : serviceID = json["service_id"],
        serviceName = json["service_name"],
        servicePrice = json["service_price"],
        distance = json["addition_distance"],
        quantity = json["addition_quantity"],
        time = json["addition_time"] == null
            ? null
            : DateTime.parse(json["addition_time"]);
}
