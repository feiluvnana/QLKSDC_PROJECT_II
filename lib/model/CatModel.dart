import 'dart:convert';
import 'dart:typed_data';
import 'OwnerModel.dart';

class Cat {
  final int age, sterilization, vaccination;
  final double? weight;
  final String name, physicalCondition, weightRank;
  final String? gender, species, appearance;
  final Uint8List? image;
  final Owner owner;

  Cat.fromJson(Map<String, dynamic> json, this.owner)
      : name = json["cat_name"],
        image = (json["cat_image"] == null)
            ? null
            : base64Decode(json["cat_image"]),
        age = json["cat_age"],
        sterilization = json["cat_sterilization"],
        vaccination = json["cat_vaccination"],
        physicalCondition = json["cat_physical_condition"],
        gender = json["cat_gender"],
        species = json["cat_species"],
        appearance = json["cat_appearance"],
        weightRank = json["cat_weight_rank"],
        weight = json["cat_weight"];

  Cat.empty()
      : weightRank = "",
        name = "",
        age = -1,
        physicalCondition = "",
        sterilization = -1,
        vaccination = -1,
        species = null,
        appearance = null,
        gender = null,
        image = null,
        weight = null,
        owner = Owner.empty();

  Map<String, String> toJson() {
    return {
      "catName": name,
      "catImage": image != null ? base64Encode(image!) : null.toString(),
      "catAge": age.toString(),
      "catSterilization": sterilization.toString(),
      "catVaccination": vaccination.toString(),
      "catPhysicalCondition": physicalCondition,
      "catGender": gender.toString(),
      "catWeightRank": weightRank,
      "catSpecies": species.toString(),
      "catAppearance": appearance.toString(),
      "catWeight": weight.toString(),
    };
  }

  String sterText() {
    if (sterilization == 0) return "Chưa thiến";
    return "Đã thiến";
  }

  String vaccText() {
    if (vaccination == 0) return "Chưa tiêm";
    if (vaccination == 1) return "Đã tiêm vaccine dại";
    if (vaccination == 2) return "Đã tiêm vaccine tổng hợp";
    return "Đã tiêm cả hai loại vaccine";
  }
}
