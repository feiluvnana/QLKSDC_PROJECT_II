class Service {
  final int serviceID;
  final String serviceName;
  final double servicePrice;
  final bool requiredDistance, requiredWeight, requiredQuantity;

  Service.fromJson(Map<String, dynamic> json)
      : serviceID = json["serviceID"],
        serviceName = json["serviceName"],
        servicePrice = json["servicePrice"],
        requiredDistance = json["requiredDistance"] == 1,
        requiredWeight = json["requiredWeight"] == 1,
        requiredQuantity = json["requiredQuantity"] == 1;
}
