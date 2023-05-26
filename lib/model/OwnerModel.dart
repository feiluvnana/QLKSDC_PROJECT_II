class Owner {
  final String name, gender, tel;

  Owner.fromJson(Map<String, dynamic> json)
      : gender = json["owner_gender"],
        name = json["owner_name"],
        tel = json["owner_tel"];

  Owner.empty()
      : gender = "",
        name = "",
        tel = "";

  Map<String, String> toJson() {
    return {"ownerTel": tel, "ownerName": name, "ownerGender": gender};
  }
}
