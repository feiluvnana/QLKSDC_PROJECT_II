import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:project_ii/controller/home_page_bloc.dart';
import 'BookingPageView.dart';
import 'CalendarPageView.dart';
import 'RoomPageView.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => HomePageCubit(),
        child: BlocBuilder<HomePageCubit, int>(
          builder: (context, state) => Row(
            children: [
              NavigationRail(
                elevation: 12,
                onDestinationSelected: (index) {
                  BlocProvider.of<HomePageCubit>(context).goto(index);
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
                selectedIndex: state,
                extended: true,
                trailing: ElevatedButton(
                    onPressed: () async {
                      await GetConnect().post(
                        "http://localhost/php-crash/logout.php",
                        FormData({"sessionID": GetStorage().read("sessionID")}),
                      );
                      await GetStorage().erase();
                      Get.offAllNamed("/login");
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        FaIcon(FontAwesomeIcons.arrowRightFromBracket,
                            size: 14),
                        Text(" Đăng xuất"),
                      ],
                    )),
              ),
              Expanded(
                child: const [
                  CalenderPage(),
                  BookingPage(),
                  RoomPage(),
                  Text("child4"),
                ][state],
              )
            ],
          ),
        ),
      ),
    );
  }
}
