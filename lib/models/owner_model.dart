class Owner {
  final String name, gender, tel;

  Owner.fromJson(Map<String, dynamic> json)
      : gender = json["gender"],
        name = json["name"],
        tel = json["tel"];

  Owner.empty()
      : gender = "",
        name = "",
        tel = "";

  Map<String, String> toJson() {
    return {"tel": tel, "name": name, "gender": gender};
  }
}
