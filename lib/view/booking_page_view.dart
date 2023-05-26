import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../blocs/booking_page_bloc.dart';
import '../data/dependencies/internal_storage.dart';
import '../data/enums/RenderState.dart';
import '../model/RoomGroupModel.dart';
import '../utils/reusables/date_time_picker.dart';
import '../utils/reusables/image_picker.dart';
import '../utils/reusables/service_chooser.dart';
import '../utils/validators/validators.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    var internalStorage = GetIt.I<InternalStorage>();
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
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                  Text('Đang tải dữ liệu...'),
                ],
              );
            }
            SchedulerBinding.instance.addPostFrameCallback((_) {
              BlocProvider.of<BookingPageBloc>(context)
                  .add(CompleteRenderEvent());
            });
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
                      content: const Form1(),
                    ),
                    Step(
                      state: (state.currentStep == 1)
                          ? StepState.editing
                          : StepState.indexed,
                      isActive: state.currentStep >= 1,
                      title: const Text("Nhập thông tin mèo"),
                      content: Form2(internalStorage: internalStorage),
                    ),
                    Step(
                      state: (state.currentStep == 2)
                          ? StepState.editing
                          : StepState.indexed,
                      isActive: state.currentStep >= 2,
                      title: const Text("Nhập thông tin đặt phòng và dịch vụ"),
                      content: Form3(internalStorage: internalStorage),
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
  });

  final InternalStorage internalStorage;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingPageBloc, BookingState>(
      buildWhen: (previous, current) =>
          current.currentStep == 2 && previous.step3State != current.step3State,
      builder: (context, state) {
        print(3);
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
                        onChanged: (String? value) {
                          if (value != null) {
                            context.read<BookingPageBloc>().add(
                                ChangeStep3StateEvent(
                                    roomID: value, subRoomNum: 1));
                          }
                        },
                        validator: Validators().notNullValidator,
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
                        items: state.step3State.order.subRoomNum == -1
                            ? null
                            : List.generate(
                                state.step3State.order.room.total,
                                (index) => DropdownMenuItem(
                                    value: index + 1,
                                    child: Text("${index + 1}"))),
                        onChanged: (value) {},
                        onSaved: (value) {
                          print("fired $value");
                          context
                              .read<BookingPageBloc>()
                              .add(ChangeStep3StateEvent(subRoomNum: value));
                        },
                        validator: Validators().notNullValidator,
                        value: (state.step3State.order.subRoomNum == -1)
                            ? null
                            : state.step3State.order.subRoomNum,
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
                          internalStorage.read("servicesList").length,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text("${index + 1}"),
                          ),
                        ),
                        onChanged: (int? value) {},
                        onSaved: (int? value) {
                          context
                              .read<BookingPageBloc>()
                              .add(ChangeStep3StateEvent(eatingRank: value));
                        },
                        validator: Validators().notNullValidator,
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
                      child: DateTimePicker(
                        title: "Thời gian check-in",
                        validator: Validators(
                                checkIn: state.step3State.order.checkIn,
                                checkOut: state.step3State.order.checkOut)
                            .checkInValidator,
                        onChanged: (value) {
                          context
                              .read<BookingPageBloc>()
                              .add(ChangeStep3StateEvent(checkIn: value));
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
                        title: "Thời gian check-out",
                        validator: Validators(
                                checkIn: state.step3State.order.checkIn,
                                checkOut: state.step3State.order.checkOut)
                            .checkOutValidator,
                        onChanged: (value) {
                          context
                              .read<BookingPageBloc>()
                              .add(ChangeStep3StateEvent(checkOut: value));
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
                        validator: Validators().multilineTextCanNullValidator,
                        onSaved: (value) {
                          context
                              .read<BookingPageBloc>()
                              .add(ChangeStep3StateEvent(attention: value));
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
                        validator: Validators().multilineTextCanNullValidator,
                        onSaved: (value) {
                          context
                              .read<BookingPageBloc>()
                              .add(ChangeStep3StateEvent(note: value));
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
              AdditionChooser(
                  initialValue: state.step3State.order.additionsList,
                  onSaved: (value) {
                    context
                        .read<BookingPageBloc>()
                        .add(ChangeStep3StateEvent(additionsList: value));
                  }),
            ],
          ),
        );
      },
    );
  }
}

class Form2 extends StatelessWidget {
  const Form2({super.key, required this.internalStorage});

  final InternalStorage internalStorage;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingPageBloc, BookingState>(
        buildWhen: (previous, current) => current.currentStep == 1,
        builder: (context, state) {
          print(2);
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
                                onSaved: (value) {
                                  context
                                      .read<BookingPageBloc>()
                                      .add(ChangeStep2StateEvent(name: value));
                                },
                                validator: Validators().nameValidator,
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
                              onSaved: (value) {
                                context.read<BookingPageBloc>().add(
                                    ChangeStep2StateEvent(
                                        sterilization: value));
                              },
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
                              onChanged: (String? value) {
                                context.read<BookingPageBloc>().add(
                                    ChangeStep2StateEvent(weightRank: value));
                              },
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
                              validator: Validators().speciesValidator,
                              onSaved: (value) {
                                context
                                    .read<BookingPageBloc>()
                                    .add(ChangeStep2StateEvent(species: value));
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
                                  child: Text("Đã tiêm vaccine tổng hợp"),
                                ),
                                DropdownMenuItem(
                                  value: 3,
                                  child: Text("Đã tiêm cả hai loại vaccine"),
                                ),
                              ],
                              onChanged: (int? value) {},
                              onSaved: (value) {
                                context.read<BookingPageBloc>().add(
                                    ChangeStep2StateEvent(vaccination: value));
                              },
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
                              validator: Validators(
                                      weightRank:
                                          state.step2State.cat.weightRank)
                                  .weightValidator,
                              onSaved: (value) {
                                context.read<BookingPageBloc>().add(
                                    ChangeStep2StateEvent(
                                        weight: double.tryParse(
                                            value ?? "invalid")));
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
                              onSaved: (value) {
                                context.read<BookingPageBloc>().add(
                                    ChangeStep2StateEvent(
                                        age: int.tryParse(value ?? "invalid")));
                              },
                              validator: Validators().ageValidator,
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
                              onSaved: (value) {
                                context
                                    .read<BookingPageBloc>()
                                    .add(ChangeStep2StateEvent(gender: value));
                              },
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
                      child: ImagePicker(
                          width: 200,
                          height: 200,
                          onSaved: (bytes) {
                            context
                                .read<BookingPageBloc>()
                                .add(PickImageEvent(bytes));
                          }),
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
                          validator:
                              Validators().multilineTextCanNotNullValidator,
                          maxLines: null,
                          onSaved: (value) {
                            context.read<BookingPageBloc>().add(
                                ChangeStep2StateEvent(
                                    physicalCondition: value));
                          },
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
                          validator: Validators().multilineTextCanNullValidator,
                          maxLines: null,
                          onSaved: (value) {
                            context
                                .read<BookingPageBloc>()
                                .add(ChangeStep2StateEvent(appearance: value));
                          },
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
  const Form1({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingPageBloc, BookingState>(
      buildWhen: (previous, current) => current.currentStep == 0,
      builder: (context, state) {
        print(1);
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
                        validator: Validators().nameValidator,
                        onSaved: (value) {
                          context
                              .read<BookingPageBloc>()
                              .add(ChangeStep1StateEvent(name: value));
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
                        onSaved: (value) {
                          context
                              .read<BookingPageBloc>()
                              .add(ChangeStep1StateEvent(gender: value));
                        },
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
                  validator: Validators().telValidator,
                  onSaved: (value) {
                    context
                        .read<BookingPageBloc>()
                        .add(ChangeStep1StateEvent(tel: value));
                  },
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
