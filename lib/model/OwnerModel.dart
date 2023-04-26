class Owner {
  final int ownerID;
  final String ownerName, ownerGender, tel;

  Owner.fromJson(Map<String, dynamic> json)
      : ownerID = json["ownerID"],
        ownerGender = json["ownerGender"],
        ownerName = json["ownerName"],
        tel = json["tel"];
}
