import '../utils/PairUtils.dart';
import 'OrderModel.dart';
import 'RoomModel.dart';

class RoomGroup {
  Room room;
  List<Order> ordersList;
  List<List<Pair>> displayArray;

  RoomGroup(
      {required this.room,
      required this.ordersList,
      required this.displayArray});
}
