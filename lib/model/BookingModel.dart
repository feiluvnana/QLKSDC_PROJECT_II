import 'CatModel.dart';
import 'BookingServiceModel.dart';

class Booking {
  final DateTime bookingDate, checkInDate, checkOutDate;
  final Cat catData;
  final String byRep;
  final String? note, attention;
  final int subNumber, bookingID, eatingRank;
  final List<BookingService>? bookingServiceList;

  Booking.fromJson(Map<String, dynamic> json)
      : bookingID = json["bookingID"],
        bookingDate = DateTime.parse(json["bookingDate"]),
        checkInDate = DateTime.parse(json["checkInDate"]),
        checkOutDate = DateTime.parse(json["checkOutDate"]),
        attention = json["attention"],
        note = json["note"],
        byRep = json["byRep"],
        subNumber = json["subNumber"],
        eatingRank = json["eatingRank"],
        catData = Cat.fromJson({
          "catID": json["catID"],
          "catName": json["catName"],
          "catImage": json["catImage"],
          "catAge": json["catAge"],
          "catSterilization": json["catSterilization"],
          "catVaccination": json["catVaccination"],
          "catPhysicalCondition": json["catPhysicalCondition"],
          "catGender": json["catGender"],
          "catSpecies": json["catSpecies"],
          "catAppearance": json["catAppearance"],
          "catWeightLevel": json["catWeightLevel"],
          "catWeight": json["catWeight"],
          "owner": {
            "ownerName": json["ownerName"],
            "ownerGender": json["ownerGender"],
            "ownerTel": json["ownerTel"],
            "ownerID": json["ownerID"],
          }
        }),
        bookingServiceList = json["bookingServiceList"];

  String getBookingInfoToString() {
    return "Mèo: ${catData.catName}\nCheck-in: \nCheck-out: \nGhi chú: $note\nLễ tân tiếp nhận: $byRep\nNgày đặt phòng: ";
  }
}
