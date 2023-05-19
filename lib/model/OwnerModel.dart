class Owner {
  final int id;
  final String name, gender, tel;

  Owner.fromJson(Map<String, dynamic> json)
      : id = json["ownerID"],
        gender = json["ownerGender"],
        name = json["ownerName"],
        tel = json["ownerTel"];

  Map<String, dynamic> toJson() {
    return {
      "ownerID": id,
      "ownerTel": tel,
      "ownerName": name,
      "ownerGender": gender
    };
  }
}
