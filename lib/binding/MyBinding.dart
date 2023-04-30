import 'package:get/get.dart';
import '../controller/LoginPageController.dart';
import '../controller/BookingPageController.dart';
import '../controller/HomePageController.dart';
import '../controller/CalendarPageController.dart';

class MyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginPageController(), fenix: true);
    Get.lazyPut(() => HomePageController(), fenix: true);
    Get.lazyPut(() => CalendarPageController(), fenix: true);
    Get.lazyPut(() => BookingPageController(), fenix: true);
  }

  void delete() {
    Get.delete<LoginPageController>();
    Get.delete<HomePageController>();
    Get.delete<CalendarPageController>();
    Get.delete<BookingPageController>();
  }
}
