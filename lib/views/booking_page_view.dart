import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../blocs/booking_page_bloc.dart';
import '../data/dependencies/internal_storage.dart';
import '../data/types/render_state.dart';
import '../utils/reusables/date_time_picker.dart';
import '../utils/reusables/location_picker.dart';
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
                    context.read<BookingPageBloc>().add(NextStepEvent(context));
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
                      title: const Text("Nhập thông tin đặt phòng"),
                      content: Form2(internalStorage: internalStorage),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

class Form2 extends StatelessWidget {
  const Form2({
    super.key,
    required this.internalStorage,
  });

  final InternalStorage internalStorage;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingPageBloc, BookingState>(
      buildWhen: (previous, current) =>
          current.currentStep == 1 || previous.isPickedup != current.isPickedup,
      builder: (context, state) {
        return Form(
          key: state.formKey2,
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
                          return DropdownMenuItem(
                              value: internalStorage
                                  .read("roomGroupsList")[index]
                                  .room
                                  .id,
                              child: Text(internalStorage
                                  .read("roomGroupsList")[index]
                                  .room
                                  .id));
                        }),
                        onChanged: (String? value) {
                          if (value != null) {
                            context.read<BookingPageBloc>().add(
                                ModifyOrderEvent(roomID: value, subRoomNum: 1));
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
                        items: state.order.subRoomNum == -1
                            ? null
                            : List.generate(
                                state.order.room.total,
                                (index) => DropdownMenuItem(
                                    value: index + 1,
                                    child: Text("${index + 1}"))),
                        onChanged: (value) {},
                        onSaved: (value) {
                          context
                              .read<BookingPageBloc>()
                              .add(ModifyOrderEvent(subRoomNum: value));
                        },
                        validator: Validators().notNullValidator,
                        value: (state.order.subRoomNum == -1)
                            ? null
                            : state.order.subRoomNum,
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
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: DateTimePicker(
                        title: "Thời gian check-in (dự kiến)",
                        validator: Validators(
                                checkIn: state.order.checkIn,
                                checkOut: state.order.checkOut)
                            .checkInValidator,
                        onChanged: (value) {
                          context
                              .read<BookingPageBloc>()
                              .add(ModifyOrderEvent(checkIn: value));
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
                        title: "Thời gian check-out (dự kiến)",
                        validator: Validators(
                                checkIn: state.order.checkIn,
                                checkOut: state.order.checkOut)
                            .checkOutValidator,
                        onChanged: (value) {
                          context
                              .read<BookingPageBloc>()
                              .add(ModifyOrderEvent(checkOut: value));
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
                              .add(ModifyOrderEvent(attention: value));
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
                              .add(ModifyOrderEvent(note: value));
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: DropdownButtonFormField<bool>(
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: true, child: Text("Có pick-up")),
                    DropdownMenuItem(value: false, child: Text("Không pick-up"))
                  ],
                  onChanged: (value) {
                    context.read<BookingPageBloc>().add(TogglePickupEvent());
                  },
                  validator: Validators().notNullValidator,
                  value: state.isPickedup,
                  hint: const Text("---"),
                  decoration: const InputDecoration(
                    errorMaxLines: 3,
                    labelText: "Lựa chọn pick-up",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              state.isPickedup
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: DateTimePicker(
                          title: "Thời gian pickup",
                          validator: Validators().notNullValidator,
                          onChanged: (value) {
                            context
                                .read<BookingPageBloc>()
                                .add(ModifyPickupEvent(pickupTime: value));
                          }),
                    )
                  : Container(),
              state.isPickedup
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: LocationPicker(onChanged: (value) {
                        context
                            .read<BookingPageBloc>()
                            .add(ModifyPickupEvent(distance: value));
                      }),
                    )
                  : Container(),
            ],
          ),
        );
      },
    );
  }
}

class Form1 extends StatelessWidget {
  const Form1({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingPageBloc, BookingState>(
      buildWhen: (previous, current) => current.currentStep == 0,
      builder: (context, state) {
        return Form(
          key: state.formKey1,
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
                              .add(ModifyOwnerEvent(name: value));
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
                              .add(ModifyOwnerEvent(gender: value));
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
                        .add(ModifyOwnerEvent(tel: value));
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
