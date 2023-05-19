import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../blocs/BookingPageController.dart';
import '../data/enums/RenderState.dart';
import '../model/RoomGroupModel.dart';
import '../utils/GoogleMaps.dart';
import '../utils/InternalStorage.dart';

class BookingPage extends StatelessWidget {
  final _ownerNameController = TextEditingController();

  final _ownerTelController = TextEditingController();

  final _catNameController = TextEditingController();

  final _catSpeciesController = TextEditingController();

  final _catWeightController = TextEditingController();

  final _catAgeController = TextEditingController();

  final _catPhysicalConditionController = TextEditingController();

  final _catAppearanceController = TextEditingController();

  final _orderAttentionController = TextEditingController();

  final _orderNoteController = TextEditingController();

  BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    print("big");
    var internalStorage = Get.find<InternalStorage>();
    return BlocProvider(
      create: (_) => BookingPageBloc(),
      child: BlocConsumer<BookingPageBloc, BookingState>(
          listener: (context, state) {},
          buildWhen: (previous, current) =>
              previous.currentStep != current.currentStep ||
              previous.renderState == RenderState.waiting,
          builder: (context, state) {
            if (state.renderState == RenderState.waiting) {
              BlocProvider.of<BookingPageBloc>(context).add(RequireDataEvent());
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                  Text('Đang tải dữ liệu...'),
                ],
              );
            }
            Future.delayed(
                const Duration(milliseconds: 100),
                () => BlocProvider.of<BookingPageBloc>(context)
                    .add(CompleteRenderEvent()));
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 5 * 3,
                child: Stepper(
                  currentStep: state.currentStep,
                  controlsBuilder: (context, details) {
                    return Row(
                      children: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black),
                          onPressed: details.onStepContinue,
                          child: const Text('XÁC NHẬN'),
                        ),
                        const SizedBox(width: 20),
                        (state.currentStep != 0)
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
                    context.read<BookingPageBloc>().add(NextStepEvent());
                  },
                  onStepCancel: () {
                    context.read<BookingPageBloc>().add(BackStepEvent());
                  },
                  steps: [
                    //Step1
                    Step(
                      state: (state.currentStep == 0)
                          ? StepState.editing
                          : StepState.indexed,
                      isActive: state.currentStep >= 0,
                      title: const Text("Nhập thông tin khách hàng"),
                      content: Form1(
                          ownerNameController: _ownerNameController,
                          ownerTelController: _ownerTelController),
                    ),
                    Step(
                      state: (state.currentStep == 1)
                          ? StepState.editing
                          : StepState.indexed,
                      isActive: state.currentStep >= 1,
                      title: const Text("Nhập thông tin mèo"),
                      content: Form2(
                          catNameController: _catNameController,
                          catSpeciesController: _catSpeciesController,
                          catWeightController: _catWeightController,
                          catAgeController: _catAgeController,
                          catPhysicalConditionController:
                              _catPhysicalConditionController,
                          catAppearanceController: _catAppearanceController),
                    ),
                    Step(
                      state: (state.currentStep == 2)
                          ? StepState.editing
                          : StepState.indexed,
                      isActive: state.currentStep >= 2,
                      title: const Text("Nhập thông tin đặt phòng và dịch vụ"),
                      content: Form3(
                          internalStorage: internalStorage,
                          orderAttentionController: _orderAttentionController,
                          orderNoteController: _orderNoteController),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

class Form3 extends StatelessWidget {
  const Form3({
    super.key,
    required this.internalStorage,
    required TextEditingController orderAttentionController,
    required TextEditingController orderNoteController,
  })  : _orderAttentionController = orderAttentionController,
        _orderNoteController = orderNoteController;

  final InternalStorage internalStorage;
  final TextEditingController _orderAttentionController;
  final TextEditingController _orderNoteController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingPageBloc, BookingState>(
      buildWhen: (previous, current) =>
          previous.renderState != current.renderState,
      builder: (context, state) {
        return Form(
          key: state.step3State.formKey3,
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
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        items: List.generate(
                            internalStorage.read("roomGroupsList").length,
                            (index) {
                          RoomGroup roomGroup =
                              internalStorage.read("roomGroupsList")[index];
                          return DropdownMenuItem(
                              value: roomGroup.room.id,
                              child: Text(roomGroup.room.id));
                        }),
                        onChanged: (String? value) {},
                        validator: (value) {
                          if (value == null) return "Không để trống mã phòng";
                          return null;
                        },
                        value: null,
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
                        items: null,
                        onChanged: (int? value) {},
                        validator: (value) {
                          if (value == null)
                            return "Không để trống mã phòng con";
                          return null;
                        },
                        value: null,
                        hint: const Text("---"),
                        decoration: const InputDecoration(
                          errorMaxLines: 3,
                          labelText: "Mã phòng con",
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
                          Get.find<InternalStorage>()
                              .read("servicesList")
                              .length,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("${index + 1}"),
                                const SizedBox(width: 10),
                                const Tooltip(
                                    message: "Chi tiết:\nĐề xuất\nGiá thành:",
                                    child: FaIcon(FontAwesomeIcons.circleInfo))
                              ],
                            ),
                          ),
                        ),
                        onChanged: (int? value) {},
                        validator: (value) {
                          if (value == null) return "Không để trống hạng ăn";
                          return null;
                        },
                        value: null,
                        hint: const Text("---"),
                        decoration: const InputDecoration(
                          errorMaxLines: 2,
                          labelText: "Hạng ăn",
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
                      child: TextFormField(),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: TextFormField(),
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
                        controller: _orderAttentionController,
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          if (!RegExp(r'^[^]{1,200}$',
                                  unicode: true, multiLine: true)
                              .hasMatch(value)) {
                            return "Lưu ý không đúng định dạng";
                          }
                          return null;
                        },
                        maxLines: null,
                        decoration: const InputDecoration(
                          labelText: "Lưu ý",
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
                        controller: _orderNoteController,
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          if (!RegExp(r'^[^]{1,200}$',
                                  unicode: true, multiLine: true)
                              .hasMatch(value)) {
                            return "Ghi chú không đúng định dạng";
                          }
                          return null;
                        },
                        maxLines: null,
                        decoration: const InputDecoration(
                          labelText: "Ghi chú",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              FormField(
                builder: (formState) => Padding(
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
                              state.step3State.numberOfAdditions,
                              (index1) => TextFormField()),
                        ),
                        ElevatedButton(
                            onPressed: () {}, child: const Text("Thêm dịch vụ"))
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Form2 extends StatelessWidget {
  const Form2({
    super.key,
    required TextEditingController catNameController,
    required TextEditingController catSpeciesController,
    required TextEditingController catWeightController,
    required TextEditingController catAgeController,
    required TextEditingController catPhysicalConditionController,
    required TextEditingController catAppearanceController,
  })  : _catNameController = catNameController,
        _catSpeciesController = catSpeciesController,
        _catWeightController = catWeightController,
        _catAgeController = catAgeController,
        _catPhysicalConditionController = catPhysicalConditionController,
        _catAppearanceController = catAppearanceController;

  final TextEditingController _catNameController;
  final TextEditingController _catSpeciesController;
  final TextEditingController _catWeightController;
  final TextEditingController _catAgeController;
  final TextEditingController _catPhysicalConditionController;
  final TextEditingController _catAppearanceController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingPageBloc, BookingState>(
        buildWhen: (previous, current) =>
            previous.renderState != current.renderState,
        builder: (context, state) {
          return Form(
            key: state.step2State.formKey2,
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
                                    return "Không để trống tên mèo";
                                  if (!RegExp(r'^[\p{L}\s]{1,50}$',
                                          unicode: true)
                                      .hasMatch(value)) {
                                    return "Tên mèo không đúng định dạng";
                                  }
                                  return null;
                                },
                                controller: _catNameController,
                                decoration: const InputDecoration(
                                  labelText: "Tên mèo",
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
                              onChanged: (int? value) {},
                              value: null,
                              hint: const Text("---"),
                              decoration: const InputDecoration(
                                errorMaxLines: 2,
                                labelText: "Tình trạng thiến",
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
                                if (value == null) {
                                  return "Không để trống hạng cân";
                                }
                                return null;
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: "< 3kg",
                                  child: Text("Dưới 3 kg"),
                                ),
                                DropdownMenuItem(
                                  value: "3-6kg",
                                  child: Text("3-6 kg"),
                                ),
                                DropdownMenuItem(
                                  value: "> 6kg",
                                  child: Text("Trên 6 kg"),
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
                              controller: _catSpeciesController,
                              validator: (value) {
                                if (value == null || value.isEmpty) return null;
                                if (!RegExp(r'^[\p{L}\s]{1,30}$', unicode: true)
                                    .hasMatch(value)) {
                                  return "Giống mèo không đúng định dạng";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: "Giống mèo",
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
                                if (value == null) {
                                  return "Không để trống tình trạng tiêm phòng";
                                }
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
                                  child: Text("Đã tiêm cả hai loại vaccine"),
                                ),
                              ],
                              onChanged: (int? value) {},
                              value: null,
                              hint: const Text("---"),
                              decoration: const InputDecoration(
                                errorMaxLines: 2,
                                labelText: "Tình trạng tiêm phòng",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            child: TextFormField(
                              controller: _catWeightController,
                              validator: (value) {
                                if (value == null || value.isEmpty) return null;
                                if (!RegExp(r'^[1-9]\d*(\.\d+){0,1}$',
                                        unicode: true)
                                    .hasMatch(value)) {
                                  return "Cân nặng mèo không đúng định dạng";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                suffix: Text("kg"),
                                labelText: "Cân nặng",
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
                                if (!RegExp(r'[1-9]\d*').hasMatch(value))
                                  return "Tuổi mèo không đúng định dạng";
                                return null;
                              },
                              controller: _catAgeController,
                              decoration: const InputDecoration(
                                errorMaxLines: 2,
                                labelText: "Tuổi",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            child: DropdownButtonFormField<String>(
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
                              onChanged: (String? value) {},
                              value: null,
                              hint: const Text("---"),
                              decoration: const InputDecoration(
                                labelText: "Giới tính",
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
                                  constraints: const BoxConstraints.tightFor(
                                      width: 210, height: 210),
                                  border: const OutlineInputBorder(),
                                ),
                                child: state.value == null
                                    ? const SizedBox(width: 200, height: 200)
                                    : Image.memory(
                                        state.value!,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.scaleDown,
                                      ),
                              ),
                              ElevatedButton(
                                onPressed: () => context
                                    .read<BookingPageBloc>()
                                    .add(PickImageEvent()),
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
                            if (!RegExp(r'^[^]{1,150}$',
                                    unicode: true, multiLine: true)
                                .hasMatch(value)) {
                              return "Thể trạng không đúng định dạng";
                            }
                            return null;
                          },
                          controller: _catPhysicalConditionController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            labelText: "Thể trạng",
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
                            if (value == null || value.isEmpty) return null;
                            if (!RegExp(r'^[^]{1,150}$',
                                    unicode: true, multiLine: true)
                                .hasMatch(value)) {
                              return "Đặc điểm hình thái không đúng định dạng";
                            }
                            return null;
                          },
                          controller: _catAppearanceController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            labelText: "Đặc điểm hình thái",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }
}

class Form1 extends StatelessWidget {
  const Form1({
    super.key,
    required TextEditingController ownerNameController,
    required TextEditingController ownerTelController,
  })  : _ownerNameController = ownerNameController,
        _ownerTelController = ownerTelController;

  final TextEditingController _ownerNameController;
  final TextEditingController _ownerTelController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingPageBloc, BookingState>(
      buildWhen: (previous, current) =>
          previous.renderState != current.renderState,
      builder: (context, state) {
        return Form(
          key: state.step1State.formKey1,
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
                        controller: _ownerNameController,
                        onChanged: (value) => context
                            .read<BookingPageBloc>()
                            .add(ChangeStep1StateEvent(
                                name: _ownerNameController.text)),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Không để trống tên";
                          if (!RegExp(r'^[\p{L}\s]{1,50}$', unicode: true)
                              .hasMatch(value)) {
                            return "Tên không đúng định dạng";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: "Tên khách hàng",
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
                          if (value == null) {
                            return "Không để trống giới tính";
                          }
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
                          context
                              .read<BookingPageBloc>()
                              .add(ChangeStep1StateEvent(gender: value));
                        },
                        value: null,
                        hint: const Text("---"),
                        decoration: const InputDecoration(
                          labelText: "Giới tính",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Không để trống số điện thoại";
                    }
                    if (!RegExp(r'^0\d{9}$').hasMatch(value)) {
                      return "Số điện thoại không đúng định dạng";
                    }
                    return null;
                  },
                  controller: _ownerTelController,
                  onChanged: (value) => context.read<BookingPageBloc>().add(
                      ChangeStep1StateEvent(name: _ownerTelController.text)),
                  decoration: const InputDecoration(
                    labelText: "Số điện thoại",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/*

class ServiceInput extends StatelessWidget {
  final BookingPageController controller;
  final int index1;

  const ServiceInput(
      {super.key, required this.controller, required this.index1});

  @override
  Widget build(BuildContext context) {
    print("ServiceInput $index1 build");
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
                controller.additionsList[index1] = value!;
                controller.createServiceController(value - 1, index1);
              },
              validator: (value) {
                if (value == null) return "Không để trống loại dịch vụ";
                return null;
              },
              value: (controller.additionsList[index1] == -1)
                  ? null
                  : controller.additionsList[index1],
              hint: const Text("---"),
              decoration: const InputDecoration(
                labelText: "Loại dịch vụ",
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        (controller.additionTimeController[index1] == null)
            ? Flexible(flex: 0, child: Container())
            : Flexible(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: DateTimePicker(
                      controller: controller.additionTimeController[index1]!,
                      titleOfTextField: "Thời gian",
                      validator: (value) {
                        if (controller.additionTimeList[index1] == null)
                          return "Không để trống thời gian";
                        if (controller.orderCheckInController.text.isNotEmpty &&
                            controller
                                .orderCheckOutController.text.isNotEmpty) {
                          if (controller.additionTimeList[index1]!
                                  .isAfter(controller.orderCheckOut) ||
                              controller.additionTimeList[index1]!
                                  .isBefore(controller.orderCheckIn)) {
                            return "Thời gian phải nằm trong khoảng check-in và check-out";
                          }
                        }
                        return null;
                      },
                      isOutSerIn: 0,
                      index1: index1),
                ),
              ),
        (controller.additionQuantityController[index1] == null)
            ? Flexible(flex: 0, child: Container())
            : ServiceValue(
                controller: controller.additionQuantityController[index1]!,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Không để trống số lượng";
                  if (!RegExp(r'^[1-9]\d*').hasMatch(value))
                    return "Số lượng không đúng định dạng";
                  return null;
                },
                label: "Số lượng"),
        (controller.additionDistanceController[index1] == null)
            ? Flexible(flex: 0, child: Container())
            : Flexible(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: TextFormField(
                    controller: controller.additionDistanceController[index1]!,
                    readOnly: true,
                    decoration: InputDecoration(
                        labelText: "Thông tin vị trí",
                        border: const OutlineInputBorder(),
                        suffix: InkWell(
                            onTap: () async {
                              await Get.to(() => const MyApp())?.then((value) {
                                controller.additionDistanceController[index1]
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
                  controller.additionsList.removeAt(index1);
                  controller.additionTimeController.removeAt(index1);
                  controller.additionQuantityController.removeAt(index1);
                  controller.additionDistanceController.removeAt(index1);
                  controller.additionTimeList.removeAt(index1);
                  controller.numberOfAdditions =
                      controller.numberOfAdditions - 1;
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
  final void Function()? onTap;

  const ServiceValue(
      {super.key,
      required this.controller,
      required this.validator,
      required this.label,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    print("ServiceValue build");
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: TextFormField(
          controller: controller,
          validator: validator,
          onTap: onTap,
          decoration: InputDecoration(
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
    print("DateTimePicker $index1 build");
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
          Get.find<BookingPageController>().orderCheckIn = date;
        } else if (isOutSerIn < 0) {
          Get.find<BookingPageController>().orderCheckOut = date;
        } else {
          Get.find<BookingPageController>().additionTimeList[index1!] = date;
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
*/