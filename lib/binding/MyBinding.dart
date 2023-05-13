import 'package:get/get.dart';
import 'package:project_ii/controller/InformationPageController.dart';
import '../controller/LoginPageController.dart';
import '../controller/BookingPageController.dart';
import '../controller/HomePageController.dart';
import '../controller/CalendarPageController.dart';
import '../utils/InternalStorage.dart';

class MyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginPageController(), fenix: true);
    Get.lazyPut(() => HomePageController(), fenix: true);
    Get.lazyPut(() => CalendarPageController(), fenix: true);
    Get.lazyPut(() => BookingPageController(), fenix: true);
    Get.lazyPut(() => InformationPageController(), fenix: true);
    Get.put(InternalStorage(), permanent: true);
  }

  void delete() {
    Get.deleteAll(force: true);
  }
}
