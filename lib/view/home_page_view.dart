import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_ii/blocs/home_page_bloc.dart';

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
                    icon: Icon(Icons.history),
                    label: Text("Lịch sử"),
                  ),
                ],
                selectedIndex: state.selectedIndex,
                extended: MediaQuery.of(context).size.width > 800,
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
                      5, (index) => Builder(builder: state.builders[index])),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
