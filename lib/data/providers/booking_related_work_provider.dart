import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/order_model.dart';
import 'package:http/http.dart' as http;

class BookingRelatedWorkProvider {
  static Future<http.Response> sendOrderInfo(Order order) async {
    return http.post(
        Uri.http("localhost", "php-crash/booking_related_work.php"),
        body: {
          "session_id":
              (await SharedPreferences.getInstance()).getString("session_id"),
          "data": jsonEncode(order.toJson()),
        });
  }
}
