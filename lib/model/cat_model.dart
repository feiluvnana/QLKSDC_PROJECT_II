import 'dart:convert';
import 'dart:typed_data';
import 'owner_model.dart';

class Cat {
  final int age, sterilization, vaccination;
  final double? weight;
  final String name, physicalCondition, weightRank;
  final String? gender, species, appearance;
  final Uint8List? image;
  final Owner owner;

  Cat.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        image = (json["image"] == null) ? null : base64Decode(json["image"]),
        age = json["age"],
        sterilization = json["sterilization"],
        vaccination = json["vaccination"],
        physicalCondition = json["physical_condition"],
        gender = json["gender"],
        species = json["species"],
        appearance = json["appearance"],
        weightRank = json["weight_rank"],
        weight = json["weight"],
        owner = Owner.fromJson(json["owner"]);

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

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "image": image != null ? base64Encode(image!) : null,
      "age": age,
      "sterilization": sterilization,
      "vaccination": vaccination,
      "physical_condition": physicalCondition,
      "gender": gender,
      "weight_rank": weightRank,
      "species": species,
      "appearance": appearance,
      "weight": weight,
      "owner": owner.toJson()
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
