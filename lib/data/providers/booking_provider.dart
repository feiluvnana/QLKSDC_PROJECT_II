import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../model/CatModel.dart';
import '../../model/OrderModel.dart';
import '../../model/OwnerModel.dart';

class BookingProvider {
  static Future<int> sendOwnerInfo(Owner owner) async {
    return jsonDecode((await GetConnect().post(
            "http://localhost/php-crash/setOwnerInfo.php",
            FormData({
              "sessionID": GetStorage().read("sessionID"),
              ...owner.toJson()
            })))
        .body)["owner_id"];
  }

  static Future<int> sendCatInfo(Cat cat, int ownerID) async {
    return jsonDecode((await GetConnect().post(
            "http://localhost/php-crash/setCatInfo.php",
            FormData({
              "sessionID": GetStorage().read("sessionID"),
              "ownerID": ownerID,
              ...cat.toJson()
            })))
        .body)["cat_id"];
  }

  static Future<String> sendOrderInfo(Order order, int cid) async {
    return jsonDecode((await GetConnect().post(
            "http://localhost/php-crash/setOrderInfo.php",
            FormData({
              "sessionID": GetStorage().read("sessionID"),
              ...order.toJson(cid),
              "inCharge": GetStorage().read("name"),
            })))
        .body)["status"];
  }
}
