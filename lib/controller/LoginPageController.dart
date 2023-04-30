import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginPageController extends GetxController {
  final TextEditingController _usernameController;
  final TextEditingController _passwordController;
  bool _isClick;
  bool _isLogged;
  bool get isLogged => _isLogged;
  TextEditingController get usernameController => _usernameController;
  TextEditingController get passwordController => _passwordController;

  LoginPageController()
      : _isClick = false,
        _usernameController = TextEditingController(),
        _passwordController = TextEditingController(),
        _isLogged = false;

  void authenticate() async {
    if (_isClick) return;
    _isClick = true;
    Response res = const Response();
    try {
      String authString =
          "${_usernameController.text}:${md5.convert(utf8.encode(_passwordController.text))}";
      print(authString);
      res = await GetConnect().post(
        "http://localhost/php-crash/login.php",
        FormData({"authString": authString}),
      );
      print(res.body);
    } catch (event) {
      Get.defaultDialog(middleText: "Có lỗi khi kết nối với máy chủ.");
    }
    if (jsonDecode(res.body)["success"] && !jsonDecode(res.body)["error"]) {
      await GetStorage().write("sessionID", jsonDecode(res.body)["sessionID"]);
      await GetStorage().write("fullname", jsonDecode(res.body)["fullname"]);
      _isClick = false;
      _isLogged = true;
      Get.toNamed("/home");
    } else {
      Get.defaultDialog(
          title: "Thông báo", middleText: "Tài khoản hoặc mật khẩu sai.");
    }
    _isClick = false;
  }
}
