import 'package:get/get.dart';

class HomePageController extends GetxController {
  int _homePageIndex = 0;

  int get homePageIndex => _homePageIndex;
  set homePageIndex(int value) {
    _homePageIndex = value;
    update();
  }
}
