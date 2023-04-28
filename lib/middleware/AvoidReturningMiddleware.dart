import 'package:flutter/src/widgets/navigator.dart';
import 'package:get/get.dart';
import '../controller/AuthController.dart';

class AvoidReturningMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final AuthController authController = Get.find<AuthController>();
    if (authController.sessionID != null && route == "/login")
      return const RouteSettings(name: "/home");
  }
}
