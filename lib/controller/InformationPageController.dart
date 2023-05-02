import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import '../model/BookingModel.dart';
import '../model/RoomModel.dart';

class InformationPageController extends GetxController {
  final GlobalKey<FormState> formKey1 = GlobalKey();

  bool _editForm1 = false;
  bool _initForm1 = false;

  String _modifiedRoomID = "";
  int _modifiedSubNumber = -1;
  int _modifiedEatingRank = -1;

  bool get editForm1 => _editForm1;

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

  Future<void> toggleForm1(
      {required Booking bookingData, required Room roomData}) async {
    _editForm1 = !_editForm1;
    if (!_initForm1) {
      _modifiedRoomID = roomData.roomID;
      _modifiedSubNumber = bookingData.subNumber;
      _modifiedEatingRank = bookingData.eatingRank;
      _initForm1 = true;
    }
    update(["form1"]);
  }
}
