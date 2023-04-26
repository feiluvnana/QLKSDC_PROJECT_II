/*import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column;

import '../model/RoomBookingModel.dart';

class GuestList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<RoomBooking> roomBookingData = Get.arguments["roomBookingData"];
    int selectedDay = Get.arguments["day"];
    return Scaffold(
        body: Column(
      children: [
        Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(12),
            1: FlexColumnWidth(12),
            2: FlexColumnWidth(9),
            3: FlexColumnWidth(20),
            4: FlexColumnWidth(13),
            5: FlexColumnWidth(40),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: const [
            TableRow(
              children: [
                TableCell(child: Text("Số phòng")),
                TableCell(child: Text("Số phòng phụ")),
                TableCell(child: Text("Tên mèo")),
                TableCell(child: Text("Đặc điểm hình thái")),
                TableCell(child: Text("Hạng ăn")),
                TableCell(child: Text("Ghi chú"))
              ],
            ),
          ],
        ),
        ElevatedButton(
            onPressed: () async {
              await downloadExcel(
                  createExcelAsBytes(roomBookingData, selectedDay));
            },
            child: const Text("Tải xuống danh sách")),
      ],
    ));
  }

  List<int> createExcelAsBytes(
      List<RoomBooking> roomBookingData, int selectedDay) {
    final workbook = Workbook();
    final sheet = workbook.worksheets[0];
    sheet.showGridlines = true;
    sheet.enableSheetCalculations();

    sheet.getRangeByName("A1").columnWidth = 12;
    sheet.getRangeByName("B1").columnWidth = 12;
    sheet.getRangeByName("C1").columnWidth = 9;
    sheet.getRangeByName("D1").columnWidth = 20;
    sheet.getRangeByName("E1").columnWidth = 13;
    sheet.getRangeByName("F1").columnWidth = 40;

    var titleStyle = workbook.styles.add("tStyle");
    titleStyle
      ..fontSize = 16
      ..fontName = "Arial"
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center
      ..bold = true;
    sheet.getRangeByName("A1:F2")
      ..merge()
      ..setText("DANH SÁCH MÈO")
      ..cellStyle = titleStyle;

    sheet.getRangeByName("A3").setText("Số phòng");
    sheet.getRangeByName("B3").setText("Số phòng phụ");
    sheet.getRangeByName("C3").setText("Tên mèo");
    sheet.getRangeByName("D3").setText("Đặc điểm hình thái");
    sheet.getRangeByName("E3").setText("Hạng ăn");
    sheet.getRangeByName("F3").setText("Ghi chú");
    var headerStyle = workbook.styles.add("hStyle");
    headerStyle
      ..fontSize = 11
      ..fontName = "Arial"
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center;
    sheet.getRangeByName("A3:F3").cellStyle = headerStyle;

    int beginRow = 4;

    for (RoomBooking datum in roomBookingData) {
      int counter = 0;
      for (int i = 0; i < datum.displayArray.length; i++) {
        if (datum.displayArray[i][selectedDay - 1] != -1) {
          sheet.getRangeByName("B${beginRow + counter}").setValue(datum
              .bookingData[datum.displayArray[i][selectedDay - 1]].subRoomID);
          sheet.getRangeByName("C${beginRow + counter}").setValue(datum
              .bookingData[datum.displayArray[i][selectedDay - 1]]
              .catData
              .catName);
          sheet.getRangeByName("D${beginRow + counter}").setValue(datum
              .bookingData[datum.displayArray[i][selectedDay - 1]]
              .catData
              .appearance);
          sheet
              .getRangeByName("E${beginRow + counter}")
              .setValue("lorem ipsum");
          sheet.getRangeByName("F${beginRow + counter}")
            ..setValue(
                datum.bookingData[datum.displayArray[i][selectedDay - 1]].note)
            ..cellStyle.wrapText = true;
          counter++;
        }
      }
      sheet.getRangeByName("A$beginRow:A${beginRow + counter - 1}")
        ..merge()
        ..setValue(datum.roomData.roomID);
      beginRow += counter;
    }

    return workbook.saveAsStream();
  }

  Future<int> downloadExcel(List<int> bytes) async {
    await AnchorElement(
        href:
            "data:application/octet-stream;charset:utf-16le;base64,${base64.encode(bytes)}")
      ..setAttribute("download", "GuestList-15-04-2023.xlsx")
      ..click();
    return 0;
  }
}
*/