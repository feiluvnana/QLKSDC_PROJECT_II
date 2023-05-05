import '../utils/PairUtils.dart';
import 'BookingModel.dart';
import 'RoomModel.dart';

class RoomBooking {
  late Room roomData;
  late List<Booking> bookingDataList;
  late List<List<Pair>> displayArray;

  RoomBooking(
      {required this.roomData,
      required this.bookingDataList,
      required this.displayArray});
}
