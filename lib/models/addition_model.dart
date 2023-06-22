class Addition {
  final int serviceID;
  final String? distance;
  final int? quantity;
  final DateTime? time;

  Addition.fromJson(Map<String, dynamic> json)
      : serviceID = json["service_id"],
        distance = json["distance"],
        quantity = json["quantity"],
        time = json["time"] == null ? null : DateTime.parse(json["time"]);

  Addition.empty()
      : serviceID = -1,
        distance = null,
        time = null,
        quantity = null;

  Map<String, dynamic> toJson() {
    return {
      "service_id": serviceID,
      "time": time?.toString(),
      "distance": distance,
      "quantity": quantity
    };
  }
}
