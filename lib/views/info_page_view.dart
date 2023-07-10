import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:project_ii/blocs/info_page_bloc.dart';
import '../data/dependencies/internal_storage.dart';
import '../utils/reusables/date_time_picker.dart';
import '../utils/reusables/image_picker.dart';
import '../utils/reusables/service_chooser.dart';
import '../utils/validators/validators.dart';

class InfoPage extends StatelessWidget {
  final int ridx, oidx;
  const InfoPage({
    super.key,
    required this.ridx,
    required this.oidx,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InfoPageBloc>(
      create: (context) => InfoPageBloc(ridx, oidx),
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
                            _.read<InfoPageBloc>().add(GotoHomePage(_)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back, size: 14),
                            Text(" Quay lại")
                          ],
                        ));
                  }),
                ),
                const SizedBox(height: 10),
                const StatusInfo(),
                const SizedBox(height: 50),
                const CatInfo(),
                const SizedBox(height: 50),
                const OwnerInfo(),
                const SizedBox(height: 50),
                const OrderInfo(),
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
                              _.read<InfoPageBloc>().add(SaveChangesEvent(_));
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.save, size: 14),
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
                              backgroundColor: const Color(0xffff6961),
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () {
                              _.read<InfoPageBloc>().add(CancelOrderEvent(_));
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.cancel, size: 14),
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

class StatusInfo extends StatelessWidget {
  const StatusInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfoPageBloc, InformationState>(
        builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Thông tin trạng thái ",
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
                      child: Text("Tình trạng check-out"),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: (state.order.isCheckedout)
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                    Text("Đã check-out")
                                  ])
                            : Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                const Text("Chưa check-out"),
                                (state.order.isCheckedin ||
                                        state.order.isWalkedin)
                                    ? Flexible(
                                        child: Builder(builder: (_) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xfffaf884),
                                                foregroundColor: Colors.black,
                                              ),
                                              onPressed: () async {
                                                _
                                                    .read<InfoPageBloc>()
                                                    .add(CheckoutEvent(_));
                                              },
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.receipt, size: 14),
                                                  Text(" Check-out")
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      )
                                    : Container(),
                              ]))
                  ],
                ),
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xffe3f2fd)),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Tình trạng đặt phòng"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: state.order.isCheckedin
                          ? const Text("Đã check-in")
                          : state.order.isWalkedin
                              ? const Text("Đã walk-in")
                              : Row(children: [
                                  const Text("Đã đặt phòng"),
                                  Flexible(
                                    child: Builder(builder: (_) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xff77dd77),
                                            foregroundColor: Colors.black,
                                          ),
                                          onPressed: () {
                                            context
                                                .read<InfoPageBloc>()
                                                .add(CheckinEvent(context));
                                          },
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check_circle_rounded,
                                                  size: 14),
                                              Text(" Check-in")
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ]),
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

class CatInfo extends StatelessWidget {
  const CatInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfoPageBloc, InformationState>(
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
                        .read<InfoPageBloc>()
                        .add(ToggleModifyCatEvent()),
                    child: Icon((state.isEditing1) ? Icons.close : Icons.edit,
                        size: 28, color: const Color(0xff68b6ef)),
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
                                  initialValue: state.modifiedOrder.cat.name,
                                  onChanged: (value) {
                                    context
                                        .read<InfoPageBloc>()
                                        .add(ModifyCatEvent(name: value));
                                  },
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
                                      onChanged: (value) {
                                        context
                                            .read<InfoPageBloc>()
                                            .add(ModifyCatEvent(image: value));
                                      },
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
                                  onChanged: (String? value) {
                                    context
                                        .read<InfoPageBloc>()
                                        .add(ModifyCatEvent(gender: value));
                                  },
                                  value: state.modifiedOrder.cat.gender,
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
                                  initialValue:
                                      state.modifiedOrder.cat.age.toString(),
                                  onChanged: (value) {
                                    context.read<InfoPageBloc>().add(
                                        ModifyCatEvent(
                                            age: int.tryParse(value)));
                                  },
                                  validator: Validators().intValidator,
                                  decoration: const InputDecoration(
                                    errorMaxLines: 2,
                                    labelText: "Tuổi",
                                    border: OutlineInputBorder(),
                                  ),
                                )
                              : Text(state.order.cat.ageText()),
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
                                      initialValue: state
                                          .modifiedOrder.cat.physicalCondition,
                                      keyboardType: TextInputType.multiline,
                                      validator: Validators()
                                          .multilineTextCanNotNullValidator,
                                      maxLines: null,
                                      onChanged: (value) {
                                        context.read<InfoPageBloc>().add(
                                            ModifyCatEvent(
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
                                      onChanged: (int? value) {
                                        context.read<InfoPageBloc>().add(
                                            ModifyCatEvent(vaccination: value));
                                      },
                                      value:
                                          state.modifiedOrder.cat.vaccination,
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
                                    onChanged: (value) {
                                      context.read<InfoPageBloc>().add(
                                          ModifyCatEvent(sterilization: value));
                                    },
                                    value:
                                        state.modifiedOrder.cat.sterilization,
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
                                  initialValue: state.modifiedOrder.cat.species,
                                  validator: Validators().speciesValidator,
                                  onChanged: (value) {
                                    context.read<InfoPageBloc>().add(
                                        ModifyCatEvent(
                                            species:
                                                value == "" ? null : value));
                                  },
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
                                      initialValue:
                                          state.modifiedOrder.cat.appearance,
                                      keyboardType: TextInputType.multiline,
                                      validator: Validators()
                                          .multilineTextCanNullValidator,
                                      maxLines: null,
                                      onChanged: (value) {
                                        context.read<InfoPageBloc>().add(
                                            ModifyCatEvent(appearance: value));
                                      },
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
                                      onChanged: (String? value) {
                                        context.read<InfoPageBloc>().add(
                                            ModifyCatEvent(weightRank: value));
                                      },
                                      value: state.modifiedOrder.cat.weightRank,
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
                                    initialValue: state.modifiedOrder.cat.weight
                                        ?.toStringAsPrecision(2),
                                    validator: Validators(
                                            weightRank: state
                                                .modifiedOrder.cat.weightRank)
                                        .weightValidator,
                                    onChanged: (value) {
                                      context.read<InfoPageBloc>().add(
                                          ModifyCatEvent(
                                              weight: double.tryParse(value)));
                                    },
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
                                          "Đặc điểm hình thái: \n${state.order.cat.appearance ?? ""}"),
                                    ),
                                    const Spacer(),
                                    Flexible(
                                        child: Text(
                                            "Cân nặng(kg): ${state.order.cat.weight?.toStringAsPrecision(2) ?? "Không được cung cấp"} ${state.order.cat.weightRank == "" ? "" : "(${state.order.cat.weightRank})"}")),
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
    return BlocBuilder<InfoPageBloc, InformationState>(
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
                        .read<InfoPageBloc>()
                        .add(ToggleModifyOwnerEvent()),
                    child: Icon((state.isEditing2) ? Icons.close : Icons.edit,
                        size: 28, color: const Color(0xff68b6ef)),
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
                                    value: state.modifiedOrder.cat.owner.gender,
                                    onChanged: (value) {
                                      context
                                          .read<InfoPageBloc>()
                                          .add(ModifyOwnerEvent(gender: value));
                                    },
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
                                      initialValue:
                                          state.modifiedOrder.cat.owner.name,
                                      validator: Validators().nameValidator,
                                      onChanged: (value) {
                                        context
                                            .read<InfoPageBloc>()
                                            .add(ModifyOwnerEvent(name: value));
                                      },
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
                                  initialValue:
                                      state.modifiedOrder.cat.owner.tel,
                                  validator: Validators().telValidator,
                                  onChanged: (value) {
                                    context
                                        .read<InfoPageBloc>()
                                        .add(ModifyOwnerEvent(tel: value));
                                  },
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

class OrderInfo extends StatelessWidget {
  const OrderInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfoPageBloc, InformationState>(
        builder: (context, state) {
      return Form(
        key: state.formKey3,
        child: Column(
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
                InkWell(
                  onTap: () => context
                      .read<InfoPageBloc>()
                      .add(ToggleModifyOrderEvent()),
                  child: Icon((state.isEditing3) ? Icons.close : Icons.edit,
                      size: 28, color: const Color(0xff68b6ef)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xff68b6ef), width: 1)),
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
                        child: Text(
                            "${state.order.room.id}(${state.order.subRoomNum})"),
                      ),
                    ],
                  ),
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xffE3F2FD)),
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("Ngày đặt phòng"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(DateFormat("yyyy-MM-dd HH:mm:ss")
                            .format(state.order.date)),
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
                        child: (state.isEditing3)
                            ? DropdownButtonFormField<int>(
                                isExpanded: true,
                                items: List.generate(
                                  4,
                                  (index) => DropdownMenuItem(
                                    value: index + 1,
                                    child: Text("${index + 1}"),
                                  ),
                                ),
                                onChanged: (int? value) {
                                  context
                                      .read<InfoPageBloc>()
                                      .add(ModifyOrderEvent(eatingRank: value));
                                },
                                validator: Validators().notNullValidator,
                                value: state.modifiedOrder.eatingRank,
                                hint: const Text("---"),
                                decoration: const InputDecoration(
                                  errorMaxLines: 2,
                                  labelText: "Hạng ăn",
                                  border: OutlineInputBorder(),
                                ),
                              )
                            : Text(state.order.eatingRank == -1
                                ? ""
                                : state.order.eatingRank.toString()),
                      )
                    ],
                  ),
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xffE3F2FD)),
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Lịch trình"),
                      ),
                      (state.isEditing3)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: DateTimePicker(
                                        enabled: !state.order.isCheckedin &&
                                            !state.order.isWalkedin,
                                        initialValue:
                                            state.modifiedOrder.checkIn,
                                        title: "Thời gian check-in",
                                        validator: Validators(
                                                checkIn:
                                                    state.modifiedOrder.checkIn,
                                                checkOut: state
                                                    .modifiedOrder.checkOut)
                                            .checkInValidator,
                                        onChanged: (value) {
                                          context.read<InfoPageBloc>().add(
                                              ModifyOrderEvent(checkIn: value));
                                        },
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DateTimePicker(
                                      enabled: !state.order.isCheckedout,
                                      initialValue:
                                          state.modifiedOrder.checkOut,
                                      title: "Thời gian check-out",
                                      validator: Validators(
                                              checkIn:
                                                  state.modifiedOrder.checkIn,
                                              checkOut:
                                                  state.modifiedOrder.checkOut)
                                          .checkOutValidator,
                                      onChanged: (value) {
                                        context.read<InfoPageBloc>().add(
                                            ModifyOrderEvent(checkOut: value));
                                      },
                                    ),
                                  ))
                                ])
                          : Padding(
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
                                                      "yyyy-MM-dd HH:mm")
                                                  .format(state.order.checkIn),
                                              style: TextStyle(
                                                  color: (state.order.checkIn
                                                              .hour <
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
                                                  .format(state.order.checkOut),
                                              style: TextStyle(
                                                  color: (state.order.checkOut
                                                                  .hour >
                                                              14 ||
                                                          (state.order.checkOut
                                                                      .hour ==
                                                                  14 &&
                                                              state
                                                                      .order
                                                                      .checkOut
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
                        child: Text("Lưu ý"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: (state.isEditing3)
                            ? TextFormField(
                                initialValue: state.modifiedOrder.attention,
                                keyboardType: TextInputType.multiline,
                                validator:
                                    Validators().multilineTextCanNullValidator,
                                onChanged: (value) {
                                  context
                                      .read<InfoPageBloc>()
                                      .add(ModifyOrderEvent(attention: value));
                                },
                                maxLines: null,
                                decoration: const InputDecoration(
                                  labelText: "Lưu ý",
                                  border: OutlineInputBorder(),
                                ),
                              )
                            : Text(state.order.attention ?? ""),
                      )
                    ],
                  ),
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xffE3F2FD)),
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("Ghi chú"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: (state.isEditing3)
                            ? TextFormField(
                                initialValue: state.modifiedOrder.note,
                                keyboardType: TextInputType.multiline,
                                validator:
                                    Validators().multilineTextCanNullValidator,
                                onChanged: (value) {
                                  context
                                      .read<InfoPageBloc>()
                                      .add(ModifyOrderEvent(note: value));
                                },
                                maxLines: null,
                                decoration: const InputDecoration(
                                  labelText: "Ghi chú",
                                  border: OutlineInputBorder(),
                                ),
                              )
                            : Text(state.order.note ?? ""),
                      )
                    ],
                  ),
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
                          child: (!state.isEditing3)
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
                                        (state.order.additionsList == null)
                                            ? 0
                                            : state.order.additionsList!.length,
                                        (index) {
                                      var serviceQuantity = state
                                          .order.additionsList![index].quantity;
                                      var serviceTime = state
                                          .order.additionsList![index].time;
                                      var serviceDistance = state
                                          .order.additionsList![index].distance;
                                      return TableRow(
                                        decoration: (index % 2 == 0)
                                            ? const BoxDecoration(
                                                color: Color(0xffE3F2FD))
                                            : null,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(GetIt.I<
                                                    InternalStorage>()
                                                .read("servicesList")
                                                .firstWhere((element) =>
                                                    state
                                                        .order
                                                        .additionsList![index]
                                                        .serviceID ==
                                                    element.id)
                                                .name),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                "${(serviceQuantity == null) ? "" : "Số lượng: $serviceQuantity\n"}${(serviceTime == null) ? "" : "Thời gian: ${DateFormat("dd/MM/yyyy HH:mm").format(serviceTime)}\n"}${(serviceDistance == null) ? "" : "Thông tin vị trí: $serviceDistance"}"),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(GetIt.I<
                                                    InternalStorage>()
                                                .read("servicesList")
                                                .firstWhere((element) =>
                                                    state
                                                        .order
                                                        .additionsList![index]
                                                        .serviceID ==
                                                    element.id)
                                                .price
                                                .toInt()
                                                .toString()),
                                          ),
                                        ],
                                      );
                                    })
                                  ],
                                )
                              : AdditionChooser(
                                  checkIn: state.modifiedOrder.checkIn,
                                  checkOut: state.modifiedOrder.checkOut,
                                  initialValue:
                                      state.modifiedOrder.additionsList,
                                  onChanged: (value) {
                                    context.read<InfoPageBloc>().add(
                                        ModifyOrderEvent(additionsList: value));
                                  }),
                        ),
                      )
                    ],
                  ),
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xffE3F2FD)),
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("Lễ tân tiếp nhận"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(state.order.inCharge),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
