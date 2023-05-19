import 'dart:convert';
import 'package:flutter/material.dart';
import 'OwnerModel.dart';

class Cat {
  final int id, age, sterilization, vaccination;
  final double? weight;
  final String name, physicalCondition, weightRank;
  final String? gender, species, appearance;
  final Image? image;
  final Owner owner;

  Cat(
      {required this.id,
      required this.age,
      required this.sterilization,
      required this.vaccination,
      required this.weightRank,
      this.weight,
      required this.name,
      required this.physicalCondition,
      this.gender,
      this.species,
      this.appearance,
      this.image,
      required this.owner});

  Cat.fromJson(Map<String, dynamic> json)
      : id = json["catID"],
        name = json["catName"],
        image = (json["catImage"] == null)
            ? null
            : Image.memory(base64Decode(json["catImage"]),
                fit: BoxFit.scaleDown),
        age = json["catAge"],
        sterilization = json["catSterilization"],
        vaccination = json["catVaccination"],
        physicalCondition = json["catPhysicalCondition"],
        gender = json["catGender"],
        species = json["catSpecies"],
        appearance = json["catAppearance"],
        weightRank = json["catWeightRank"],
        weight = json["catWeight"],
        owner = Owner.fromJson(json["owner"]);

  Map<String, dynamic> toJson() {
    return {
      "catID": id,
      "catName": name,
      "catImage": image,
      "catAge": age,
      "catSterilization": sterilization,
      "catVaccination": vaccination,
      "catPhysicalCondition": physicalCondition,
      "catGender": gender,
      "catWeightRank": weightRank,
      "catSpecies": species,
      "catAppearance": appearance,
      "catWeight": weight,
      "owner": owner.toJson()
    };
  }
}
