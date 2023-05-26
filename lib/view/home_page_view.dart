import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:project_ii/blocs/home_page_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project_ii/data/dependencies/internal_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => HomePageBloc(),
        child: BlocBuilder<HomePageBloc, HomeState>(
          builder: (context, state) => Row(
            children: [
              NavigationRail(
                elevation: 12,
                onDestinationSelected: (index) =>
                    BlocProvider.of<HomePageBloc>(context)
                        .add(TabChangedEvent(index, primaryFocus)),
                destinations: const [
                  NavigationRailDestination(
                    icon: FaIcon(FontAwesomeIcons.book),
                    selectedIcon: FaIcon(FontAwesomeIcons.bookOpen),
                    label: Text("Lịch đặt phòng"),
                  ),
                  NavigationRailDestination(
                    icon: FaIcon(FontAwesomeIcons.paw),
                    label: Text("Đặt phòng"),
                  ),
                  NavigationRailDestination(
                    icon: FaIcon(FontAwesomeIcons.doorClosed),
                    selectedIcon: FaIcon(FontAwesomeIcons.doorOpen),
                    label: Text("Quản lý phòng"),
                  ),
                  NavigationRailDestination(
                    icon: FaIcon(FontAwesomeIcons.bellConcierge),
                    label: Text("Quản lý dịch vụ"),
                  ),
                  NavigationRailDestination(
                    icon: FaIcon(FontAwesomeIcons.moneyBill),
                    label: Text("Thống kê"),
                  ),
                  NavigationRailDestination(
                    icon: FaIcon(FontAwesomeIcons.clock),
                    label: Text("Lịch sử"),
                  ),
                ],
                selectedIndex: state.selectedIndex,
                extended: MediaQuery.of(context).size.width > 800,
                trailing: ElevatedButton(
                    onPressed: () async {
                      await http.post(
                        Uri.http("localhost", "php-crash/logout.php"),
                        body: {
                          "sessionID":
                              GetIt.I<InternalStorage>().read("sessionID")
                        },
                      );
                      await (await SharedPreferences.getInstance()).clear();
                      // ignore: use_build_context_synchronously
                      context.go("/login");
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(FontAwesomeIcons.arrowRightFromBracket,
                            size: 14),
                        Text(" Đăng xuất"),
                      ],
                    )),
              ),
              Expanded(
                child: IndexedStack(
                  index: state.selectedIndex,
                  children: List.generate(
                      6, (index) => Builder(builder: state.builders[index])),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
