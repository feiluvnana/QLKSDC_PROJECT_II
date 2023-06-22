class History {
  int id;
  String action, perfomer;
  String time, details;

  History.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        action = json["action"],
        time = json["time"],
        perfomer = json["perfomer"],
        details = json["details"];
}
