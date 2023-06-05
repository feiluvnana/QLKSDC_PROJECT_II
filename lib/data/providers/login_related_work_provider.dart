import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginRelatedWorkProvider {
  static Future<bool> authenticate(
      {required String username, required String password}) async {
    String authString = "$username:${md5.convert(utf8.encode(password))}";
    return await http.post(
      Uri.http("localhost", "php-crash/login_related_work.php"),
      body: {"auth_string": authString, "flag": "login"},
    ).then((res) async {
      if (jsonDecode(res.body)["errors"].length == 0) {
        await (await SharedPreferences.getInstance())
            .setString("session_id", (jsonDecode(res.body)["results"])["id"]);
        await (await SharedPreferences.getInstance())
            .setString("name", (jsonDecode(res.body)["results"])["name"]);
        await (await SharedPreferences.getInstance())
            .setString("role", (jsonDecode(res.body)["results"])["role"]);
        return true;
      } else {
        return false;
      }
    });
  }

  static Future<bool> logout() async {
    return await http.post(
      Uri.http("localhost", "php-crash/login_related_work.php"),
      body: {
        "session_id":
            (await SharedPreferences.getInstance()).getString("session_id"),
        "flag": "logout"
      },
    ).then((res) async {
      if (jsonDecode(res.body)["errors"].length == 0) {
        return true;
      } else {
        return false;
      }
    });
  }
}
