import 'package:flutter/src/widgets/navigator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../controller/BookingPageController.dart';
import '../controller/CalendarPageController.dart';

class HomePageMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (GetStorage().read("sessionID") == null) {
      return const RouteSettings(name: "/login");
    }
    return null;
  }
}
