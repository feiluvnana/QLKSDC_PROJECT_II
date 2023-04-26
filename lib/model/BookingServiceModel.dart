class BookingService {
  final int serviceID;
  final String serviceName;
  final double servicePrice;
  final double? distance;
  final int? quantity;
  final DateTime? time;

  BookingService.fromJson(Map<String, dynamic> json)
      : serviceID = json["serviceID"],
        serviceName = json["serviceName"],
        servicePrice = json["servicePrice"],
        distance = json["distance"],
        quantity = json["quantity"],
        time = (null == json["time"]) ? null : DateTime.parse(json["time"]);
}
