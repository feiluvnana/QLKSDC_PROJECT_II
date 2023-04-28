import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:project_ii/controller/AuthController.dart';
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
  int _weightLevel = 0;
  String _catGender = "";
  Uint8List? _catImage;
  final TextEditingController catAgeController = TextEditingController();
  int _sterilization = -1;
  int _vaccination = -1;
  final TextEditingController physicalConditionController =
      TextEditingController();
  final TextEditingController appearanceController = TextEditingController();
  final TextEditingController speciesController = TextEditingController();

  final TextEditingController checkInController = TextEditingController();
  final TextEditingController checkOutController = TextEditingController();
  final TextEditingController attentionController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  int _roomIndex = -1;
  int _subRoomIndex = -1;
  int _numberOfServices = 0;
  int _rank = 0;
  List<int> service = [];
  List<TextEditingController?> quantity = [];
  List<TextEditingController> time = [];
  List<TextEditingController?> distance = [];
  List<TextEditingController?> weight = [];

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

  String get catGender => _catGender;
  set catGender(String value) {
    _catGender = value;
    update();
  }

  int get weightLevel => _weightLevel;
  set weightLevel(int value) {
    _weightLevel = value;
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

  int get roomIndex => _roomIndex;
  set roomIndex(int value) {
    _roomIndex = value;
    update();
  }

  int get subRoomIndex => _subRoomIndex;
  set subRoomIndex(int value) {
    _subRoomIndex = value;
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
    weight[index] =
        (serviceList[value].requiredWeight) ? TextEditingController() : null;
    update();
  }

  Future<void> sendDataToDatabase() async {
    print(jsonDecode((await GetConnect().post(
            "http://localhost/php-crash/setOwnerInfo.php",
            FormData({
              "sessionID": Get.find<AuthController>().sessionID,
              "name": ownerNameController.text,
              "tel": telController.text,
              "gender": ownerGender
            })))
        .body));
    int ownerID = jsonDecode((await GetConnect().post(
            "http://localhost/php-crash/setOwnerInfo.php",
            FormData({
              "sessionID": Get.find<AuthController>().sessionID,
              "name": ownerNameController.text,
              "tel": telController.text,
              "gender": ownerGender
            })))
        .body)["ownerID"];
    print("ownerID $ownerID");
    print((await GetConnect().post(
            "http://localhost/php-crash/setCatInfo.php",
            FormData({
              "sessionID": Get.find<AuthController>().sessionID,
              "ownerID": ownerID,
              "name": catNameController.text,
              "age": catAgeController.text,
              "image": (catImage == null) ? null : base64Encode(catImage!),
              "vaccination": vaccination,
              "species": speciesController.text,
              "appearance": appearanceController.text,
              "sterilization": sterilization,
              "physicalCondition": physicalConditionController.text,
              "gender": catGender
            })))
        .body);
  }
}
