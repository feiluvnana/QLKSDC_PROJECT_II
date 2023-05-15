import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_ii/controller/InformationPageController.dart';
import 'package:project_ii/model/OrderModel.dart';
import 'package:project_ii/model/RoomModel.dart';
import '../model/RoomGroupModel.dart';
import '../model/ServiceModel.dart';
import '../utils/GoogleMaps.dart';
import '../utils/InternalStorage.dart';
import '../utils/ExcelGenerator.dart';

class InformationPage extends StatelessWidget with ExcelGenerator {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        primary: true,
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
                    onPressed: () => Get.offNamed("/home"),
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
                        onPressed: () {
                          Get.find<InformationPageController>()
                              .saveChanges(
                                  bidx: int.parse(Get.parameters["bidx"]!),
                                  ridx: int.parse(Get.parameters["ridx"]!))
                              .then((response) async {
                            if (response["validation"] == false) return;
                            if (response["form1Init"] == true &&
                                response["form2Init"] == true) {
                              await Get.defaultDialog(
                                  title: "Thông báo",
                                  content: Text(
                                      "${response["form1"] == true ? "Lưu thay đổi thông tin đặt phòng thành công" : "Lưu thay đổi thông tin đặt phòng thất bại"}\n${response["form2"] == true ? "Lưu thay đổi thông tin dịch vụ thành công" : "Lưu thay đổi thông tin dịch vụ thất bại"}"));
                              Get.offNamed("/home");
                            } else if (response["form1Init"] == true &&
                                response["form2Init"] == false) {
                              await Get.defaultDialog(
                                  title: "Thông báo",
                                  content: Text(response["form1"] == true
                                      ? "Lưu thay đổi thông tin đặt phòng thành công"
                                      : "Lưu thay đổi thông tin đặt phòng thất bại"));
                              Get.offNamed("/home");
                            } else if (response["form1Init"] == false &&
                                response["form2Init"] == true) {
                              await Get.defaultDialog(
                                  title: "Thông báo",
                                  content: Text(response["form2"] == true
                                      ? "Lưu thay đổi thông tin dịch vụ thành công"
                                      : "Lưu thay đổi thông tin dịch vụ thất bại"));
                              Get.offNamed("/home");
                            } else if (response["form1Init"] == true &&
                                response["form2Init"] == true) {}
                          });
                        },
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
                        onPressed: () {
                          createBill(
                              bidx: int.parse(Get.parameters["bidx"]!),
                              ridx: int.parse(Get.parameters["ridx"]!));
                        },
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
                                if (response == "accepted") {
                                  await Get.defaultDialog(
                                      title: "Thông báo",
                                      content: const Text(
                                          "Huỷ đặt phòng thành công"));
                                  Get.offNamed("/home");
                                } else {
                                  await Get.defaultDialog(
                                      title: "Thông báo",
                                      content:
                                          const Text("Huỷ đặt phòng thất bại"));
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
    Order order = (Get.find<InternalStorage>()
                .read("roomGroupsList")[int.parse(Get.parameters["ridx"]!)]
            as RoomGroup)
        .ordersList[int.parse(Get.parameters["bidx"]!)];
    Widget thisPageCatImage = (order.cat.image == null)
        ? const Placeholder(color: Color(0xff68b6ef))
        : order.cat.image!;

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
                    child: Text(order.cat.name),
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
                    child: Text(order.cat.gender ?? ""),
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
                    child: Text(order.cat.age.toString()),
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
                    child: Text(order.cat.physicalCondition),
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
                    child: Text(order.cat.species ?? ""),
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
                    child: Text(order.cat.catAppearance ?? ""),
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
    Order order = (Get.find<InternalStorage>()
                .read("roomGroupsList")[int.parse(Get.parameters["ridx"]!)]
            as RoomGroup)
        .ordersList[int.parse(Get.parameters["bidx"]!)];
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
                    child: Text((order.cat.owner.gender == "Nam")
                        ? "(Anh) ${order.cat.owner.name}"
                        : "(Chị) ${order.cat.owner.name}"),
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
                    child: Text(order.cat.owner.tel),
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
    List<RoomGroup> roomGroupsList =
        Get.find<InternalStorage>().read("roomGroupsList");
    Order order = roomGroupsList[int.parse(Get.parameters["ridx"]!)]
        .ordersList[int.parse(Get.parameters["bidx"]!)];
    Room roomData = roomGroupsList[int.parse(Get.parameters["ridx"]!)].room;
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
                        order: order, room: roomData),
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
                            child: (!controller.editForm1)
                                ? Text("${roomData.id}(${order.subRoomNum})")
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
                                                roomGroupsList.length,
                                                (index) => DropdownMenuItem(
                                                    value: roomGroupsList[index]
                                                        .room
                                                        .id,
                                                    child: Text(
                                                        roomGroupsList[index]
                                                            .room
                                                            .id))),
                                            onChanged: (!order.checkIn
                                                    .isBefore(DateTime.now()))
                                                ? (String? value) {
                                                    if (value == null) return;
                                                    controller
                                                        .modifiedSubNumber = 1;
                                                    controller.modifiedRoomID =
                                                        value;
                                                  }
                                                : null,
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
                                                roomGroupsList
                                                    .firstWhere((element) =>
                                                        element.room.id ==
                                                        controller
                                                            .modifiedRoomID)
                                                    .room
                                                    .total,
                                                (index) => DropdownMenuItem(
                                                    value: index + 1,
                                                    child:
                                                        Text("${index + 1}"))),
                                            onChanged: (!order.checkIn
                                                    .isBefore(DateTime.now()))
                                                ? (int? value) {
                                                    if (value == null) return;
                                                    controller
                                                            .modifiedSubNumber =
                                                        value;
                                                  }
                                                : null,
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
                                .format(order.date)),
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
                            child: (!controller.editForm1)
                                ? Text(order.eatingRank.toString())
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
                                      onChanged: (!order.checkIn
                                              .isBefore(DateTime.now()))
                                          ? (int? value) {
                                              if (value == null) return;
                                              controller.modifiedEatingRank =
                                                  value;
                                            }
                                          : null,
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
                            child: (!controller.editForm1)
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                        Flexible(
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                const TextSpan(
                                                    text: "Check-in:\n"),
                                                TextSpan(
                                                  text: DateFormat(
                                                          "yyyy-MM-dd HH:mm")
                                                      .format(order.checkIn),
                                                  style: TextStyle(
                                                      color:
                                                          (order.checkIn.hour <
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
                                                const TextSpan(
                                                    text: "Check-out:\n"),
                                                TextSpan(
                                                  text: DateFormat(
                                                          "yyyy-MM-dd HH:mm")
                                                      .format(order.checkOut),
                                                  style: TextStyle(
                                                      color: (order.checkOut
                                                                      .hour >
                                                                  14 ||
                                                              (order.checkOut
                                                                          .hour ==
                                                                      14 &&
                                                                  order.checkOut
                                                                          .minute >
                                                                      0))
                                                          ? Colors.red
                                                          : null),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ])
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                        Flexible(
                                          child: DateTimePicker(
                                            controller: controller
                                                .modifiedCheckInDateController,
                                            titleOfTextField:
                                                "Thời gian check-in",
                                            isOutSerIn: 1,
                                            validator: (value) {
                                              if (controller
                                                  .modifiedCheckInDateController
                                                  .text
                                                  .isEmpty)
                                                return "Không để trống thời gian check-in";
                                              if (controller.modifiedCheckInDate
                                                  .isBefore(DateTime.now()))
                                                return "Không thể check-in trong quá khứ";
                                              if (controller
                                                  .modifiedCheckOutDateController
                                                  .text
                                                  .isNotEmpty) {
                                                if (!controller
                                                    .modifiedCheckInDate
                                                    .isBefore(controller
                                                        .modifiedCheckOutDate))
                                                  return "Thời gian check-in phải trước thời gian check-out";
                                              }
                                              return null;
                                            },
                                            isEnabled: !order.checkIn
                                                .isBefore(DateTime.now()),
                                          ),
                                        ),
                                        const Spacer(),
                                        Flexible(
                                          child: DateTimePicker(
                                              controller: controller
                                                  .modifiedCheckOutDateController,
                                              titleOfTextField:
                                                  "Thời gian check-out",
                                              isOutSerIn: -1,
                                              validator: (value) {
                                                if (controller
                                                    .modifiedCheckOutDateController
                                                    .text
                                                    .isEmpty)
                                                  return "Không để trống thời gian check-out";
                                                if (controller
                                                    .modifiedCheckInDateController
                                                    .text
                                                    .isNotEmpty) {
                                                  if (!controller
                                                      .modifiedCheckOutDate
                                                      .isAfter(controller
                                                          .modifiedCheckInDate))
                                                    return "Thời gian check-in phải trước thời gian check-out";
                                                }
                                                return null;
                                              }),
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
                            child: Text(order.inCharge),
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
    List<RoomGroup> roomGroupsList =
        Get.find<InternalStorage>().read("roomGroupsList");
    Order order = roomGroupsList[int.parse(Get.parameters["ridx"]!)]
        .ordersList[int.parse(Get.parameters["bidx"]!)];
    Room room = roomGroupsList[int.parse(Get.parameters["ridx"]!)].room;
    return GetBuilder<InformationPageController>(
        id: "form2",
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Thông tin dịch vụ ",
                    style: TextStyle(
                      color: Color(0xff3d426b),
                      fontSize: 28,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async =>
                        await controller.toggleForm2(order: order, room: room),
                    child: FaIcon(
                        (controller.editForm2)
                            ? FontAwesomeIcons.xmark
                            : FontAwesomeIcons.penToSquare,
                        size: 28,
                        color: const Color(0xff68b6ef)),
                  ),
                ],
              ),
              Container(
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
                          child: Text("Danh sách dịch vụ"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xff68b6ef), width: 1)),
                            child: (!controller.editForm2)
                                ? Table(
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
                                          (order.additionsList == null)
                                              ? 0
                                              : order.additionsList!.length,
                                          (index) {
                                        var serviceQuantity = order
                                            .additionsList![index].quantity;
                                        var serviceTime =
                                            order.additionsList![index].time;
                                        var serviceDistance = order
                                            .additionsList![index].distance;
                                        return TableRow(
                                          decoration: (index % 2 == 0)
                                              ? const BoxDecoration(
                                                  color: Color(0xffE3F2FD))
                                              : null,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(order
                                                  .additionsList![index]
                                                  .serviceName),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  "${(serviceQuantity == null) ? "" : "Số lượng: $serviceQuantity\n"}${(serviceTime == null) ? "" : "Thời gian: ${DateFormat("dd/MM/yyyy HH:mm").format(serviceTime)}\n"}${(serviceDistance == null) ? "" : "Thông tin vị trí: $serviceDistance"}"),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(order
                                                  .additionsList![index]
                                                  .servicePrice
                                                  .toInt()
                                                  .toString()),
                                            ),
                                          ],
                                        );
                                      })
                                    ],
                                  )
                                : Form(
                                    key: controller.formKey2,
                                    child: ServiceModifier(
                                        controller: controller)),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          );
        });
  }
}

class ServiceModifier extends StatelessWidget {
  final InformationPageController controller;

  const ServiceModifier({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return FormField(
      builder: (state) => Padding(
        padding: const EdgeInsets.all(10),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: "Danh sách dịch vụ",
            border: OutlineInputBorder(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  controller.modifiedNumberOfAdditions,
                  (index1) =>
                      ServiceInput(controller: controller, index1: index1),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    controller.modifiedAdditionsList.add(-1);
                    controller.modifiedAdditionTime.add(null);
                    controller.modifiedAdditionDistance.add(null);
                    controller.modifiedAdditionQuantity.add(null);
                    controller.modifiedAdditionTimeValue.add(null);
                    controller.modifiedNumberOfAdditions =
                        controller.modifiedNumberOfAdditions + 1;
                  },
                  child: const Text("Thêm dịch vụ"))
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceInput extends StatelessWidget {
  final InformationPageController controller;
  final int index1;

  const ServiceInput(
      {super.key, required this.controller, required this.index1});

  @override
  Widget build(BuildContext context) {
    Order order = (Get.find<InternalStorage>()
                .read("roomGroupsList")[int.parse(Get.parameters["ridx"]!)]
            as RoomGroup)
        .ordersList[int.parse(Get.parameters["bidx"]!)];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: DropdownButtonFormField<int>(
              isExpanded: true,
              items: List.generate(
                Get.find<InternalStorage>().read("servicesList").length,
                (index2) => DropdownMenuItem(
                  value: index2 + 1,
                  child: Text(Get.find<InternalStorage>()
                      .read("servicesList")[index2]
                      .name),
                ),
              ),
              onChanged: (int? value) {
                controller.modifiedAdditionsList[index1] = value!;
                controller.createModifiedController(value, index1);
              },
              validator: (value) {
                if (value == null) return "Không để trống loại dịch vụ";
                return null;
              },
              value: (controller.modifiedAdditionsList[index1] == -1)
                  ? null
                  : controller.modifiedAdditionsList[index1],
              hint: const Text("---"),
              decoration: const InputDecoration(
                labelText: "Loại dịch vụ",
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        (controller.modifiedAdditionTime[index1] == null)
            ? Flexible(flex: 0, child: Container())
            : Flexible(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: DateTimePicker(
                      controller: controller.modifiedAdditionTime[index1]!,
                      titleOfTextField: "Thời gian",
                      validator: (value) {
                        if (controller.modifiedAdditionTimeValue[index1] ==
                            null) return "Không để trống thời gian";

                        if (controller.modifiedAdditionTimeValue[index1]!
                                .isAfter(order.checkOut) ||
                            controller.modifiedAdditionTimeValue[index1]!
                                .isBefore(order.checkIn)) {
                          return "Thời gian phải nằm trong khoảng check-in và check-out";
                        }
                        return null;
                      },
                      isOutSerIn: 0,
                      index1: index1),
                ),
              ),
        (controller.modifiedAdditionQuantity[index1] == null)
            ? Flexible(flex: 0, child: Container())
            : ServiceValue(
                controller: controller.modifiedAdditionQuantity[index1]!,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Không để trống số lượng";
                  if (!RegExp(r'^[1-9]\d*').hasMatch(value))
                    return "Số lượng không đúng định dạng";
                  return null;
                },
                label: "Số lượng"),
        (controller.modifiedAdditionDistance[index1] == null)
            ? Flexible(flex: 0, child: Container())
            : Flexible(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: TextFormField(
                    controller: controller.modifiedAdditionDistance[index1]!,
                    readOnly: true,
                    decoration: InputDecoration(
                        labelText: "Thông tin vị trí",
                        border: const OutlineInputBorder(),
                        suffix: InkWell(
                            onTap: () async {
                              await Get.to(() => const MyApp())?.then((value) {
                                controller.modifiedAdditionDistance[index1]
                                        ?.text =
                                    "(${value["distance"].toStringAsPrecision(2)}km) ${value["address"]}";
                              });
                            },
                            child: const FaIcon(FontAwesomeIcons.map))),
                  ),
                ),
              ),
        Flexible(
            child: ElevatedButton(
                onPressed: () {
                  controller.modifiedAdditionsList.removeAt(index1);
                  controller.modifiedAdditionTime.removeAt(index1);
                  controller.modifiedAdditionQuantity.removeAt(index1);
                  controller.modifiedAdditionDistance.removeAt(index1);
                  controller.modifiedAdditionTimeValue.removeAt(index1);
                  controller.modifiedNumberOfAdditions =
                      controller.modifiedNumberOfAdditions - 1;
                },
                child: const Text("Xóa dịch vụ"))),
      ],
    );
  }
}

class ServiceValue extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;
  final String label;
  final String? suffix;

  const ServiceValue(
      {super.key,
      required this.controller,
      required this.validator,
      required this.label,
      this.suffix});

  @override
  Widget build(BuildContext context) {
    print("ServiceValue build");
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            suffix: (suffix == null) ? null : Text(suffix!),
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}

class DateTimePicker extends StatelessWidget {
  final TextEditingController controller;
  final String titleOfTextField;
  final String? Function(String?)? validator;
  final int isOutSerIn;
  final bool isEnabled;
  final int? index1;

  const DateTimePicker(
      {super.key,
      required this.controller,
      required this.titleOfTextField,
      this.validator,
      required this.isOutSerIn,
      this.isEnabled = true,
      this.index1});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: MaterialStateMouseCursor.clickable,
      onTap: () async {
        if (!isEnabled) return;
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
          Get.find<InformationPageController>().modifiedCheckInDate = date;
        } else if (isOutSerIn < 0) {
          Get.find<InformationPageController>().modifiedCheckOutDate = date;
        } else {
          Get.find<InformationPageController>()
              .modifiedAdditionTimeValue[index1!] = date;
        }
        if (context.mounted) {
          controller.text = DateFormat('dd/MM/yyyy HH:mm').format(date);
        }
      },
      child: IgnorePointer(
        child: TextFormField(
          enabled: isEnabled,
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
