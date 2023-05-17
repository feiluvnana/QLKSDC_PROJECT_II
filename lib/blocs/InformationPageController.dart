import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../model/OrderModel.dart';
import '../model/AdditionModel.dart';
import '../model/RoomModel.dart';
import '../model/ServiceModel.dart';
import '../utils/InternalStorage.dart';

class InformationPageController extends GetxController {
  final GlobalKey<FormState> formKey1 = GlobalKey();
  final GlobalKey<FormState> formKey2 = GlobalKey();

  bool _editForm1 = false;
  bool _initForm1 = false;
  bool _editForm2 = false;
  bool _initForm2 = false;

  String _modifiedRoomID = "";
  int _modifiedSubNumber = -1;
  int _modifiedEatingRank = -1;
  DateTime _modifiedCheckInDate = DateTime.now();
  DateTime _modifiedCheckOutDate = DateTime.now();
  final modifiedCheckInDateController = TextEditingController();
  final modifiedCheckOutDateController = TextEditingController();

  int _modifiedNumberOfAdditions = 0;
  List<int> modifiedAdditionsList = [];
  List<DateTime?> modifiedAdditionTimeValue = [];
  List<TextEditingController?> modifiedAdditionTime = [];
  List<TextEditingController?> modifiedAdditionQuantity = [];
  List<TextEditingController?> modifiedAdditionDistance = [];

  bool get editForm1 => _editForm1;
  bool get editForm2 => _editForm2;

  String get modifiedRoomID => _modifiedRoomID;
  set modifiedRoomID(String value) {
    _modifiedRoomID = value;
    update(["form1"]);
  }

  int get modifiedSubNumber => _modifiedSubNumber;
  set modifiedSubNumber(int value) {
    _modifiedSubNumber = value;
    update(["form1"]);
  }

  int get modifiedEatingRank => _modifiedEatingRank;
  set modifiedEatingRank(int value) {
    _modifiedEatingRank = value;
    update(["form1"]);
  }

  DateTime get modifiedCheckInDate => _modifiedCheckInDate;
  set modifiedCheckInDate(DateTime value) {
    _modifiedCheckInDate = value;
    update(["form1"]);
  }

  DateTime get modifiedCheckOutDate => _modifiedCheckOutDate;
  set modifiedCheckOutDate(DateTime value) {
    _modifiedCheckOutDate = value;
    update(["form1"]);
  }

  int get modifiedNumberOfAdditions => _modifiedNumberOfAdditions;
  set modifiedNumberOfAdditions(int value) {
    _modifiedNumberOfAdditions = value;
    update(["form2"]);
  }

  Future<void> toggleForm1({required Order order, required Room room}) async {
    _editForm1 = !_editForm1;
    if (!_initForm1) {
      _modifiedRoomID = room.id;
      _modifiedSubNumber = order.subRoomNum;
      _modifiedEatingRank = order.eatingRank;
      _initForm1 = true;
      _modifiedCheckInDate = order.checkIn;
      _modifiedCheckOutDate = order.checkOut;
      modifiedCheckOutDateController.text =
          DateFormat("dd/MM/yyyy HH:mm").format(_modifiedCheckOutDate);
      modifiedCheckInDateController.text =
          DateFormat("dd/MM/yyyy HH:mm").format(_modifiedCheckInDate);
    }
    _initForm1 = true;
    update(["form1"]);
  }

  Future<void> toggleForm2({required Order order, required Room room}) async {
    _editForm2 = !_editForm2;
    List<Addition>? additionsList = order.additionsList;
    if (!_initForm2) {
      if (additionsList != null) {
        _modifiedNumberOfAdditions = additionsList.length;
        for (int i = 0; i < additionsList.length; i++) {
          modifiedAdditionsList.add(additionsList[i].serviceID);
          if (additionsList[i].quantity != null) {
            modifiedAdditionQuantity.add(TextEditingController());
            modifiedAdditionQuantity[i]?.text =
                additionsList[i].quantity.toString();
          } else {
            modifiedAdditionQuantity.add(null);
          }
          if (additionsList[i].time != null) {
            modifiedAdditionTime.add(TextEditingController());
            modifiedAdditionTime[i]?.text =
                DateFormat("dd/MM/yyyy HH:mm").format(additionsList[i].time!);
          } else {
            modifiedAdditionTime.add(null);
          }
          if (additionsList[i].distance != null) {
            modifiedAdditionDistance.add(TextEditingController());
            modifiedAdditionDistance[i]?.text = additionsList[i].distance!;
          } else {
            modifiedAdditionDistance.add(null);
          }
          if (additionsList[i].time != null) {
            modifiedAdditionTimeValue.add(additionsList[i].time);
          } else {
            modifiedAdditionTimeValue.add(null);
          }
        }
      }
    }
    _initForm2 = true;
    update(["form2"]);
  }

  void createModifiedController(int value, int index) {
    Service service = Get.find<InternalStorage>().read("servicesList")[value];
    modifiedAdditionQuantity[index] =
        (service.quantityNeed) ? TextEditingController() : null;
    modifiedAdditionDistance[index] =
        (service.distanceNeed) ? TextEditingController() : null;
    modifiedAdditionTime[index] =
        (service.timeNeed) ? TextEditingController() : null;
    update(["form2"]);
  }

  Future<String> cancelBooking({required int bidx, required int ridx}) async {
    Order order = (Get.find<InternalStorage>().read("roomGroupsList")[ridx])
        .ordersList[bidx];
    if (order.checkIn.isBefore(DateTime.now())) {
      return "Không thể huỷ đặt phòng do đã check-in.";
    }
    await GetConnect().post(
        "http://localhost/php-crash/cancelBooking.php",
        FormData({
          "sessionID": GetStorage().read("sessionID"),
          "bookingID": order.id
        }));
    return "Huỷ đặt phòng thành công";
  }

  Future<Map<String, bool>> saveChanges(
      {required int bidx, required int ridx}) async {
    if (formKey1.currentState?.validate() != true) return {"validation": false};
    if (formKey1.currentState?.validate() != true) return {"validation": false};
    Order order = (Get.find<InternalStorage>().read("roomGroupsList")[ridx])
        .ordersList[bidx];
    //form1:
    bool form1Result = true;
    if (_initForm1) {
      form1Result = await GetConnect()
          .post(
              "http://localhost/php-crash/saveChanges.php",
              FormData({
                "sessionID": GetStorage().read("sessionID"),
                "order": 1,
                "roomID": modifiedRoomID,
                "subRoomNum": modifiedSubNumber,
                "eatingRank": modifiedEatingRank,
                "checkIn": modifiedCheckInDate.toString(),
                "checkOut": modifiedCheckOutDate.toString(),
                "orderID": order.id
              }))
          .then((res) {
        if (res.body == null) return false;
        if (jsonDecode(res.body)["status"] == "failed") return false;
        return true;
      });
    }
    //form2:
    bool form2Result = true;
    if (_initForm2) {
      form2Result = await GetConnect()
          .post(
              "http://localhost/php-crash/saveChanges.php",
              FormData({
                "sessionID": GetStorage().read("sessionID"),
                "addition": 1,
                "orderID": order.id,
                "additionsList": jsonEncode(
                    List.generate(modifiedNumberOfAdditions, (index) {
                  List<Service> servicesList =
                      Get.find<InternalStorage>().read("servicesList");
                  if (servicesList
                          .firstWhere((element) =>
                              element.id == modifiedAdditionsList[index])
                          .name ==
                      "Đón mèo") {
                    modifiedAdditionTimeValue[index] = order.checkIn;
                  }
                  if (servicesList
                          .firstWhere((element) =>
                              element.id == modifiedAdditionsList[index])
                          .name ==
                      "Trả mèo") {
                    modifiedAdditionTimeValue[index] = order.checkOut;
                  }
                  return {
                    "serviceID": servicesList
                        .firstWhere((element) =>
                            element.id == modifiedAdditionsList[index])
                        .id,
                    "additionTime": (modifiedAdditionTimeValue[index] == null)
                        ? null
                        : modifiedAdditionTimeValue[index].toString(),
                    "additionQuantity":
                        (modifiedAdditionQuantity[index] == null)
                            ? null
                            : modifiedAdditionQuantity[index]?.text,
                    "additionDistance":
                        (modifiedAdditionDistance[index] == null)
                            ? null
                            : modifiedAdditionDistance[index]?.text,
                  };
                }))
              }))
          .then((res) {
        if (res.body == null) return false;
        if (jsonDecode(res.body)["status"] == "failed") return false;
        return true;
      });
    }
    return {
      "form1": form1Result,
      "form1Init": _initForm1,
      "form2": form2Result,
      "form2Init": _initForm2
    };
  }
}
