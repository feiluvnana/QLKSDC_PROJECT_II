import 'package:get/get.dart';
import '../controller/AuthController.dart';
import '../controller/BookingPageController.dart';
import '../controller/HomePageController.dart';
import '../controller/CalendarPageController.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.lazyPut(() => HomePageController(), fenix: true);
    Get.lazyPut(() => CalendarPageController(), fenix: true);
    Get.lazyPut(() => BookingPageController(), fenix: true);
  }

  void delete() {
    Get.delete<AuthController>(force: true);
    Get.delete<HomePageController>();
    Get.delete<CalendarPageController>();
    Get.delete<BookingPageController>();
  }
}
