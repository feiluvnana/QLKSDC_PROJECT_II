import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/states/home_page_state.dart';

class HomePageCubit extends Cubit<int> {
  HomePageCubit() : super(HomePageState.calendar);

  void goto(int value) => emit(value);

  @override
  void onChange(Change<int> change) {
    super.onChange(change);
    print("[home_page_cubit] $change");
  }
}
