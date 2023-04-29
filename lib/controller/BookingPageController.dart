import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'AuthController.dart';
import '../model/ServiceModel.dart';

class BookingPageController extends GetxController {
  int _currentStep = 0;
  final GlobalKey<FormState> formKey1 = GlobalKey();
  final GlobalKey<FormState> formKey2 = GlobalKey();
  final GlobalKey<FormState> formKey3 = GlobalKey();

  final TextEditingController ownerNameController = TextEditingController();
  String _ownerGender = "";
  final TextEditingController telController = TextEditingController();

  final TextEditingController catNameController = TextEditingController();
  final TextEditingController catWeightController = TextEditingController();
  int _catWeightLevel = 0;
  String? _catGender = "";
  Uint8List? _catImage;
  final TextEditingController catAgeController = TextEditingController();
  int _sterilization = -1;
  int _vaccination = -1;
  final TextEditingController physicalConditionController =
      TextEditingController();
  final TextEditingController appearanceController = TextEditingController();
  final TextEditingController speciesController = TextEditingController();

  DateTime _checkIn = DateTime.now();
  DateTime _checkOut = DateTime.now();
  final checkInController = TextEditingController();
  final checkOutController = TextEditingController();
  final TextEditingController attentionController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  int _roomId = -1;
  int _subNumber = -1;
  int _numberOfServices = 0;
  int _rank = 0;
  List<int> service = [];
  List<TextEditingController?> quantity = [];
  List<TextEditingController> time = [];
  List<TextEditingController?> distance = [];

  List<Service> serviceList = [];

  int get currentStep => _currentStep;
  set currentStep(int value) {
    _currentStep = value;
    update();
  }

  String get ownerGender => _ownerGender;
  set ownerGender(String value) {
    _ownerGender = value;
    update();
  }

  String? get catGender => _catGender;
  set catGender(String? value) {
    _catGender = value;
    update();
  }

  int get catWeightLevel => _catWeightLevel;
  set catWeightLevel(int value) {
    _catWeightLevel = value;
    update();
  }

  Uint8List? get catImage => _catImage;
  set catImage(Uint8List? value) {
    _catImage = value;
    update();
  }

  int get sterilization => _sterilization;
  set sterilization(int value) {
    _sterilization = value;
    update();
  }

  int get vaccination => _vaccination;
  set vaccination(int value) {
    _vaccination = value;
    update();
  }

  DateTime get checkIn => _checkIn;
  set checkIn(DateTime value) {
    _checkIn = value;
  }

  DateTime get checkOut => _checkOut;
  set checkOut(DateTime value) {
    _checkOut = value;
  }

  int get roomId => _roomId;
  set roomId(int value) {
    _roomId = value;
    update();
  }

  int get subNumber => _subNumber;
  set subNumber(int value) {
    _subNumber = value;
    update();
  }

  int get numberOfServices => _numberOfServices;
  set numberOfServices(int value) {
    _numberOfServices = value;
    update();
  }

  int get rank => _rank;
  set rank(int value) {
    _rank = value;
    update();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  Future<Uint8List?> getPhotos() async {
    catImage = await ImagePickerWeb.getImageAsBytes();
    return catImage;
  }

  Future<void> getServiceInfo() async {
    List<dynamic> list = jsonDecode((await GetConnect().post(
      "http://localhost/php-crash/getServiceForDisplay.php",
      FormData({"sessionID": Get.find<AuthController>().sessionID}),
    ))
        .body);
    for (var s in list) {
      serviceList.add(Service.fromJson(s));
    }
  }

  Future<void> createServiceController(int value, int index) async {
    quantity[index] =
        (serviceList[value].requiredQuantity) ? TextEditingController() : null;
    distance[index] =
        (serviceList[value].requiredDistance) ? TextEditingController() : null;
    update();
  }

  Future<void> sendDataToDatabase() async {
    int ownerID = jsonDecode((await GetConnect().post(
            "http://localhost/php-crash/setOwnerInfo.php",
            FormData({
              "sessionID": Get.find<AuthController>().sessionID,
              "ownerName": ownerNameController.text,
              "tel": telController.text,
              "ownerGender": ownerGender
            })))
        .body)["ownerID"];
    int catID = jsonDecode((await GetConnect().post(
            "http://localhost/php-crash/setCatInfo.php",
            FormData({
              "sessionID": Get.find<AuthController>().sessionID,
              "ownerID": ownerID,
              "catName": catNameController.text,
              "age": catAgeController.text,
              "image": (catImage == null) ? null : base64Encode(catImage!),
              "vaccination": vaccination,
              "species": speciesController.text,
              "appearance": appearanceController.text,
              "sterilization": sterilization,
              "physicalCondition": physicalConditionController.text,
              "catGender": catGender,
              "catWeight": catWeightController.text,
              "catWeightLevel": catWeightLevel
            })))
        .body)["catID"];
    String message = jsonDecode((await GetConnect().post(
            "http://localhost/php-crash/setBookingInfo.php",
            FormData({
              "sessionID": Get.find<AuthController>().sessionID,
              "catID": catID,
              "roomID": roomId,
              "subNumber": subNumber,
              "dateIn": checkIn.toString(),
              "dateOut": checkOut.toString(),
              "attention": attentionController.text,
              "note": noteController.text,
              "rank": rank,
              "services": List.generate(
                  numberOfServices,
                  (index) => {
                        "serviceID": serviceList[index].serviceID,
                        "time": null,
                        "quantity": (quantity[index] == null)
                            ? null
                            : quantity[index]?.text,
                        "distance": (distance[index] == null)
                            ? null
                            : distance[index]?.text,
                      })
            })))
        .body)["message"];
  }
}
