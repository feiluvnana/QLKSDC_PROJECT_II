class Owner {
  final int id;
  final String name, gender, tel;

  Owner.fromJson(Map<String, dynamic> json)
      : id = json["ownerID"],
        gender = json["ownerGender"],
        name = json["ownerName"],
        tel = json["ownerTel"];
}
