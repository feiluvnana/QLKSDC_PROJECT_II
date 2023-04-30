class BookingService {
  final int serviceID;
  final String serviceName;
  final double servicePrice;
  final double? serviceDistance;
  final int? quantity;
  final DateTime? time;

  BookingService.fromJson(Map<String, dynamic> json)
      : serviceID = json["serviceID"],
        serviceName = json["serviceName"],
        servicePrice = json["servicePrice"],
        serviceDistance = json["serviceDistance"],
        quantity = json["serviceQuantity"],
        time = (null == json["serviceTime"])
            ? null
            : DateTime.parse(json["serviceTime"]);
}
