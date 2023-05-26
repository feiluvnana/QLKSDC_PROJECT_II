import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginRelatedWorkProvider {
  static Future<bool> authenticate(
      {required String username, required String password}) async {
    String authString = "$username:${md5.convert(utf8.encode(password))}";
    return await http.post(
      Uri.http("localhost", "php-crash/login.php"),
      body: {"authString": authString},
    ).then((res) async {
      if (jsonDecode(res.body)["status"] == "successed") {
        await (await SharedPreferences.getInstance())
            .setString("sessionID", jsonDecode(res.body)["account_session_id"]);
        await (await SharedPreferences.getInstance())
            .setString("name", jsonDecode(res.body)["account_name"]);
        await (await SharedPreferences.getInstance())
            .setString("role", jsonDecode(res.body)["account_role"]);
        return true;
      } else {
        return false;
      }
    });
  }
}
