class Owner {
  final int ownerID;
  final String ownerName, ownerGender, ownerTel;

  Owner.fromJson(Map<String, dynamic> json)
      : ownerID = json["ownerID"],
        ownerGender = json["ownerGender"],
        ownerName = json["ownerName"],
        ownerTel = json["ownerTel"];
}
