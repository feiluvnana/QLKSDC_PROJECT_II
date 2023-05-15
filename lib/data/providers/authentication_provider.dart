import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthenticationProvider {
  static Future<bool> authenticate(
      {required String username, required String password}) async {
    String authString = "$username:${md5.convert(utf8.encode(password))}";
    return await GetConnect()
        .post(
      "http://localhost/php-crash/login.php",
      FormData({"authString": authString}),
    )
        .then((res) async {
      if (jsonDecode(res.body)["status"] == "successed") {
        await GetStorage()
            .write("sessionID", jsonDecode(res.body)["account_session_id"]);
        await GetStorage().write("name", jsonDecode(res.body)["account_name"]);
        await GetStorage().write("role", jsonDecode(res.body)["account_role"]);
        return true;
      } else {
        return false;
      }
    });
  }
}
