import 'dart:convert';
import 'package:project_ii/data/providers/booking_related_work_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../model/cat_model.dart';
import '../../model/order_model.dart';
import '../../model/owner_model.dart';

class InfoRelatedWorkProvider {
  static Future<http.Response> saveChanges(Order order, Order order_old) async {
    return http.post(Uri.http("localhost", "php-crash/info_related_work.php"),
        body: <String, String?>{
          "session_id":
              (await SharedPreferences.getInstance()).getString("session_id"),
          "data": jsonEncode({...order.toJson(), "old": order_old.toJson()}),
          "flag": "save"
        });
  }

  static Future<http.Response> checkout(Order old, int fin) async {
    return http
        .post(Uri.http("localhost", "php-crash/info_related_work.php"), body: {
      "session_id":
          (await SharedPreferences.getInstance()).getString("session_id"),
      "flag": "checkout",
      "data": jsonEncode({"old": old.toJson(), "final": fin})
    });
  }

  static Future<http.Response> cancel(Order old) async {
    return http
        .post(Uri.http("localhost", "php-crash/info_related_work.php"), body: {
      "session_id":
          (await SharedPreferences.getInstance()).getString("session_id"),
      "flag": "cancel",
      "data": jsonEncode({"old": old.toJson()})
    });
  }
}
