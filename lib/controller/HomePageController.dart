import 'package:get/get.dart';

class HomePageController extends GetxController {
  RxInt _homePageIndex = 0.obs;

  int get homePageIndex => _homePageIndex.value;
  set homePageIndex(int value) {
    _homePageIndex.value = value;
  }
}
