import 'package:get/get.dart';
import 'package:project_ii/blocs/InformationPageController.dart';
import '../utils/InternalStorage.dart';

class MyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InformationPageController(), fenix: true);
    Get.put(InternalStorage(), permanent: true);
  }

  void delete() {
    Get.deleteAll(force: true);
  }
}
