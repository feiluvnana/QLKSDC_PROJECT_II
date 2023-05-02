class BookingService {
  final int serviceID;
  final String serviceName;
  final double servicePrice;
  final double? serviceDistance;
  final int? serviceQuantity;
  final DateTime? serviceTime;

  BookingService.fromJson(Map<String, dynamic> json)
      : serviceID = json["serviceID"],
        serviceName = json["serviceName"],
        servicePrice = json["servicePrice"],
        serviceDistance = json["serviceDistance"],
        serviceQuantity = json["serviceQuantity"],
        serviceTime = (null == json["serviceTime"])
            ? null
            : DateTime.parse(json["serviceTime"]);
}
