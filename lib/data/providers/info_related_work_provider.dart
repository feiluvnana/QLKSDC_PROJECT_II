import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../models/order_model.dart';

class InfoRelatedWorkProvider {
  static Future<http.Response> saveChanges(Order order, Order oldOrder) async {
    return http.post(Uri.http("localhost", "php-crash/info_related_work.php"),
        body: <String, String?>{
          "session_id":
              (await SharedPreferences.getInstance()).getString("session_id"),
          "data": jsonEncode({...order.toJson(), "old": oldOrder.toJson()}),
          "flag": "save"
        });
  }

  static Future<http.Response> checkout(Order old, {double? charge}) async {
    return http
        .post(Uri.http("localhost", "php-crash/info_related_work.php"), body: {
      "session_id":
          (await SharedPreferences.getInstance()).getString("session_id"),
      "flag": "checkout",
      "data": jsonEncode(
          {"old": old.toJson(), "charge": charge?.toStringAsFixed(1) ?? "0"}),
    });
  }

  static Future<http.Response> checkin(Order order) async {
    return http.post(
        Uri.http("localhost", "php-crash/booking_related_work.php"),
        body: {
          "session_id":
              (await SharedPreferences.getInstance()).getString("session_id"),
          "data": jsonEncode(order.toJson()),
        });
  }

  static Future<http.Response> cancel(Order old, {double? charge}) async {
    return http
        .post(Uri.http("localhost", "php-crash/info_related_work.php"), body: {
      "session_id":
          (await SharedPreferences.getInstance()).getString("session_id"),
      "flag": "cancel",
      "data": jsonEncode(
          {"old": old.toJson(), "charge": charge?.toStringAsFixed(1) ?? 0}),
    });
  }
}
