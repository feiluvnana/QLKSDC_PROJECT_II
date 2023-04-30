import 'OwnerModel.dart';

class Cat {
  final int catID, catAge, catSterilization, catVaccination, catWeightLevel;
  final double? catWeight;
  final String catName, catPhysicalCondition;
  final String? catGender, catSpecies, catAppearance, catImage;
  final Owner ownerData;

  Cat.fromJson(Map<String, dynamic> json)
      : catID = json["catID"],
        catName = json["catName"],
        catImage = json["catImage"],
        catAge = json["catAge"],
        catSterilization = json["catSterilization"],
        catVaccination = json["catVaccination"],
        catPhysicalCondition = json["catPhysicalCondition"],
        catGender = json["catGender"],
        catSpecies = json["caySpecies"],
        catAppearance = json["catAppearance"],
        catWeightLevel = json["catWeightLevel"],
        catWeight = json["catWeight"],
        ownerData = Owner.fromJson(json["owner"]);
}
