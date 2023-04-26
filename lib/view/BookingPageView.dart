// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/BookingPageController.dart';
import '../controller/CalendarPageController.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingPageController>(builder: (controller) {
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 5 * 3,
          child: Stepper(
            currentStep: controller.currentStep,
            controlsBuilder: (context, details) {
              return Row(
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                    onPressed: details.onStepContinue,
                    child: const Text('XÁC NHẬN'),
                  ),
                  const SizedBox(width: 20),
                  (controller.currentStep != 0)
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffff6961),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: details.onStepCancel,
                          child: const Text('QUAY LẠI'),
                        )
                      : Container(),
                ],
              );
            },
            onStepContinue: () {
              if (controller.currentStep == 0 &&
                  controller.formKey1.currentState?.validate() != true) return;
              if (controller.currentStep == 1 &&
                  controller.formKey2.currentState?.validate() != true) return;
              if (controller.currentStep == 2 &&
                  controller.formKey3.currentState?.validate() != true) return;
              if (controller.currentStep < 2) {
                controller.currentStep = controller.currentStep + 1;
              } else {
                controller.sendDataToDatabase();
              }
            },
            onStepCancel: () {
              if (controller.currentStep > 0) {
                controller.currentStep = controller.currentStep - 1;
              }
            },
            steps: [
              Step(
                state: (controller.currentStep == 0)
                    ? StepState.editing
                    : StepState.indexed,
                isActive: controller.currentStep >= 0,
                title: const Text("Nhập thông tin khách hàng"),
                content: Form(
                  key: controller.formKey1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: TextFormField(
                                controller: controller.ownerNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return "Không để trống tên";
                                  if (value.length > 50)
                                    return "Tên dài hơn 50 ký tự";
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: "Tên khách hàng",
                                  labelStyle: TextStyle(color: Colors.black87),
                                  floatingLabelStyle:
                                      TextStyle(color: Colors.blue),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                validator: (value) {
                                  if (value == null)
                                    return "Không để trống giới tính";
                                  return null;
                                },
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
                                onChanged: (String? value) {
                                  controller.ownerGender = value!;
                                },
                                value: null,
                                hint: const Text("---"),
                                decoration: const InputDecoration(
                                  labelText: "Giới tính",
                                  labelStyle: TextStyle(color: Colors.black87),
                                  floatingLabelStyle:
                                      TextStyle(color: Colors.blue),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Không để trống số điện thoại";
                            if (value[0] != "0" || value.length != 10)
                              return "Số điện thoại không đúng định dạng";
                            return null;
                          },
                          controller: controller.telController,
                          decoration: const InputDecoration(
                            labelText: "Số điện thoại",
                            labelStyle: TextStyle(color: Colors.black87),
                            floatingLabelStyle: TextStyle(color: Colors.blue),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Step(
                state: (controller.currentStep == 1)
                    ? StepState.editing
                    : StepState.indexed,
                isActive: controller.currentStep >= 1,
                title: const Text("Nhập thông tin mèo"),
                content: Form(
                  key: controller.formKey2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 16),
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty)
                                          return "Không để trống tên";
                                        if (value.length > 20)
                                          return "Tên dài hơn 20 ký tự";
                                        return null;
                                      },
                                      controller: controller.catNameController,
                                      decoration: const InputDecoration(
                                        labelText: "Tên mèo",
                                        labelStyle:
                                            TextStyle(color: Colors.black87),
                                        floatingLabelStyle:
                                            TextStyle(color: Colors.blue),
                                        border: OutlineInputBorder(),
                                      ),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 16),
                                  child: DropdownButtonFormField<int>(
                                    isExpanded: true,
                                    validator: (value) {
                                      if (value == null)
                                        return "Không để trống tình trạng thiến";
                                      return null;
                                    },
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
                                    onChanged: (int? value) {
                                      controller.sterilization = value!;
                                    },
                                    value: null,
                                    hint: const Text("---"),
                                    decoration: const InputDecoration(
                                      labelText: "Tình trạng thiến",
                                      labelStyle:
                                          TextStyle(color: Colors.black87),
                                      floatingLabelStyle:
                                          TextStyle(color: Colors.blue),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 16),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return "Không để trống giống mèo";
                                      if (value.length > 30)
                                        return "Giống mèo dài hơn 30 ký tự";
                                      return null;
                                    },
                                    controller: controller.speciesController,
                                    decoration: const InputDecoration(
                                      labelText: "Giống mèo",
                                      labelStyle:
                                          TextStyle(color: Colors.black87),
                                      floatingLabelStyle:
                                          TextStyle(color: Colors.blue),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 16),
                                  child: DropdownButtonFormField<int>(
                                    isExpanded: true,
                                    validator: (value) {
                                      if (value == null)
                                        return "Không để trống tình trạng tiêm phòng";
                                      return null;
                                    },
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
                                        child: Text("Đã tiêm vaccine tổng hợp"),
                                      ),
                                      DropdownMenuItem(
                                        value: 3,
                                        child:
                                            Text("Đã tiêm cả hai loại vaccine"),
                                      ),
                                    ],
                                    onChanged: (int? value) {
                                      controller.vaccination = value!;
                                    },
                                    value: null,
                                    hint: const Text("---"),
                                    decoration: const InputDecoration(
                                      labelText: "Tình trạng tiêm phòng",
                                      labelStyle:
                                          TextStyle(color: Colors.black87),
                                      floatingLabelStyle:
                                          TextStyle(color: Colors.blue),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 16),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return "Không để trống tuổi mèo";
                                      if (int.tryParse(value) == null)
                                        return "Tuổi phải là số";
                                      if (int.tryParse(value)! < 0)
                                        return "Tuổi phải không âm";
                                      return null;
                                    },
                                    controller: controller.catAgeController,
                                    decoration: const InputDecoration(
                                      labelText: "Tuổi",
                                      labelStyle:
                                          TextStyle(color: Colors.black87),
                                      floatingLabelStyle:
                                          TextStyle(color: Colors.blue),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 16),
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    validator: (value) {
                                      if (value == null)
                                        return "Không để trống giới tính";
                                      return null;
                                    },
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
                                    onChanged: (String? value) {
                                      controller.catGender = value!;
                                    },
                                    value: null,
                                    hint: const Text("---"),
                                    decoration: const InputDecoration(
                                      labelText: "Giới tính",
                                      labelStyle:
                                          TextStyle(color: Colors.black87),
                                      floatingLabelStyle:
                                          TextStyle(color: Colors.blue),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            child: FormField<Uint8List>(
                              initialValue: null,
                              builder: (state) {
                                return Column(
                                  children: [
                                    InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: "Ảnh",
                                        errorText: state.errorText,
                                        constraints:
                                            const BoxConstraints.tightFor(
                                                width: 210, height: 210),
                                        labelStyle: const TextStyle(
                                            color: Colors.black87),
                                        floatingLabelStyle:
                                            const TextStyle(color: Colors.blue),
                                        border: const OutlineInputBorder(),
                                      ),
                                      child: state.value == null
                                          ? const SizedBox(
                                              width: 200,
                                              height: 200,
                                            )
                                          : Image.memory(
                                              state.value!,
                                              width: 200,
                                              height: 200,
                                              fit: BoxFit.scaleDown,
                                            ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async => state.didChange(
                                          await controller.getPhotos()),
                                      child: const Text("Chọn ảnh"),
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: TextFormField(
                                keyboardType: TextInputType.multiline,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return "Không để trống thể trạng";
                                  if (value.length > 150)
                                    return "Thể trạng dài hơn 150 ký tự";
                                  return null;
                                },
                                controller:
                                    controller.physicalConditionController,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  labelText: "Thể trạng",
                                  labelStyle: TextStyle(color: Colors.black87),
                                  floatingLabelStyle:
                                      TextStyle(color: Colors.blue),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: TextFormField(
                                keyboardType: TextInputType.multiline,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return null;
                                  if (value.length > 150)
                                    return "Thể trạng dài hơn 150 ký tự";
                                  return null;
                                },
                                controller: controller.appearanceController,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  labelText: "Đặc điểm hình thái",
                                  labelStyle: TextStyle(color: Colors.black87),
                                  floatingLabelStyle:
                                      TextStyle(color: Colors.blue),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Step(
                state: (controller.currentStep == 2)
                    ? StepState.editing
                    : StepState.indexed,
                isActive: controller.currentStep >= 2,
                title: const Text("Nhập thông tin đặt phòng và dịch vụ"),
                content: Form(
                  key: controller.formKey3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: DropdownButtonFormField<int>(
                                isExpanded: true,
                                items: List.generate(
                                    Get.find<CalendarPageController>()
                                        .roomBookingData
                                        .length,
                                    (index) => DropdownMenuItem(
                                        value: index,
                                        child: Text(
                                            Get.find<CalendarPageController>()
                                                .roomBookingData[index]
                                                .roomData
                                                .roomID))),
                                onChanged: (int? value) {
                                  controller.subRoomIndex = 0;
                                  controller.roomIndex = value!;
                                },
                                validator: (value) {
                                  if (value == null)
                                    return "Không để trống mã phòng";
                                  return null;
                                },
                                value: null,
                                hint: const Text("---"),
                                decoration: const InputDecoration(
                                  labelText: "Mã phòng",
                                  labelStyle: TextStyle(color: Colors.black87),
                                  floatingLabelStyle:
                                      TextStyle(color: Colors.blue),
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
                                items: (controller.roomIndex == -1)
                                    ? null
                                    : List.generate(
                                        Get.find<CalendarPageController>()
                                            .roomBookingData[
                                                controller.roomIndex]
                                            .roomData
                                            .subQuantity,
                                        (index) => DropdownMenuItem(
                                            value: index,
                                            child: Text("${index + 1}"))),
                                onChanged: (controller.roomIndex == -1)
                                    ? null
                                    : (int? value) {
                                        controller.subRoomIndex = value!;
                                      },
                                validator: (value) {
                                  if (value == null)
                                    return "Không để trống mã phòng con";
                                  return null;
                                },
                                value: (controller.roomIndex == -1)
                                    ? null
                                    : controller.subRoomIndex,
                                hint: const Text("---"),
                                decoration: const InputDecoration(
                                  labelText: "Mã phòng con",
                                  labelStyle: TextStyle(color: Colors.black87),
                                  floatingLabelStyle:
                                      TextStyle(color: Colors.blue),
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
                                  4,
                                  (index) => DropdownMenuItem(
                                    value: index,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Hạng ${index + 1}"),
                                        const SizedBox(width: 10),
                                        const Tooltip(
                                            message:
                                                "Chi tiết:\nĐề xuất\nGiá thành:",
                                            child: FaIcon(
                                                FontAwesomeIcons.circleInfo))
                                      ],
                                    ),
                                  ),
                                ),
                                onChanged: (int? value) {
                                  controller.rank = value!;
                                },
                                validator: (value) {
                                  if (value == null)
                                    return "Không để trống hạng ăn";
                                  return null;
                                },
                                value: null,
                                hint: const Text("---"),
                                decoration: const InputDecoration(
                                  labelText: "Hạng ăn",
                                  labelStyle: TextStyle(color: Colors.black87),
                                  floatingLabelStyle:
                                      TextStyle(color: Colors.blue),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: DateTimePicker(
                                controller: controller.checkInController,
                                titleOfTextField: "Thời gian check-in",
                                validator: (value) {
                                  if (value == null)
                                    return "Không để trống thời gian check-in";
                                  if (controller
                                      .checkOutController.text.isNotEmpty) {
                                    if (!DateTime.parse(
                                            controller.checkOutController.text)
                                        .isAfter(DateTime.parse(value)))
                                      return "Thời gian check-in phải trước thời gian check-out";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: DateTimePicker(
                                controller: controller.checkOutController,
                                titleOfTextField: "Thời gian check-out",
                                validator: (value) {
                                  if (value == null)
                                    return "Không để trống thời gian check-out";
                                  if (controller
                                      .checkInController.text.isNotEmpty) {
                                    if (!DateTime.parse(
                                            controller.checkInController.text)
                                        .isBefore(DateTime.parse(value)))
                                      return "Thời gian check-out phải sau thời gian check-in";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: TextFormField(
                                keyboardType: TextInputType.multiline,
                                controller: controller.attentionController,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  labelText: "Lưu ý",
                                  labelStyle: TextStyle(color: Colors.black87),
                                  floatingLabelStyle:
                                      TextStyle(color: Colors.blue),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: TextFormField(
                                keyboardType: TextInputType.multiline,
                                controller: controller.noteController,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  labelText: "Ghi chú",
                                  labelStyle: TextStyle(color: Colors.black87),
                                  floatingLabelStyle:
                                      TextStyle(color: Colors.blue),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      FormField(
                        builder: (state) => Padding(
                          padding: const EdgeInsets.all(10),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Danh sách dịch vụ",
                              labelStyle: TextStyle(color: Colors.black87),
                              floatingLabelStyle: TextStyle(color: Colors.blue),
                              border: OutlineInputBorder(),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    controller.numberOfServices,
                                    (index1) => ServiceInput(
                                        controller: controller, index1: index1),
                                  ),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      controller.service.add(-1);
                                      controller.time
                                          .add(TextEditingController());
                                      controller.quantity.add(null);
                                      controller.distance.add(null);
                                      controller.weight.add(null);
                                      controller.numberOfServices =
                                          controller.numberOfServices + 1;
                                    },
                                    child: const Text("Thêm dịch vụ"))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class ServiceInput extends StatelessWidget {
  final BookingPageController controller;
  final int index1;

  const ServiceInput(
      {super.key, required this.controller, required this.index1});

  @override
  Widget build(BuildContext context) {
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
                controller.serviceList.length,
                (index2) => DropdownMenuItem(
                  value: index2,
                  child: Text(controller.serviceList[index2].serviceName),
                ),
              ),
              onChanged: (int? value) {
                controller.service[index1] = value!;
                controller.createServiceController(value, index1);
              },
              validator: (value) {
                if (value == null) return "Không để trống loại dịch vụ";
                return null;
              },
              value: (controller.service[index1] == -1)
                  ? null
                  : controller.service[index1],
              hint: const Text("---"),
              decoration: const InputDecoration(
                labelText: "Loại dịch vụ",
                labelStyle: TextStyle(color: Colors.black87),
                floatingLabelStyle: TextStyle(color: Colors.blue),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        (controller.quantity[index1] == null)
            ? Flexible(flex: 0, child: Container())
            : ServiceValue(
                controller: controller.quantity[index1]!,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Không để trống số lượng";
                  if (int.tryParse(value) == null) return "Phải nhập số";
                  if (int.tryParse(value)! < 1)
                    return "Số lượng phải lớn hơn 0";
                  return null;
                },
                label: "Số lượng"),
        (controller.distance[index1] == null)
            ? Flexible(flex: 0, child: Container())
            : ServiceValue(
                controller: controller.distance[index1]!,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Không để trống khoảng cách";
                  if (double.tryParse(value) == null) return "Phải nhập số";
                  if (double.tryParse(value)! <= 0)
                    return "Khoảng cách phải lớn hơn 0";
                  return null;
                },
                label: "Khoảng cách"),
        (controller.weight[index1] == null)
            ? Flexible(flex: 0, child: Container())
            : ServiceValue(
                controller: controller.distance[index1]!,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Không để trống khối lượng";
                  if (double.tryParse(value) == null) return "Phải nhập số";
                  if (double.tryParse(value)! <= 0)
                    return "Khối lượng phải lớn hơn 0";
                  return null;
                },
                label: "Khối lượng (kg)"),
        Flexible(
            child: ElevatedButton(
                onPressed: () {
                  controller.service.removeAt(index1);
                  controller.time.removeAt(index1);
                  controller.quantity.removeAt(index1);
                  controller.distance.removeAt(index1);
                  controller.weight.removeAt(index1);
                  controller.numberOfServices = controller.numberOfServices - 1;
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

  const ServiceValue(
      {super.key,
      required this.controller,
      required this.validator,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black87),
            floatingLabelStyle: const TextStyle(color: Colors.blue),
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

  const DateTimePicker(
      {super.key,
      required this.controller,
      required this.titleOfTextField,
      this.validator});

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
        if (context.mounted) {
          controller.text = DateFormat('dd/MM/yyyy HH:mm').format(date);
        }
      },
      child: IgnorePointer(
        child: TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            labelText: titleOfTextField,
            labelStyle: const TextStyle(color: Colors.black87),
            floatingLabelStyle: const TextStyle(color: Colors.blue),
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
