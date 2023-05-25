import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_ii/blocs/InformationPageController.dart';
import 'package:project_ii/model/OrderModel.dart';
import 'package:project_ii/model/RoomModel.dart';
import '../model/RoomGroupModel.dart';
import '../utils/GoogleMaps.dart';
import '../utils/InternalStorage.dart';
import '../data/generators/excel_generator.dart';
import '../utils/reusables/image_picker.dart';
import '../utils/validators/validators.dart';

class InformationPage extends StatelessWidget with ExcelGenerator {
  final int ridx, oidx;
  const InformationPage({super.key, required this.ridx, required this.oidx});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InformationPageBloc>(
      create: (context) => InformationPageBloc(ridx, oidx),
      child: Scaffold(
        body: SingleChildScrollView(
          primary: true,
          child: Padding(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width / 20,
                right: MediaQuery.of(context).size.width / 10 * 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Builder(builder: (_) {
                    return ElevatedButton(
                        onPressed: () =>
                            _.read<InformationPageBloc>().add(GotoHomePage(_)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            FaIcon(FontAwesomeIcons.arrowLeft, size: 14),
                            Text(" Quay lại")
                          ],
                        ));
                  }),
                ),
                const SizedBox(height: 10),
                const CatInfo(),
                const SizedBox(height: 50),
                const OwnerInfo(),
                const SizedBox(height: 50),
                BookingInfo(ridx: ridx, oidx: oidx),
                const SizedBox(height: 50),
                ServiceInfo(ridx: ridx, oidx: oidx),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Builder(builder: (_) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () {
                              _
                                  .read<InformationPageBloc>()
                                  .add(SaveChangesEvent());
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                FaIcon(FontAwesomeIcons.floppyDisk, size: 14),
                                Text(" Lưu thay đổi")
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    Flexible(
                      child: Builder(builder: (_) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xfffaf884),
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () {
                              _
                                  .read<InformationPageBloc>()
                                  .add(CheckoutEvent());
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                FaIcon(FontAwesomeIcons.moneyBill, size: 14),
                                Text(" Check-out")
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    Flexible(
                      child: Builder(builder: (_) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffff6961),
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () {
                              _
                                  .read<InformationPageBloc>()
                                  .add(SaveChangesEvent());
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                FaIcon(FontAwesomeIcons.ban, size: 14),
                                Text(" Hủy đặt phòng")
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
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
    return BlocBuilder<InformationPageBloc, InformationState>(
      buildWhen: (previous, current) =>
          previous.isEditing1 != current.isEditing1,
      builder: (context, state) {
        return Form(
          key: state.formKey1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Thông tin mèo ",
                    style: TextStyle(
                      color: Color(0xff3d426b),
                      fontSize: 28,
                    ),
                  ),
                  InkWell(
                    onTap: () => context
                        .read<InformationPageBloc>()
                        .add(ToggleModifyCatEvent()),
                    child: FaIcon(
                        (state.isEditing1)
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
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(20)
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
                          child: (state.isEditing1)
                              ? TextFormField(
                                  onSaved: (value) {},
                                  validator: Validators().nameValidator,
                                  decoration: const InputDecoration(
                                    labelText: "Tên mèo",
                                    border: OutlineInputBorder(),
                                  ),
                                )
                              : Text(state.order.cat.name),
                        )
                      ],
                    ),
                    TableRow(
                        decoration:
                            const BoxDecoration(color: Color(0xffE3F2FD)),
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Ảnh"),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: (state.isEditing1)
                                  ? ImagePicker(
                                      width: 700,
                                      height: 420,
                                      initialWidget: (state
                                                  .modifiedOrder.cat.image !=
                                              null)
                                          ? Image.memory(
                                              state.modifiedOrder.cat.image!,
                                              fit: BoxFit.scaleDown)
                                          : null)
                                  : SizedBox(
                                      width: 700,
                                      height: 420,
                                      child: (state.order.cat.image != null)
                                          ? Image.memory(state.order.cat.image!,
                                              fit: BoxFit.scaleDown)
                                          : const Placeholder(
                                              color: Color(0xff68b6ef)))),
                        ]),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Giới tính"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: (state.isEditing1)
                              ? DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(
                                      value: "Đực",
                                      child: Text("Đực"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Cái",
                                      child: Text("Cái"),
                                    ),
                                  ],
                                  onSaved: (value) {},
                                  onChanged: (String? value) {},
                                  value: null,
                                  hint: const Text("---"),
                                  decoration: const InputDecoration(
                                    labelText: "Giới tính",
                                    border: OutlineInputBorder(),
                                  ),
                                )
                              : Text(state.order.cat.gender ?? ""),
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
                          child: (state.isEditing1)
                              ? TextFormField(
                                  onSaved: (value) {},
                                  validator: Validators().ageValidator,
                                  decoration: const InputDecoration(
                                    errorMaxLines: 2,
                                    labelText: "Tuổi",
                                    border: OutlineInputBorder(),
                                  ),
                                )
                              : Text(state.order.cat.age.toString()),
                        )
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Tình trạng sức khoẻ"),
                        ),
                        (state.isEditing1)
                            ? Row(mainAxisSize: MainAxisSize.min, children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.multiline,
                                      validator: Validators()
                                          .multilineTextCanNotNullValidator,
                                      maxLines: null,
                                      onSaved: (value) {},
                                      decoration: const InputDecoration(
                                        labelText: "Thể trạng",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DropdownButtonFormField<int>(
                                      isExpanded: true,
                                      validator: Validators().notNullValidator,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 0,
                                          child: Text("Chưa tiêm"),
                                        ),
                                        DropdownMenuItem(
                                          value: 1,
                                          child: Text("Đã tiêm vaccine dại"),
                                        ),
                                        DropdownMenuItem(
                                          value: 2,
                                          child:
                                              Text("Đã tiêm vaccine tổng hợp"),
                                        ),
                                        DropdownMenuItem(
                                          value: 3,
                                          child: Text(
                                              "Đã tiêm cả hai loại vaccine"),
                                        ),
                                      ],
                                      onChanged: (int? value) {},
                                      onSaved: (value) {},
                                      value: null,
                                      hint: const Text("---"),
                                      decoration: const InputDecoration(
                                        errorMaxLines: 2,
                                        labelText: "Tình trạng tiêm phòng",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DropdownButtonFormField<int>(
                                    isExpanded: true,
                                    validator: Validators().notNullValidator,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 0,
                                        child: Text("Chưa thiến"),
                                      ),
                                      DropdownMenuItem(
                                        value: 1,
                                        child: Text("Đã thiến"),
                                      ),
                                    ],
                                    onChanged: (value) {},
                                    onSaved: (value) {},
                                    value: null,
                                    hint: const Text("---"),
                                    decoration: const InputDecoration(
                                      errorMaxLines: 2,
                                      labelText: "Tình trạng thiến",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                )),
                              ])
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                          "Thể trạng: \n${state.order.cat.physicalCondition}"),
                                    ),
                                    const Spacer(),
                                    Flexible(
                                        child: Text(
                                            "Tình trạng tiêm phòng: ${state.order.cat.vaccText()}\nTình trạng thiến: ${state.order.cat.sterText()}")),
                                  ],
                                ),
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
                          child: (state.isEditing1)
                              ? TextFormField(
                                  validator: Validators().speciesValidator,
                                  onSaved: (value) {},
                                  decoration: const InputDecoration(
                                    labelText: "Giống mèo",
                                    border: OutlineInputBorder(),
                                  ),
                                )
                              : Text(state.order.cat.species ?? ""),
                        )
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Đặc điểm hình thái"),
                        ),
                        (state.isEditing1)
                            ? Row(mainAxisSize: MainAxisSize.min, children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.multiline,
                                      validator: Validators()
                                          .multilineTextCanNullValidator,
                                      maxLines: null,
                                      onSaved: (value) {},
                                      decoration: const InputDecoration(
                                        labelText: "Đặc điểm hình thái",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      validator: Validators().notNullValidator,
                                      items: const [
                                        DropdownMenuItem(
                                          value: "< 3kg",
                                          child: Text("< 3kg"),
                                        ),
                                        DropdownMenuItem(
                                          value: "3-6kg",
                                          child: Text("3-6kg"),
                                        ),
                                        DropdownMenuItem(
                                          value: "> 6kg",
                                          child: Text("> 6kg"),
                                        ),
                                      ],
                                      onChanged: (String? value) {},
                                      value: null,
                                      hint: const Text("---"),
                                      decoration: const InputDecoration(
                                        errorMaxLines: 2,
                                        labelText: "Hạng cân",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    validator: Validators(
                                            weightRank: state
                                                .modifiedOrder.cat.weightRank)
                                        .weightValidator,
                                    onSaved: (value) {},
                                    decoration: const InputDecoration(
                                      suffix: Text("kg"),
                                      labelText: "Cân nặng",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                )),
                              ])
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                          "Đặc điểm hình thái: \n${state.order.cat.appearance}"),
                                    ),
                                    const Spacer(),
                                    Flexible(
                                        child: Text(
                                            "Cân nặng(kg): ${state.order.cat.weight?.toStringAsPrecision(2) ?? "Không được cung cấp"} (${state.order.cat.weightRank})")),
                                  ],
                                ),
                              )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class OwnerInfo extends StatelessWidget {
  const OwnerInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InformationPageBloc, InformationState>(
      builder: (context, state) {
        return Form(
          key: state.formKey2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Thông tin chủ ",
                    style: TextStyle(
                      color: Color(0xff3d426b),
                      fontSize: 28,
                    ),
                  ),
                  InkWell(
                    onTap: () => context
                        .read<InformationPageBloc>()
                        .add(ToggleModifyOwnerEvent()),
                    child: FaIcon(
                        (state.isEditing2)
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
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(20)
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
                        (state.isEditing2)
                            ? Row(mainAxisSize: MainAxisSize.min, children: [
                                Flexible(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    validator: Validators().notNullValidator,
                                    items: const [
                                      DropdownMenuItem(
                                        value: "Nam",
                                        child: Text("Nam"),
                                      ),
                                      DropdownMenuItem(
                                        value: "Nữ",
                                        child: Text("Nữ"),
                                      ),
                                    ],
                                    value: null,
                                    onChanged: (value) {},
                                    onSaved: (value) {},
                                    hint: const Text("---"),
                                    decoration: const InputDecoration(
                                      labelText: "Giới tính",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                )),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      validator: Validators().nameValidator,
                                      onSaved: (value) {},
                                      decoration: const InputDecoration(
                                        labelText: "Tên khách hàng",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                )
                              ])
                            : Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text((state.order.cat.owner.gender ==
                                        "Nam")
                                    ? "(Anh) ${state.order.cat.owner.name}"
                                    : "(Chị) ${state.order.cat.owner.name}"),
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
                          child: (state.isEditing2)
                              ? TextFormField(
                                  validator: Validators().telValidator,
                                  onSaved: (value) {},
                                  decoration: const InputDecoration(
                                    labelText: "Số điện thoại",
                                    border: OutlineInputBorder(),
                                  ),
                                )
                              : Text(state.order.cat.owner.tel),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class BookingInfo extends StatelessWidget {
  final int ridx, oidx;
  const BookingInfo({super.key, required this.ridx, required this.oidx});

  @override
  Widget build(BuildContext context) {
    List<RoomGroup> roomGroupsList =
        Get.find<InternalStorage>().read("roomGroupsList");
    Order order = roomGroupsList[ridx].ordersList[oidx];
    Room roomData = roomGroupsList[ridx].room;
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
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(20)
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
                                          child: Text("${index + 1}"),
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
  final int ridx, oidx;
  const ServiceInfo({super.key, required this.ridx, required this.oidx});

  @override
  Widget build(BuildContext context) {
    List<RoomGroup> roomGroupsList =
        Get.find<InternalStorage>().read("roomGroupsList");
    Order order = roomGroupsList[ridx].ordersList[oidx];
    Room room = roomGroupsList[ridx].room;
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
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(20)
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
                                        controller: controller,
                                        ridx: ridx,
                                        oidx: oidx)),
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
  final int ridx, oidx;
  final InformationPageController controller;

  const ServiceModifier(
      {super.key,
      required this.controller,
      required this.ridx,
      required this.oidx});
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
                  (index1) => ServiceInput(
                      controller: controller,
                      index1: index1,
                      ridx: ridx,
                      oidx: oidx),
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
  final int ridx, oidx;

  const ServiceInput(
      {super.key,
      required this.controller,
      required this.index1,
      required this.ridx,
      required this.oidx});

  @override
  Widget build(BuildContext context) {
    Order order =
        (Get.find<InternalStorage>().read("roomGroupsList")[ridx] as RoomGroup)
            .ordersList[oidx];
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
