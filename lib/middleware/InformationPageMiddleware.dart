import 'package:flutter/src/widgets/navigator.dart';
import 'package:get/get.dart';
import 'package:project_ii/controller/CalendarPageController.dart';

import '../utils/InternalStorage.dart';

class InformationPageMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (Get.find<InternalStorage>().read("allServiceList") == null) {}
    if (!Get.isRegistered<CalendarPageController>()) {
      return const RouteSettings(name: "/home");
    }
    return null;
  }
}
