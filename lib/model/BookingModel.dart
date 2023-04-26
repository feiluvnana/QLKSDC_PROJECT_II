import '../utils/DateUtils.dart';
import 'CatModel.dart';
import 'BookingServiceModel.dart';

class Booking {
  final DateTime bookingDate, dateIn, dateOut;
  final Cat catData;
  final String byRep;
  final String note, attention;
  final int subNumber, bookingID;
  final List<BookingService>? bookingServiceList;

  Booking.fromJson(Map<String, dynamic> json)
      : bookingID = json["bookingID"],
        bookingDate = DateTime.parse(json["bookingDate"]),
        dateIn = DateTime.parse(json["dateIn"]),
        dateOut = DateTime.parse(json["dateOut"]),
        attention = json["attention"],
        note = json["note"],
        byRep = json["byRep"],
        subNumber = json["subNumber"],
        catData = Cat.fromJson({
          "catID": json["catID"],
          "catName": json["catName"],
          "catImage": json["catImage"],
          "age": json["age"],
          "sterilization": json["sterilization"],
          "vaccination": json["vaccination"],
          "physicalCondition": json["physicalCondition"],
          "catGender": json["catGender"],
          "species": json["species"],
          "appearance": json["appearance"],
          "owner": {
            "ownerName": json["ownerName"],
            "ownerGender": json["ownerGender"],
            "tel": json["tel"],
            "ownerID": json["ownerID"],
          }
        }),
        bookingServiceList = json["bookingServiceList"];

  String getBookingInfoToString() {
    return "Mèo: ${catData.catName}\nCheck-in: ${DateUtils.dateTimeToString(dateIn)}\nCheck-out: ${DateUtils.dateTimeToString(dateOut)}\nGhi chú: $note\nLễ tân tiếp nhận: $byRep\nNgày đặt phòng: ${DateUtils.dateTimeToString(bookingDate)}";
  }
}
