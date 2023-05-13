import 'dart:convert';
import 'package:flutter/material.dart';
import 'OwnerModel.dart';

class Cat {
  final int id, age, sterilization, vaccination, weightRank;
  final double? weight;
  final String name, physicalCondition;
  final String? gender, species, catAppearance;
  final Image? image;
  final Owner owner;

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
        catAppearance = json["catAppearance"],
        weightRank = json["catWeightRank"],
        weight = json["catWeight"],
        owner = Owner.fromJson(json["owner"]);
}
