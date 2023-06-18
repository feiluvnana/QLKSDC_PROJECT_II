import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ii/blocs/home_page_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => HomePageBloc(),
        child: BlocBuilder<HomePageBloc, HomeState>(builder: (context, state) {
          BlocProvider.of<HomePageBloc>(context).add(RequireDataEvent());
          return Row(
            children: [
              NavigationRail(
                elevation: 12,
                onDestinationSelected: (index) =>
                    BlocProvider.of<HomePageBloc>(context)
                        .add(ChangeTabEvent(index, primaryFocus)),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.book),
                    label: Text("Lịch đặt phòng"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.add),
                    label: Text("Đặt phòng"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.door_back_door),
                    label: Text("Quản lý phòng"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.room_service),
                    label: Text("Quản lý dịch vụ"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.query_stats),
                    label: Text("Thống kê"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.history),
                    label: Text("Lịch sử"),
                  ),
                ],
                selectedIndex: state.selectedIndex,
                extended: MediaQuery.of(context).size.width > 800,
                leading: Text(state.infoString),
                trailing: ElevatedButton(
                    onPressed: () {
                      context.read<HomePageBloc>().add(LogoutEvent(context));
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.logout, size: 14),
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
          );
        }),
      ),
    );
  }
}
