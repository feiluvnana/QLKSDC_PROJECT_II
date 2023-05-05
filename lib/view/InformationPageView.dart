import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_ii/controller/InformationPageController.dart';
import 'package:project_ii/model/BookingModel.dart';
import 'package:project_ii/model/RoomModel.dart';
import '../model/RoomBookingModel.dart';
import '../model/ServiceModel.dart';
import '../utils/InternalStorage.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              left: 90, right: MediaQuery.of(context).size.width / 10 * 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () => Get.back(result: {"result": null}),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        FaIcon(FontAwesomeIcons.arrowLeft, size: 14),
                        Text(" Quay lại")
                      ],
                    )),
              ),
              const SizedBox(height: 10),
              const CatInfo(),
              const SizedBox(height: 50),
              const OwnerInfo(),
              const SizedBox(height: 50),
              const BookingInfo(),
              const SizedBox(height: 50),
              const ServiceInfo(),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffff964f),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            FaIcon(FontAwesomeIcons.print, size: 14),
                            Text(" In thông tin")
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () => {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            FaIcon(FontAwesomeIcons.floppyDisk, size: 14),
                            Text(" Lưu thay đổi")
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xfffaf884),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () => {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            FaIcon(FontAwesomeIcons.moneyBill, size: 14),
                            Text(" Check-out")
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffff6961),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () => {
                          Get.defaultDialog<bool>(
                            title: "Cảnh Báo",
                            content: const Text(
                                "Hành động này không thể đảo ngược. Xác nhận tiếp tục?"),
                            confirm: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () => Get.back(result: true),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  FaIcon(FontAwesomeIcons.check, size: 14),
                                  Text(" Xác nhận")
                                ],
                              ),
                            ),
                            cancel: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffff6961),
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () => Get.back(result: false),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  FaIcon(FontAwesomeIcons.x, size: 14),
                                  Text(" Hủy")
                                ],
                              ),
                            ),
                          ).then((isConfirmed) {
                            if (isConfirmed == true) {
                              Get.find<InformationPageController>()
                                  .cancelBooking(
                                      bidx: int.parse(Get.parameters["bidx"]!),
                                      ridx: int.parse(Get.parameters["ridx"]!))
                                  .then((response) async {
                                if (response["flag"] == "beforeCheckIn") {
                                  await Get.defaultDialog(
                                      title: "Thông báo",
                                      content: Text(response["message"]!));
                                  Get.back(closeOverlays: true);
                                }
                              });
                            }
                          })
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            FaIcon(FontAwesomeIcons.ban, size: 14),
                            Text(" Hủy đặt phòng")
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CatInfo extends StatelessWidget {
  const CatInfo({super.key});

  @override
  Widget build(BuildContext context) {
    Booking bookingData = Get.find<InternalStorage>()
        .read("bookingDataForAllRooms")[int.parse(Get.parameters["ridx"]!)]
        .bookingDataList[int.parse(Get.parameters["bidx"]!)];
    Widget thisPageCatImage = (bookingData.catData.catImage == null)
        ? const Placeholder(color: Color(0xff68b6ef))
        : bookingData.catData.catImage!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Thông tin mèo",
          style: TextStyle(
            color: Color(0xff3d426b),
            fontSize: 28,
          ),
        ),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff68b6ef), width: 1)),
          child: Table(
            columnWidths: const {
              0: FixedColumnWidth(120),
              1: FixedColumnWidth(800)
            },
            border: const TableBorder(
                verticalInside: BorderSide(
                    width: 1,
                    color: Color(0xff68b6ef),
                    style: BorderStyle.solid)),
            children: [
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("Tên mèo"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(bookingData.catData.catName),
                  )
                ],
              ),
              TableRow(
                  decoration: const BoxDecoration(color: Color(0xffE3F2FD)),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Ảnh"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                          height: 400, width: 720, child: thisPageCatImage),
                    ),
                  ]),
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Giới tính"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(bookingData.catData.catGender ?? ""),
                  )
                ],
              ),
              TableRow(
                decoration: const BoxDecoration(color: Color(0xffE3F2FD)),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Tuổi"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(bookingData.catData.catAge.toString()),
                  )
                ],
              ),
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Thể trạng"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(bookingData.catData.catPhysicalCondition),
                  )
                ],
              ),
              TableRow(
                decoration: const BoxDecoration(color: Color(0xffE3F2FD)),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Giống"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(bookingData.catData.catSpecies ?? ""),
                  )
                ],
              ),
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Đặc điểm nhận dạng"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(bookingData.catData.catAppearance ?? ""),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

class OwnerInfo extends StatelessWidget {
  const OwnerInfo({super.key});

  @override
  Widget build(BuildContext context) {
    Booking bookingData = Get.find<InternalStorage>()
        .read("bookingDataForAllRooms")[int.parse(Get.parameters["ridx"]!)]
        .bookingDataList[int.parse(Get.parameters["bidx"]!)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Thông tin chủ",
          style: TextStyle(
            color: Color(0xff3d426b),
            fontSize: 28,
          ),
        ),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff68b6ef), width: 1)),
          child: Table(
            columnWidths: const {
              0: FixedColumnWidth(120),
              1: FixedColumnWidth(800)
            },
            border: const TableBorder(
                verticalInside: BorderSide(
                    width: 1,
                    color: Color(0xff68b6ef),
                    style: BorderStyle.solid)),
            children: [
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("Tên chủ"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text((bookingData.catData.ownerData.ownerGender ==
                            "Nam")
                        ? "(Anh) ${bookingData.catData.ownerData.ownerName}"
                        : "(Chị) ${bookingData.catData.ownerData.ownerName}"),
                  )
                ],
              ),
              TableRow(
                decoration: const BoxDecoration(color: Color(0xffe3f2fd)),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Số điện thoại"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(bookingData.catData.ownerData.ownerTel),
                  )
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}

class BookingInfo extends StatelessWidget {
  const BookingInfo({super.key});

  @override
  Widget build(BuildContext context) {
    List<RoomBooking> bookingDataForAllRooms =
        Get.find<InternalStorage>().read("bookingDataForAllRooms");
    Booking bookingData =
        bookingDataForAllRooms[int.parse(Get.parameters["ridx"]!)]
            .bookingDataList[int.parse(Get.parameters["bidx"]!)];
    Room roomData =
        bookingDataForAllRooms[int.parse(Get.parameters["ridx"]!)].roomData;
    List<Service> allServiceList =
        Get.find<InternalStorage>().read("allServiceList");
    return GetBuilder<InformationPageController>(
        id: "form1",
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Thông tin đặt phòng ",
                    style: TextStyle(
                      color: Color(0xff3d426b),
                      fontSize: 28,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async => await controller.toggleForm1(
                        bookingData: bookingData, roomData: roomData),
                    child: FaIcon(
                        (controller.editForm1)
                            ? FontAwesomeIcons.xmark
                            : FontAwesomeIcons.penToSquare,
                        size: 28,
                        color: const Color(0xff68b6ef)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Form(
                key: controller.formKey1,
                child: Container(
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xff68b6ef), width: 1)),
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(120),
                      1: FixedColumnWidth(800)
                    },
                    border: const TableBorder(
                        verticalInside: BorderSide(
                            width: 1,
                            color: Color(0xff68b6ef),
                            style: BorderStyle.solid)),
                    children: [
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Số phòng"),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: (bookingData.checkInDate
                                        .isBefore(DateTime.now()) ||
                                    !controller.editForm1)
                                ? Text(
                                    "${roomData.roomID}(${bookingData.subNumber})")
                                : Row(
                                    children: [
                                      Flexible(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 16),
                                          child:
                                              DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            items: List.generate(
                                                bookingDataForAllRooms.length,
                                                (index) => DropdownMenuItem(
                                                    value:
                                                        bookingDataForAllRooms[
                                                                index]
                                                            .roomData
                                                            .roomID,
                                                    child: Text(
                                                        bookingDataForAllRooms[
                                                                index]
                                                            .roomData
                                                            .roomID))),
                                            onChanged: (String? value) {
                                              if (value == null) return;
                                              controller.modifiedSubNumber = 1;
                                              controller.modifiedRoomID = value;
                                            },
                                            value: controller.modifiedRoomID,
                                            hint: const Text("---"),
                                            decoration: const InputDecoration(
                                              errorMaxLines: 3,
                                              labelText: "Mã phòng",
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 16),
                                          child: DropdownButtonFormField<int>(
                                            isExpanded: true,
                                            items: List.generate(
                                                bookingDataForAllRooms
                                                    .firstWhere((element) =>
                                                        element
                                                            .roomData.roomID ==
                                                        controller
                                                            .modifiedRoomID)
                                                    .roomData
                                                    .subQuantity,
                                                (index) => DropdownMenuItem(
                                                    value: index + 1,
                                                    child:
                                                        Text("${index + 1}"))),
                                            onChanged: (int? value) {
                                              if (value == null) return;
                                              controller.modifiedSubNumber =
                                                  value;
                                            },
                                            value: controller.modifiedSubNumber,
                                            hint: const Text("---"),
                                            decoration: const InputDecoration(
                                              errorMaxLines: 3,
                                              labelText: "Mã phòng con",
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                      TableRow(
                        decoration:
                            const BoxDecoration(color: Color(0xffE3F2FD)),
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Ngày đặt phòng"),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(DateFormat("yyyy-MM-dd HH:mm:ss")
                                .format(bookingData.bookingDate)),
                          )
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Hạng ăn"),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: (!controller.editForm1 ||
                                    bookingData.checkInDate
                                        .isBefore(DateTime.now()))
                                ? Text(bookingData.eatingRank.toString())
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 16),
                                    child: DropdownButtonFormField<int>(
                                      isExpanded: true,
                                      items: List.generate(
                                        4,
                                        (index) => DropdownMenuItem(
                                          value: index + 1,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text("${index + 1}"),
                                              const SizedBox(width: 10),
                                              const Tooltip(
                                                  message:
                                                      "Chi tiết:\nĐề xuất\nGiá thành:",
                                                  child: FaIcon(
                                                      FontAwesomeIcons
                                                          .circleInfo,
                                                      size: 14))
                                            ],
                                          ),
                                        ),
                                      ),
                                      onChanged: (int? value) {
                                        if (value == null) return;
                                        controller.modifiedEatingRank = value;
                                      },
                                      value: controller.modifiedEatingRank,
                                      hint: const Text("---"),
                                      decoration: const InputDecoration(
                                        errorMaxLines: 2,
                                        labelText: "Hạng ăn",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                          )
                        ],
                      ),
                      TableRow(
                        decoration:
                            const BoxDecoration(color: Color(0xffE3F2FD)),
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Lịch trình"),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(text: "Check-in:\n"),
                                          TextSpan(
                                            text: DateFormat(
                                                    "yyyy-MM-dd HH:mm:ss")
                                                .format(
                                                    bookingData.checkInDate),
                                            style: TextStyle(
                                                color: (bookingData
                                                            .checkInDate.hour <
                                                        14)
                                                    ? Colors.red
                                                    : null),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(text: "Check-out:\n"),
                                          TextSpan(
                                            text: DateFormat(
                                                    "yyyy-MM-dd HH:mm:ss")
                                                .format(
                                                    bookingData.checkOutDate),
                                            style: TextStyle(
                                                color: (bookingData.checkOutDate
                                                                .hour >
                                                            14 ||
                                                        (bookingData.checkOutDate
                                                                    .hour ==
                                                                14 &&
                                                            bookingData
                                                                    .checkOutDate
                                                                    .minute >
                                                                0))
                                                    ? Colors.red
                                                    : null),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ]),
                          )
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Lễ tân tiếp nhận"),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(bookingData.byRep),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }
}

class ServiceInfo extends StatelessWidget {
  const ServiceInfo({super.key});

  @override
  Widget build(BuildContext context) {
    Booking bookingData = Get.find<InternalStorage>()
        .read("bookingDataForAllRooms")[int.parse(Get.parameters["ridx"]!)]
        .bookingDataList[int.parse(Get.parameters["bidx"]!)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Thông tin dịch vụ",
          style: TextStyle(
            color: Color(0xff3d426b),
            fontSize: 28,
          ),
        ),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff68b6ef), width: 1)),
          child: Table(
            columnWidths: const {
              0: FixedColumnWidth(120),
              1: FixedColumnWidth(800)
            },
            border: const TableBorder(
                verticalInside: BorderSide(
                    width: 1,
                    color: Color(0xff68b6ef),
                    style: BorderStyle.solid)),
            children: [
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("Danh sách dịch vụ"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xff68b6ef), width: 1)),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(),
                          1: FlexColumnWidth(),
                          2: FlexColumnWidth(),
                        },
                        border: const TableBorder(
                            verticalInside: BorderSide(
                                width: 1,
                                color: Color(0xff68b6ef),
                                style: BorderStyle.solid)),
                        children: [
                          const TableRow(children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Tên dịch vụ"),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Thông tin"),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Đơn giá"),
                            )
                          ]),
                          ...List.generate(
                              (bookingData.bookingServiceList == null)
                                  ? 0
                                  : bookingData.bookingServiceList!.length,
                              (index) {
                            var serviceQuantity = bookingData
                                .bookingServiceList![index].serviceQuantity;
                            var serviceTime = bookingData
                                .bookingServiceList![index].serviceTime;
                            var serviceDistance = bookingData
                                .bookingServiceList![index].serviceDistance;
                            return TableRow(
                              decoration: (index % 2 == 0)
                                  ? BoxDecoration(color: Colors.grey[200])
                                  : null,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(bookingData
                                      .bookingServiceList![index].serviceName),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "${(serviceQuantity == null) ? "" : "Số lượng: $serviceQuantity\n"}${(serviceTime == null) ? "" : "Thời gian: ${DateFormat("dd/MM/yyyy").format(serviceTime)}\n"}${(serviceDistance == null) ? "" : "Khoảng cách: ${serviceDistance}km"}"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(bookingData
                                      .bookingServiceList![index].servicePrice
                                      .toInt()
                                      .toString()),
                                ),
                              ],
                            );
                          })
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}

class DateTimePicker extends StatelessWidget {
  final TextEditingController controller;
  final String titleOfTextField;
  final String? Function(String?)? validator;
  final int isOutSerIn;
  final int? index1;

  const DateTimePicker(
      {super.key,
      required this.controller,
      required this.titleOfTextField,
      this.validator,
      required this.isOutSerIn,
      this.index1});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: MaterialStateMouseCursor.clickable,
      onTap: () async {
        var date = (await showDatePicker(
          locale: const Locale("vi", "VN"),
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2023),
          lastDate: DateTime(2030),
          helpText: "Chọn ngày",
          cancelText: "Hủy",
          confirmText: "Xác nhận",
        ));
        if (date == null) return;
        var time = (await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          helpText: "Chọn giờ",
          cancelText: "Hủy",
          confirmText: "Xác nhận",
        ));
        if (time == null) return;
        date =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);
        if (isOutSerIn > 0) {
          Get.find().checkInDate = date;
        } else if (isOutSerIn < 0) {
          Get.find().checkOutDate = date;
        } else {
          Get.find().serviceTimeValue[index1!] = date;
        }
        if (context.mounted) {
          controller.text = DateFormat('dd/MM/yyyy HH:mm').format(date);
        }
      },
      child: IgnorePointer(
        child: TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            errorMaxLines: 2,
            labelText: titleOfTextField,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
