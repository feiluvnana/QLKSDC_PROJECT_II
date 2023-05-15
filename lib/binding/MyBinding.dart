import 'package:get/get.dart';
import 'package:project_ii/controller/InformationPageController.dart';
import '../controller/login_page_bloc.dart';
import '../controller/BookingPageController.dart';
import '../controller/home_page_bloc.dart';
import '../controller/calendar_page_bloc.dart';
import '../utils/InternalStorage.dart';

class MyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BookingPageController(), fenix: true);
    Get.lazyPut(() => InformationPageController(), fenix: true);
    Get.put(InternalStorage(), permanent: true);
  }

  void delete() {
    Get.deleteAll(force: true);
  }
}
