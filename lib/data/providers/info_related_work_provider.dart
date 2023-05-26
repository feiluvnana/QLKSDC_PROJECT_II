import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../model/OrderModel.dart';

class InfoRelatedWorkProvider {
  static Future<String> saveChanges(Order order, Order old) async {
    return await http
        .post(Uri.http("localhost", "php-crash/info_related_work.php"), body: {
      "sessionID":
          (await SharedPreferences.getInstance()).getString("sessionID"),
      "name": (await SharedPreferences.getInstance()).getString("name"),
      ...order.toJson(-1),
      "flag": "save",
      "date_old": old.date.toString(),
      "checkIn_old": old.checkIn.toString(),
      "checkOut_old": old.checkOut.toString(),
      "roomID_old": old.room.id
    }).then((res) {
      if (jsonDecode(res.body)["status"] == "successed") return "successed";
      return "failed";
    });
  }
}
