import 'CatModel.dart';
import 'AdditionModel.dart';

class Order {
  final DateTime date, checkIn, checkOut;
  final Cat cat;
  final String inCharge;
  final String? note, attention;
  final int subRoomNum, id, eatingRank;
  final List<Addition>? additionsList;

  Order.fromJson(Map<String, dynamic> json)
      : id = json["order_id"],
        date = DateTime.parse(json["order_date"]),
        checkIn = DateTime.parse(json["order_checkin"]),
        checkOut = DateTime.parse(json["order_checkout"]),
        attention = json["order_attention"],
        note = json["order_note"],
        inCharge = json["order_incharge"],
        subRoomNum = json["order_subroom_num"],
        eatingRank = json["order_eating_rank"],
        cat = Cat.fromJson({
          "catID": json["cat_id"],
          "catName": json["cat_name"],
          "catImage": json["cat_image"],
          "catAge": json["cat_age"],
          "catSterilization": json["cat_sterilization"],
          "catVaccination": json["cat_vaccination"],
          "catPhysicalCondition": json["cat_physical_condition"],
          "catGender": json["cat_gender"],
          "catSpecies": json["cat_species"],
          "catAppearance": json["cat_appearance"],
          "catWeightRank": json["cat_weight_rank"],
          "catWeight": json["cat_weight"],
          "owner": {
            "ownerName": json["owner_name"],
            "ownerGender": json["owner_gender"],
            "ownerTel": json["owner_tel"],
            "ownerID": json["owner_id"],
          }
        }),
        additionsList = json["additionsList"];

  String getBookingInfoToString() {
    return "Mèo: ${cat.name}\nCheck-in: \nCheck-out: \nGhi chú: $note\nLễ tân tiếp nhận: $inCharge\nNgày đặt phòng: ";
  }
}
