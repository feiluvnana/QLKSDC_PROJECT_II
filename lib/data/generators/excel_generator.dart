import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import '../../models/order_model.dart';
import '../../models/addition_model.dart';
import '../../models/room_group_model.dart';
import '../../models/room_model.dart';
import '../../models/service_model.dart';
import '../dependencies/internal_storage.dart';

mixin ExcelGenerator {
  Future<void> createGuestList(int day, month, year) async {
    final Workbook wb = Workbook();
    final Worksheet ws = wb.worksheets[0];

    final Style titleStyle = wb.styles.add('titleStyle');
    titleStyle
      ..fontName = "Tahoma"
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

    List<RoomGroup> roomGroupsList =
        GetIt.I<InternalStorage>().read("roomGroupsList");
    int lastRow = 4;
    int currentRow = 4;
    DateTime guestListDate = DateTime(year, month, day);
    for (var roomGroup in roomGroupsList) {
      for (var order in roomGroup.ordersList) {
        if (ignoreHour(order.checkIn).isBefore(guestListDate) &&
            ignoreHour(order.checkOut).isAfter(guestListDate)) {
          ws.getRangeByName("B$currentRow")
            ..setText(order.subRoomNum.toString())
            ..cellStyle = cellStyle;
          ws.getRangeByName("C$currentRow")
            ..setText("Hạng ${order.eatingRank}")
            ..cellStyle = cellStyle;
          ws.getRangeByName("D$currentRow")
            ..setText(getStringFromServiceForPart1(
                order.additionsList, guestListDate))
            ..cellStyle = cellStyle;
          ws.getRangeByName("E$currentRow")
            ..setText(order.attention.toString())
            ..cellStyle = cellStyle;
          currentRow++;
        }
      }
      ws.getRangeByName("A$lastRow:A${currentRow - 1}")
        ..merge()
        ..setText(roomGroup.room.id)
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

    for (var roomGroup in roomGroupsList) {
      for (var order in roomGroup.ordersList) {
        if (ignoreHour(order.checkIn) == guestListDate) {
          ws.getRangeByName("B$currentRow")
            ..setText(order.subRoomNum.toString())
            ..cellStyle = cellStyle;
          ws.getRangeByName("C$currentRow")
            ..setText("Hạng ${order.eatingRank}")
            ..cellStyle = cellStyle;
          ws.getRangeByName("D$currentRow")
            ..setText(getStringFromServiceForPart2(guestListDate, order))
            ..cellStyle = cellStyle;
          ws.getRangeByName("E$currentRow")
            ..setText(order.attention.toString())
            ..cellStyle = cellStyle;
          currentRow++;
        }
      }
      ws.getRangeByName("A$lastRow:A${currentRow - 1}")
        ..merge()
        ..setText(roomGroup.room.id)
        ..cellStyle = cellStyle;
      lastRow = currentRow;
    }

    ws.getRangeByName("A$currentRow:E$currentRow")
      ..merge()
      ..rowHeight = 30
      ..setText("3. Danh sách khách check-out")
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

    for (var roomGroup in roomGroupsList) {
      for (var order in roomGroup.ordersList) {
        if (ignoreHour(order.checkOut) == guestListDate) {
          ws.getRangeByName("B$currentRow")
            ..setText(order.subRoomNum.toString())
            ..cellStyle = cellStyle;
          ws.getRangeByName("C$currentRow")
            ..setText("Hạng ${order.eatingRank}")
            ..cellStyle = cellStyle;
          ws.getRangeByName("D$currentRow")
            ..setText(getStringFromServiceForPart3(guestListDate, order))
            ..cellStyle = cellStyle;
          ws.getRangeByName("E$currentRow")
            ..setText(order.attention.toString())
            ..cellStyle = cellStyle;
          currentRow++;
        }
      }
      ws.getRangeByName("A$lastRow:A${currentRow - 1}")
        ..merge()
        ..setText(roomGroup.room.id)
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
      List<Addition>? list, DateTime guestListDate) {
    String str = "";
    int countService = 0;
    if (list == null) return str;
    for (var l in list) {
      Service s = GetIt.I<InternalStorage>()
          .read("servicesList")
          .firstWhere((element) => l.serviceID == element.id);
      if (s.name == "Đón mèo" || s.name == "Trả mèo") continue;
      if (l.time != null) {
        if (ignoreHour(l.time!) != guestListDate) continue;
      }
      str += "${++countService}. ${s.name}\n";
    }
    return str;
  }

  String getStringFromServiceForPart2(DateTime guestListDate, Order order) {
    String str = "";
    int countService = 0;
    var list = order.additionsList;
    if (list == null) return str;
    str += "Thời gian check-in: ${DateFormat("HH:mm").format(order.checkIn)}\n";
    for (var l in list) {
      Service s = GetIt.I<InternalStorage>()
          .read("servicesList")
          .firstWhere((element) => l.serviceID == element.id);
      if (s.name == "Đón mèo") {
        str += "${++countService}. ${s.name}\n";
        str += "   Thời gian: ${order.checkIn.hour}:${order.checkIn.minute}\n";
        continue;
      }
      if (l.time != null) {
        if (ignoreHour(l.time!) != guestListDate) continue;
      }
      str += "${++countService}. ${s.name}\n";
      if (l.quantity != null) {
        str += "   Số lượng khách đặt: ${l.quantity}";
      }
    }
    return str;
  }

  String getStringFromServiceForPart3(DateTime guestListDate, Order order) {
    String str = "";
    int countService = 0;
    var list = order.additionsList;
    if (list == null) return str;
    str +=
        "Thời gian check-out: ${DateFormat("HH:mm").format(order.checkOut)}\n";
    for (var l in list) {
      Service s = GetIt.I<InternalStorage>()
          .read("servicesList")
          .firstWhere((element) => l.serviceID == element.id);
      if (s.name == "Trả mèo") {
        str += "${++countService}. ${s.name}\n";
        str +=
            "   Thời gian: ${order.checkOut.hour}:${order.checkOut.minute}\n";
        continue;
      }
      if (l.time != null) {
        if (ignoreHour(l.time!) != guestListDate) continue;
      }
      str += "${++countService}. ${s.name}\n";
    }
    return str;
  }

  Future<void> createBill(
      {required int oidx,
      required int ridx,
      required int billID,
      required int billNum}) async {
    final Workbook wb = Workbook();
    final Worksheet ws = wb.worksheets[0];
    ws.pageSetup
      ..isFitToPage = true
      ..topMargin = 0.75
      ..rightMargin = 0.25
      ..leftMargin = 0.25
      ..bottomMargin = 0.25
      ..headerMargin = 0.3
      ..footerMargin = 0.3
      ..isCenterHorizontally = true;

    ws
      ..getRangeByName("A1").columnWidth = 2
      ..getRangeByName("B1").columnWidth = 7.44
      ..getRangeByName("C1").columnWidth = 4.22
      ..getRangeByName("D1").columnWidth = 2.70
      ..getRangeByName("D1").columnWidth = 4.56
      ..getRangeByName("E1").columnWidth = 5.33
      ..getRangeByName("G1").columnWidth = 8.11
      ..getRangeByName("H1").columnWidth = 2;
    ws
      ..getRangeByName("A2").rowHeight = 28.2
      ..getRangeByName("A3").rowHeight = 28.2
      ..getRangeByName("A6").rowHeight = 22.8;

    final Style titleStyle = wb.styles.add('titleStyle');
    titleStyle
      ..fontName = "Tahoma"
      ..fontSize = 12
      ..bold = true
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center;
    final Style totalStyle = wb.styles.add("totalStyle");
    totalStyle
      ..fontName = "Tahoma"
      ..fontSize = 7
      ..bold = true
      ..hAlign = HAlignType.right
      ..vAlign = VAlignType.center;
    final Style totalCellStyle = wb.styles.add("totalCellStyle");
    totalCellStyle
      ..fontName = "Tahoma"
      ..fontSize = 7
      ..bold = true
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center
      ..borders.all.lineStyle = LineStyle.thin;
    final Style cellStyle = wb.styles.add("cellStyle");
    cellStyle
      ..fontName = "Tahoma"
      ..fontSize = 7
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center
      ..borders.all.lineStyle = LineStyle.thin;
    final Style infoStyle = wb.styles.add("infoStyle");
    infoStyle
      ..fontName = "Tahoma"
      ..fontSize = 8
      ..hAlign = HAlignType.left
      ..vAlign = VAlignType.center;
    final Style sectionStyle = wb.styles.add("sectionStyle");
    sectionStyle
      ..fontName = "Tahoma"
      ..fontSize = 11
      ..bold = true
      ..hAlign = HAlignType.left
      ..vAlign = VAlignType.center;
    final Style contactStyle = wb.styles.add("contactStyle");
    contactStyle
      ..fontName = "Tahoma"
      ..fontSize = 8
      ..wrapText = true
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center;

    List<int> logoBytes =
        (await rootBundle.load("images/logo.png")).buffer.asUint8List();
    var picture = ws.pictures.addStream(2, 2, logoBytes);
    picture
      ..width = (picture.width * 0.32).toInt()
      ..height = (picture.height * 0.32).toInt();

    ws.getRangeByName("C2:G2")
      ..merge()
      ..setText("KHÁCH SẠN DỨA CON")
      ..cellStyle = titleStyle;
    ws.getRangeByName("C3:G3")
      ..merge()
      ..setText("Địa chỉ: 99 Nguyễn Chí Thanh, Láng Hạ, Đống Đa, TP Hà Nội.")
      ..cellStyle = contactStyle;
    ws.getRangeByName("C4:G4")
      ..merge()
      ..setText("SĐT: 0123456789")
      ..cellStyle = contactStyle;
    ws.getRangeByName("B6:G6")
      ..merge()
      ..setText("HOÁ ĐƠN THANH TOÁN")
      ..cellStyle = titleStyle;

    Order order = (GetIt.I<InternalStorage>().read("roomGroupsList")[ridx])
        .ordersList[oidx];
    Room room = GetIt.I<InternalStorage>().read("roomGroupsList")[ridx].room;
    ws.getRangeByName("B7:G7")
      ..merge()
      ..setText(
          "Thời gian thanh toán: ${DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now())}")
      ..cellStyle = infoStyle;
    ws.getRangeByName("B8:G8")
      ..merge()
      ..setText("Số hoá đơn: ${billID}_$billNum")
      ..cellStyle = infoStyle;
    ws.getRangeByName("B9:G9")
      ..merge()
      ..setText("Tên khách hàng: ${order.cat.owner.name}")
      ..cellStyle = infoStyle;
    ws.getRangeByName("B10:G10")
      ..merge()
      ..setText("Tên mèo: ${order.cat.name}")
      ..cellStyle = infoStyle;
    ws.getRangeByName("B11:G11")
      ..merge()
      ..setText(
          "Ngày đến: ${DateFormat("dd/MM/yyyy HH:mm").format(order.checkIn)}")
      ..cellStyle = infoStyle;
    ws.getRangeByName("B12:G12")
      ..merge()
      ..setText(
          "Ngày đi: ${DateFormat("dd/MM/yyyy HH:mm").format(order.checkOut)}")
      ..cellStyle = infoStyle;

    ws.getRangeByName("B14")
      ..setText("I. Tiền phòng")
      ..cellStyle = sectionStyle;
    ws.getRangeByName("B16")
      ..setText("Loại phòng")
      ..cellStyle = cellStyle;
    ws.getRangeByName("C16")
      ..setText("Số đêm")
      ..cellStyle = cellStyle;
    ws.getRangeByName("D16:E16")
      ..merge()
      ..setText("Đơn giá")
      ..cellStyle = cellStyle;
    ws.getRangeByName("F16:G16")
      ..merge()
      ..setText("Thành tiền")
      ..cellStyle = cellStyle;
    ws.getRangeByName("B17")
      ..setText(room.type)
      ..cellStyle = cellStyle;
    ws.getRangeByName("C17")
      ..setNumber(ignoreHour(order.checkOut)
          .difference(ignoreHour(order.checkIn))
          .inDays
          .toDouble())
      ..cellStyle = cellStyle
      ..numberFormat = "General";
    ws.getRangeByName("D17:E17")
      ..merge()
      ..setNumber(room.price)
      ..cellStyle = cellStyle
      ..numberFormat = "#,#";
    ws.getRangeByName("F17:G17")
      ..merge()
      ..setFormula("=D17*C17")
      ..cellStyle = totalCellStyle
      ..numberFormat = "#,#";

    ws.getRangeByName("B19")
      ..setText("II. Tiền dịch vụ")
      ..cellStyle = sectionStyle;
    ws.getRangeByName("B21:C21")
      ..merge()
      ..setText("Tên dịch vụ")
      ..cellStyle = cellStyle;
    ws.getRangeByName("D21")
      ..setText("SL")
      ..cellStyle = cellStyle;
    ws.getRangeByName("E21")
      ..setText("Đơn vị")
      ..cellStyle = cellStyle;
    ws.getRangeByName("F21")
      ..setText("Đơn giá")
      ..cellStyle = cellStyle;
    ws.getRangeByName("G21")
      ..setText("Thành tiền")
      ..cellStyle = cellStyle;
    int currentRow = 22;
    if (order.checkIn.hour < 14) {
      ws.getRangeByName("B$currentRow:C$currentRow")
        ..merge()
        ..setText("Check-in sớm")
        ..cellStyle = cellStyle;
      ws.getRangeByName("D$currentRow")
        ..setNumber(1)
        ..cellStyle = cellStyle
        ..numberFormat = "General";
      ws.getRangeByName("E$currentRow").cellStyle = cellStyle;
      ws.getRangeByName("F$currentRow")
        ..setFormula("=D17/2")
        ..cellStyle = cellStyle
        ..numberFormat = "#,#";
      ws.getRangeByName("G$currentRow")
        ..setFormula("=F$currentRow*D$currentRow")
        ..cellStyle = totalCellStyle;
      currentRow++;
    }
    if (order.checkOut.hour > 14 ||
        (order.checkOut.hour == 14 && order.checkOut.minute > 0)) {
      ws.getRangeByName("B$currentRow:C$currentRow")
        ..merge()
        ..setText("Check-out muộn")
        ..cellStyle = cellStyle;
      ws.getRangeByName("D$currentRow")
        ..setNumber(1)
        ..cellStyle = cellStyle
        ..numberFormat = "General";
      ws.getRangeByName("E$currentRow").cellStyle = cellStyle;
      ws.getRangeByName("F$currentRow")
        ..setFormula("=D17/2")
        ..cellStyle = cellStyle
        ..numberFormat = "#,#";
      ws.getRangeByName("G$currentRow")
        ..setFormula("=F$currentRow*D$currentRow")
        ..cellStyle = totalCellStyle;
      currentRow++;
    }
    if (order.eatingRank == 2) {
      ws.getRangeByName("B$currentRow:C$currentRow")
        ..merge()
        ..setText("Hạng ăn 2")
        ..cellStyle = cellStyle;
      ws.getRangeByName("D$currentRow")
        ..setNumber(1)
        ..cellStyle = cellStyle
        ..numberFormat = "General";
      ws.getRangeByName("E$currentRow").cellStyle = cellStyle;
      ws.getRangeByName("F$currentRow")
        ..setNumber(80000)
        ..cellStyle = cellStyle
        ..numberFormat = "#,#";
      ws.getRangeByName("G$currentRow")
        ..setFormula("=F$currentRow*D$currentRow")
        ..cellStyle = totalCellStyle;
      currentRow++;
    }
    if (order.eatingRank == 4) {
      ws.getRangeByName("B$currentRow:C$currentRow")
        ..merge()
        ..setText("Hạng ăn 4")
        ..cellStyle = cellStyle;
      ws.getRangeByName("D$currentRow")
        ..setNumber(1)
        ..cellStyle = cellStyle
        ..numberFormat = "General";
      ws.getRangeByName("E$currentRow").cellStyle = cellStyle;
      ws.getRangeByName("F$currentRow")
        ..setNumber(30000)
        ..cellStyle = cellStyle
        ..numberFormat = "#,#";
      ws.getRangeByName("G$currentRow")
        ..setFormula("=F$currentRow*D$currentRow")
        ..cellStyle = totalCellStyle;
      currentRow++;
    }
    Map<int, int> frequency = {};
    if (order.additionsList != null) {
      for (var a in order.additionsList!) {
        frequency.update(a.serviceID, (value) => value + (a.quantity ?? 1),
            ifAbsent: () => a.quantity ?? 1);
      }
      frequency.forEach((key, value) {
        Addition a = order.additionsList!
            .firstWhere((element) => element.serviceID == key);
        Service s = GetIt.I<InternalStorage>()
            .read("servicesList")
            .firstWhere((element) => a.serviceID == element.id);

        ws.getRangeByName("B$currentRow:C$currentRow")
          ..merge()
          ..setText(
              s.name + ((s.name == "Tắm") ? "(${order.cat.weightRank})" : ""))
          ..cellStyle = cellStyle;
        ws.getRangeByName("D$currentRow")
          ..setNumber((a.distance != null)
              ? double.parse(
                  (a.distance?.substring(1, a.distance?.indexOf("km)")))!)
              : (a.quantity != null)
                  ? a.quantity?.toDouble()
                  : value.toDouble())
          ..cellStyle = cellStyle
          ..numberFormat = "General";
        ws.getRangeByName("E$currentRow")
          ..setText((a.distance != null)
              ? "km"
              : (a.quantity != null)
                  ? "cái"
                  : "lần")
          ..cellStyle = cellStyle;
        ws.getRangeByName("F$currentRow")
          ..setNumber(s.price *
              ((order.cat.weightRank == "< 3kg" || s.name != "Tắm")
                  ? 1
                  : (order.cat.weightRank == "> 6kg")
                      ? 1.5
                      : 1.25))
          ..cellStyle = cellStyle
          ..numberFormat = "#,#";
        ws.getRangeByName("G$currentRow")
          ..setFormula("=F$currentRow*D$currentRow")
          ..cellStyle = totalCellStyle;
        currentRow++;
      });
    }
    currentRow++;
    ws.getRangeByName("E$currentRow")
      ..setText("Tổng:")
      ..cellStyle = infoStyle;
    ws.getRangeByName("G$currentRow")
      ..setFormula("=SUM(G1:G${currentRow - 1})")
      ..cellStyle = totalStyle
      ..numberFormat = "#,#";
    currentRow++;
    ws.getRangeByName("E$currentRow")
      ..setText("Khách đưa:")
      ..cellStyle = infoStyle;
    ws.getRangeByName("G$currentRow")
      ..setNumber(0)
      ..cellStyle = totalStyle
      ..numberFormat = "#,#";
    currentRow++;
    ws.getRangeByName("E$currentRow")
      ..setText("Trả lại:")
      ..cellStyle = infoStyle;
    ws.getRangeByName("G$currentRow")
      ..setFormula("G${currentRow - 1}-G${currentRow - 2}")
      ..cellStyle = totalStyle
      ..numberFormat = "#,#";
    currentRow++;
    ws.getRangeByName("E$currentRow")
      ..setText("(Đã bao gồm thuế GTGT)")
      ..cellStyle = infoStyle;

    final rawData = wb.saveAsStream();
    wb.dispose();
    final content = base64Encode(rawData);
    AnchorElement(
        href: "data:application/octet-stream;charset=utf-16le;base64,$content")
      ..setAttribute("download", "bill $billID-$billNum.xlsx")
      ..click();
  }
}
