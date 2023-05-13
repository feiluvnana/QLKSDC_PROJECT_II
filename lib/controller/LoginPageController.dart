import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginPageController extends GetxController {
  final TextEditingController _usernameController;
  final TextEditingController _passwordController;
  bool _isClick;
  TextEditingController get usernameController => _usernameController;
  TextEditingController get passwordController => _passwordController;

  LoginPageController()
      : _isClick = false,
        _usernameController = TextEditingController(),
        _passwordController = TextEditingController();

  void authenticate() async {
    if (_isClick) return;
    _isClick = true;
    String authString =
        "${_usernameController.text}:${md5.convert(utf8.encode(_passwordController.text))}";
    print(authString);
    await GetConnect()
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
        _isClick = false;
        Get.offNamed("/home");
      } else {
        Get.defaultDialog(
            title: "Thông báo", middleText: "Đăng nhập thất bại.");
      }
    });
    _isClick = false;
  }
}
