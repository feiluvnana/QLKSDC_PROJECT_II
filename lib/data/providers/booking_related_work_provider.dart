import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/CatModel.dart';
import '../../model/OrderModel.dart';
import '../../model/OwnerModel.dart';
import 'package:http/http.dart' as http;

class BookingRelatedWorkProvider {
  static Future<int> sendOwnerInfo(Owner owner) async {
    return jsonDecode((await http.post(
            Uri.http("localhost", "php-crash/booking_related_work.php"),
            body: {
          "sessionID":
              (await SharedPreferences.getInstance()).getString("sessionID"),
          ...owner.toJson(),
          "flag": "owner"
        }))
        .body)["owner_id"];
  }

  static Future<int> sendCatInfo(Cat cat, int ownerID) async {
    return jsonDecode((await http.post(
            Uri.http("localhost", "php-crash/booking_related_work.php"),
            body: {
          "sessionID":
              (await SharedPreferences.getInstance()).getString("sessionID"),
          "ownerID": ownerID,
          ...cat.toJson(),
          "flag": "cat"
        }))
        .body)["cat_id"];
  }

  static Future<String> sendOrderInfo(Order order, int cid) async {
    return jsonDecode((await http.post(
            Uri.http("localhost", "php-crash/booking_related_work.php"),
            body: {
          "sessionID":
              (await SharedPreferences.getInstance()).getString("sessionID"),
          ...order.toJson(cid),
          "inCharge": (await SharedPreferences.getInstance()).getString("name"),
          "flag": "order"
        }))
        .body)["status"];
  }
}
