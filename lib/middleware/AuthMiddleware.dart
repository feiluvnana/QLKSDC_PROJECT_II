import 'package:flutter/src/widgets/navigator.dart';
import 'package:get/get.dart';
import '../controller/AuthController.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final AuthController authController = Get.find<AuthController>();
    return authController.sessionID == null
        ? const RouteSettings(name: "/login")
        : null;
  }
}
