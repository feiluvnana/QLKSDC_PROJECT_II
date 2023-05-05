import 'dart:convert';
import 'dart:html';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:intl/intl.dart';
import '../model/BookingModel.dart';
import '../model/BookingServiceModel.dart';
import '../model/RoomBookingModel.dart';
import '../utils/InternalStorage.dart';

mixin GuestList {
  Future<void> createSpreadSheet(int day, month, year) async {
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
      ..setText("Danh sách khách hàng $day-$month-$year")
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
        Get.find<InternalStorage>().read("bookingDataForAllRooms");
    int lastRow = 4;
    int currentRow = 4;
    DateTime guestListDate = DateTime(year, month, day);
    for (var bdForARoom in bookingDataForAllRooms) {
      for (var bd in bdForARoom.bookingDataList) {
        if (ignoreHour(bd.checkInDate).isBefore(guestListDate) &&
            ignoreHour(bd.checkOutDate).isAfter(guestListDate)) {
          ws.getRangeByName("B$currentRow")
            ..setText(bd.subNumber.toString())
            ..cellStyle = cellStyle;
          ws.getRangeByName("C$currentRow")
            ..setText("Hạng ${bd.eatingRank}")
            ..cellStyle = cellStyle;
          ws.getRangeByName("D$currentRow")
            ..setText(getStringFromServiceForPart1(
                bd.bookingServiceList, guestListDate))
            ..cellStyle = cellStyle;
          ws.getRangeByName("E$currentRow")
            ..setText(bd.attention.toString())
            ..cellStyle = cellStyle;
          currentRow++;
        }
      }
      ws.getRangeByName("A$lastRow:A${currentRow - 1}")
        ..merge()
        ..setText(bdForARoom.roomData.roomID)
        ..cellStyle = cellStyle;
      lastRow = currentRow;
    }

    ws.getRangeByName("A$currentRow:E$currentRow")
      ..merge()
      ..rowHeight = 30
      ..setText("2. Danh sách khách check-in")
      ..cellStyle = titleStyle;
    currentRow++;

    ws.getRangeByName("A$currentRow:B$currentRow")
      ..merge()
      ..setText("Phòng")
      ..cellStyle = cellStyle;
    ws.getRangeByName("C$currentRow")
      ..setText("Hạng ăn")
      ..cellStyle = cellStyle;
    ws.getRangeByName("D$currentRow")
      ..setText("Thông tin")
      ..cellStyle = cellStyle;
    ws.getRangeByName("E$currentRow")
      ..setText("Lưu ý")
      ..cellStyle = cellStyle;
    currentRow++;
    lastRow = currentRow;

    for (var bdForARoom in bookingDataForAllRooms) {
      for (var bd in bdForARoom.bookingDataList) {
        if (ignoreHour(bd.checkInDate) == guestListDate) {
          ws.getRangeByName("B$currentRow")
            ..setText(bd.subNumber.toString())
            ..cellStyle = cellStyle;
          ws.getRangeByName("C$currentRow")
            ..setText("Hạng ${bd.eatingRank}")
            ..cellStyle = cellStyle;
          ws.getRangeByName("D$currentRow")
            ..setText(getStringFromServiceForPart2(guestListDate, bd))
            ..cellStyle = cellStyle;
          ws.getRangeByName("E$currentRow")
            ..setText(bd.attention.toString())
            ..cellStyle = cellStyle;
          currentRow++;
        }
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
        href: "data:application/octet-stream;charset=utf-16le;base64,$content")
      ..setAttribute("download", "Danh sách khách hàng $day-$month-$year.xlsx")
      ..click();
  }

  DateTime ignoreHour(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String getStringFromServiceForPart1(
      List<BookingService>? list, DateTime guestListDate) {
    String str = "";
    int countService = 0;
    if (list == null) return str;
    for (var l in list) {
      if (l.serviceName == "Đón mèo" || l.serviceName == "Trả mèo") continue;
      if (l.serviceTime != null) {
        if (ignoreHour(l.serviceTime!) != guestListDate) continue;
      }
      str += "${++countService}. ${l.serviceName}\n";
    }
    return str;
  }

  String getStringFromServiceForPart2(
      DateTime guestListDate, Booking bookingData) {
    String str = "";
    int countService = 0;
    var list = bookingData.bookingServiceList;
    if (list == null) return str;
    str +=
        "Thời gian check-in: ${DateFormat("dd/MM/yyyy hh:mm").format(bookingData.checkInDate)}\n";
    for (var l in list) {
      if (l.serviceName == "Đón mèo") {
        str += "${++countService}. ${l.serviceName}\n";
        str +=
            "   Thời gian: ${l.serviceTime?.hour}:${l.serviceTime?.minute}\n";
        continue;
      }
      if (l.serviceTime != null) {
        if (ignoreHour(l.serviceTime!) != guestListDate) continue;
      }
      str += "${++countService}. ${l.serviceName}\n";
      if (l.serviceQuantity != null) {
        str += "   Số lượng khách đặt: ${l.serviceQuantity}";
      }
    }
    return str;
  }
}
