import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:project_ii/controller/HomePageController.dart';
import '../model/ServiceModel.dart';
import 'CalendarPageController.dart';

class BookingPageController extends GetxController {
  bool _isSubmitClicked = false;
  int _currentStep = 0;
  final GlobalKey<FormState> formKey1 = GlobalKey();
  final GlobalKey<FormState> formKey2 = GlobalKey();
  final GlobalKey<FormState> formKey3 = GlobalKey();

  final TextEditingController ownerNameController = TextEditingController();
  String? _ownerGender;
  final TextEditingController ownerTelController = TextEditingController();

  final TextEditingController catNameController = TextEditingController();
  final TextEditingController catWeightController = TextEditingController();
  int _catWeightLevel = 0;
  String? _catGender;
  Uint8List? _catImage;
  final TextEditingController catAgeController = TextEditingController();
  int _catSterilization = -1;
  int _catVaccination = -1;
  final TextEditingController catPhysicalConditionController =
      TextEditingController();
  final TextEditingController catAppearanceController = TextEditingController();
  final TextEditingController catSpeciesController = TextEditingController();

  DateTime checkInDate = DateTime.now();
  DateTime checkOutDate = DateTime.now();
  final checkInDateController = TextEditingController();
  final checkOutDateController = TextEditingController();
  final TextEditingController attentionController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  String _roomID = "";
  int _subNumber = -1;
  int _numberOfServices = 0;
  int _eatingRank = 0;
  List<int> serviceList = [];
  List<DateTime?> serviceTimeValue = [];
  List<TextEditingController?> serviceTime = [];
  List<TextEditingController?> serviceQuantity = [];
  List<TextEditingController?> serviceDistance = [];
  List<Service> allServiceList = [];

  int get currentStep => _currentStep;
  set currentStep(int value) {
    _currentStep = value;
    update();
  }

  String? get ownerGender => _ownerGender;
  set ownerGender(String? value) {
    _ownerGender = value;
    update();
  }

  int get catWeightLevel => _catWeightLevel;
  set catWeightLevel(int value) {
    _catWeightLevel = value;
    update();
  }

  String? get catGender => _catGender;
  set catGender(String? value) {
    _catGender = value;
    update();
  }

  Uint8List? get catImage => _catImage;
  set catImage(Uint8List? value) {
    _catImage = value;
    update();
  }

  int get catSterilization => _catSterilization;
  set catSterilization(int value) {
    _catSterilization = value;
    update();
  }

  int get catVaccination => _catVaccination;
  set catVaccination(int value) {
    _catVaccination = value;
    update();
  }

  String get roomID => _roomID;
  set roomID(String value) {
    _roomID = value;
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

  int get eatingRank => _eatingRank;
  set eatingRank(int value) {
    _eatingRank = value;
    update();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    Future.delayed(const Duration(seconds: 0),
            () async => allServiceList = await getServiceInfo())
        .then((value) => update());
  }

  Future<Uint8List?> getPhotos() async {
    catImage = await ImagePickerWeb.getImageAsBytes();
    return catImage;
  }

  Future<List<Service>> getServiceInfo() async {
    List<dynamic> resList = jsonDecode((await GetConnect().post(
      "http://localhost/php-crash/getServiceForDisplay.php",
      FormData({"sessionID": GetStorage().read("sessionID")}),
    ))
        .body);
    List<Service> list = [];
    for (var s in resList) {
      list.add(Service.fromJson(s));
    }
    return list;
  }

  Future<void> createServiceController(int value, int index) async {
    serviceQuantity[index] = (allServiceList[value].requiredQuantity)
        ? TextEditingController()
        : null;
    serviceDistance[index] = (allServiceList[value].requiredDistance)
        ? TextEditingController()
        : null;
    serviceTime[index] =
        (allServiceList[value].requiredTime) ? TextEditingController() : null;
    update();
  }

  Future<void> sendDataToDatabase() async {
    if (_isSubmitClicked) return;
    _isSubmitClicked = true;
    int ownerID = jsonDecode((await GetConnect().post(
            "http://localhost/php-crash/setOwnerInfo.php",
            FormData({
              "sessionID": GetStorage().read("sessionID"),
              "ownerName": ownerNameController.text,
              "ownerTel": ownerTelController.text,
              "ownerGender": ownerGender
            })))
        .body)["ownerID"];
    int catID = jsonDecode((await GetConnect().post(
            "http://localhost/php-crash/setCatInfo.php",
            FormData({
              "sessionID": GetStorage().read("sessionID"),
              "ownerID": ownerID,
              "catName": catNameController.text,
              "catAge": catAgeController.text,
              "catImage": (catImage == null)
                  ? null
                  : base64Encode(catImage as List<int>),
              "catVaccination": catVaccination,
              "catSpecies": catSpeciesController.text,
              "catAppearance": catAppearanceController.text,
              "catSterilization": catSterilization,
              "catPhysicalCondition": catPhysicalConditionController.text,
              "catGender": catGender,
              "catWeight": catWeightController.text,
              "catWeightLevel": catWeightLevel
            })))
        .body)["catID"];
    String message = jsonDecode((await GetConnect().post(
            "http://localhost/php-crash/setBookingInfo.php",
            FormData({
              "sessionID": GetStorage().read("sessionID"),
              "catID": catID,
              "roomID": roomID,
              "subNumber": subNumber,
              "checkInDate": checkInDate.toString(),
              "checkOutDate": checkOutDate.toString(),
              "attention": attentionController.text,
              "note": noteController.text,
              "eatingRank": eatingRank,
              "bookingServicesList":
                  jsonEncode(List.generate(numberOfServices, (index) {
                if (allServiceList[index].serviceName == "Đón mèo")
                  serviceTimeValue[index] = checkInDate;
                if (allServiceList[index].serviceName == "Trả mèo")
                  serviceTimeValue[index] = checkOutDate;
                return {
                  "serviceID": allServiceList[index].serviceID,
                  "serviceTime": serviceTimeValue[index].toString(),
                  "serviceQuantity": (serviceQuantity[index] == null)
                      ? null
                      : serviceQuantity[index]?.text,
                  "serviceDistance": (serviceDistance[index] == null)
                      ? null
                      : serviceDistance[index]?.text,
                };
              }))
            })))
        .body)["message"];
    await Get.defaultDialog(
      barrierDismissible: true,
      title: "Thông báo",
      content: Text(message),
    ).then((value) => _isSubmitClicked = false);
    if (message == "Đã đặt phòng thành công.") {
      await Get.find<CalendarPageController>().getBookingDataForAllRooms();
      Get.find<HomePageController>()
        ..homePageIndex = 0
        ..update();
    }
  }
}
