import '../utils/PairUtils.dart';
import 'OrderModel.dart';
import 'RoomModel.dart';

class RoomGroup {
  late Room room;
  late List<Order> ordersList;
  late List<List<Pair>> displayArray;

  RoomGroup(
      {required this.room,
      required this.ordersList,
      required this.displayArray});
}
