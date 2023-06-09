import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:project_ii/binding/AuthBinding.dart';
import 'package:project_ii/controller/HomePageController.dart';
import '../controller/AuthController.dart';
import '../controller/CalendarPageController.dart';
import 'BookingPageView.dart';
import 'CalenderPageView.dart';
import 'LoginPageView.dart';
import 'RoomPageView.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Row(
          children: [
            NavigationRail(
              elevation: 8,
              onDestinationSelected: (index) {
                if (index != 0) {
                  Get.find<CalendarPageController>().index = 0;
                }
                Get.find<HomePageController>().homePageIndex = index;
              },
              destinations: const [
                NavigationRailDestination(
                  icon: FaIcon(FontAwesomeIcons.book),
                  selectedIcon: FaIcon(FontAwesomeIcons.bookOpen),
                  label: Text("Lịch đặt phòng"),
                ),
                NavigationRailDestination(
                  icon: FaIcon(FontAwesomeIcons.paw),
                  selectedIcon: FaIcon(FontAwesomeIcons.shieldCat),
                  label: Text("Đặt phòng"),
                ),
                NavigationRailDestination(
                  icon: FaIcon(FontAwesomeIcons.doorClosed),
                  selectedIcon: FaIcon(FontAwesomeIcons.doorOpen),
                  label: Text("Quản lý phòng"),
                ),
                NavigationRailDestination(
                  icon: FaIcon(FontAwesomeIcons.bellConcierge),
                  selectedIcon: FaIcon(FontAwesomeIcons.bellConcierge),
                  label: Text("Quản lý dịch vụ"),
                ),
              ],
              selectedIndex: Get.find<HomePageController>().homePageIndex,
              extended: true,
              trailing: ElevatedButton(
                  onPressed: () {
                    GetConnect().post(
                      "http://localhost/php-crash/logout.php",
                      FormData(
                          {"sessionID": Get.find<AuthController>().sessionID}),
                    );
                    AuthBinding().delete();
                    AuthBinding().dependencies();
                    Get.offAllNamed("/login");
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      FaIcon(FontAwesomeIcons.arrowRightFromBracket, size: 14),
                      Text(" Đăng xuất"),
                    ],
                  )),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: const [
                CalenderPage(),
                BookingPage(),
                RoomPage(),
                Text("child4"),
              ][Get.find<HomePageController>().homePageIndex],
            )
          ],
        ),
      ),
    );
  }
}
