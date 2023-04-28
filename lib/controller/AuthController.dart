import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'BookingPageController.dart';
import 'CalendarPageController.dart';

class AuthController extends GetxController {
  String? _sessionID;
  final TextEditingController _usernameController;
  final TextEditingController _passwordController;
  bool _isClick;
  bool _isLogged;

  String? get sessionID => _sessionID;

  bool get isLogged => _isLogged;

  TextEditingController get usernameController => _usernameController;
  TextEditingController get passwordController => _passwordController;

  AuthController()
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
      _sessionID = jsonDecode(res.body)["sessionID"];
      _isClick = false;
      _isLogged = true;
      update();
      initHomePage();
    } else {
      Get.defaultDialog(
          title: "Thông báo", middleText: "Tài khoản hoặc mật khẩu sai.");
    }
    _isClick = false;
  }

  Future<void> initHomePage() async {
    await Get.find<CalendarPageController>().getRoomBookingData();
    await Get.find<BookingPageController>().getServiceInfo();
    //await Future.delayed(const Duration(seconds: 2));
    Get.toNamed("/home");
  }
}
