import 'OwnerModel.dart';

class Cat {
  final int catID, age, sterilization, vaccination;
  final String catName, physicalCondition;
  final String? catGender, species, appearance, catImage;
  final Owner ownerData;

  Cat.fromJson(Map<String, dynamic> json)
      : catID = json["catID"],
        catName = json["catName"],
        catImage = json["catImage"],
        age = json["age"],
        sterilization = json["sterilization"],
        vaccination = json["vaccination"],
        physicalCondition = json["physicalCondition"],
        catGender = json["catGender"],
        species = json["species"],
        appearance = json["appearance"],
        ownerData = Owner.fromJson(json["owner"]);
}
