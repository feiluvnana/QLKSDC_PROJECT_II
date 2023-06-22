import '../data/types/pair.dart';
import 'order_model.dart';
import 'room_model.dart';

class RoomGroup {
  Room room;
  List<Order> ordersList;
  List<List<Pair>> displayArray;

  RoomGroup(
      {required this.room,
      required this.ordersList,
      required this.displayArray});
}
