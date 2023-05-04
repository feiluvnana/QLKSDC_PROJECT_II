import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:intl/intl.dart';
import '../model/BookingServiceModel.dart';
import '../model/RoomBookingModel.dart';

class GuestListView extends StatelessWidget {
  const GuestListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
          onPressed: () => createSpreadSheet(), child: Text("create")),
    );
  }

  Future<void> createSpreadSheet() async {
    final Workbook wb = Workbook();
    final Worksheet ws = wb.worksheets[0];

    final Style titleStyle = wb.styles.add('titleStyle');
    titleStyle
      ..fontName = 'Helvetica'
      ..fontSize = 20
      ..bold = true
      ..wrapText = true
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center;

    final Style cellStyle = wb.styles.add('cellStyle');
    cellStyle
      ..fontName = 'Times New Roman'
      ..fontSize = 14
      ..wrapText = true
      ..hAlign = HAlignType.left
      ..vAlign = VAlignType.center
      ..borders.all.lineStyle = LineStyle.medium;

    ws.getRangeByName("A1").columnWidth = 8;
    ws.getRangeByName("B1").columnWidth = 4;
    ws.getRangeByName("C1").columnWidth = 10;
    ws.getRangeByName("D1").columnWidth = 32.5;
    ws.getRangeByName("E1").columnWidth = 31;

    ws.getRangeByName("A1:E1")
      ..merge()
      ..rowHeight = 30
      ..setText(
          "Danh sách khách hàng ${Get.parameters["day"]}-${Get.parameters["month"]}-${Get.parameters["year"]}")
      ..cellStyle = titleStyle;

    ws.getRangeByName("A2:E2")
      ..merge()
      ..rowHeight = 30
      ..setText("1. Danh sách khách ở")
      ..cellStyle = titleStyle;

    ws.getRangeByName("A3:B3")
      ..merge()
      ..setText("Phòng")
      ..cellStyle = cellStyle;
    ws.getRangeByName("C3")
      ..setText("Hạng ăn")
      ..cellStyle = cellStyle;
    ws.getRangeByName("D3")
      ..setText("Thông tin")
      ..cellStyle = cellStyle;
    ws.getRangeByName("E3")
      ..setText("Lưu ý")
      ..cellStyle = cellStyle;

    List<RoomBooking> bookingDataForAllRooms =
        Get.arguments["bookingDataForAllRooms"];
    int lastRow = 4;
    int currentRow = 4;
    DateTime guestListDate = DateTime(int.parse(Get.parameters["year"]!),
        int.parse(Get.parameters["month"]!), int.parse(Get.parameters["day"]!));
    for (var bdForARoom in bookingDataForAllRooms) {
      for (var bd in bdForARoom.bookingData) {
        if (ignoreHour(bd.checkInDate).isBefore(guestListDate) &&
            ignoreHour(bd.checkOutDate).isAfter(guestListDate)) {
          ws.getRangeByName("B$currentRow")
            ..setText(bd.subNumber.toString())
            ..cellStyle = cellStyle;
          ws.getRangeByName("C$currentRow")
            ..setText("Hạng ${bd.eatingRank}")
            ..cellStyle = cellStyle;
          ws.getRangeByName("D$currentRow")
            ..setText(getStringFromService(bd.bookingServiceList))
            ..cellStyle = cellStyle;
          ws.getRangeByName("E$currentRow")
            ..setText(bd.attention.toString())
            ..cellStyle = cellStyle;
          currentRow++;
        }
        ws.getRangeByName("A$lastRow:A${currentRow - 1}")
          ..merge()
          ..setText(bdForARoom.roomData.roomID)
          ..cellStyle = cellStyle;
        lastRow = currentRow;
      }

      final rawData = wb.saveAsStream();
      wb.dispose();
      final content = base64Encode(rawData);
      AnchorElement(
          href:
              "data:application/octet-stream;charset=utf-16le;base64,$content")
        ..setAttribute("download",
            "Danh sách khách hàng ${Get.parameters["day"]}-${Get.parameters["month"]}-${Get.parameters["year"]}.xlsx")
        ..click();
    }
  }

  DateTime ignoreHour(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String getStringFromService(List<BookingService>? list) {
    String str = "";
    if (list == null) return str;
    for (int i = 0; i < list.length; i++) {
      str += "${i + 1}. ${list[i].serviceName}\n";
      if (list[i].serviceDistance != null) {
        str += "   Khoảng cách đưa đón: ${list[i].serviceDistance}\n";
      }
      if (list[i].serviceQuantity != null) {
        str += "   Số lượng đã đặt: ${list[i].serviceQuantity}\n";
      }
      if (list[i].serviceTime != null) {
        str +=
            "   Thời gian: ${DateFormat("dd/MM/yyyy hh:mm").format(list[i].serviceTime!)}\n";
      }
    }
    return str;
  }
}
