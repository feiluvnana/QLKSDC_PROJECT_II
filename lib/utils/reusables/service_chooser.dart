// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:project_ii/utils/validators/validators.dart';
import '../../data/dependencies/internal_storage.dart';
import '../../data/providers/addition_model.dart';
import '../../models/service_model.dart';
import 'date_time_picker.dart';
import 'location_picker.dart';

class AdditionChooser extends StatelessWidget {
  final List<Addition>? initialValue;
  final void Function(List<Addition>?)? onSaved, onChanged;
  final DateTime checkIn, checkOut;
  final bool? alwaysEnabled;
  const AdditionChooser(
      {super.key,
      this.initialValue,
      this.onSaved,
      this.onChanged,
      required this.checkIn,
      required this.checkOut,
      this.alwaysEnabled});
  @override
  Widget build(BuildContext context) {
    return FormField<List<Addition>>(
      initialValue: initialValue,
      onSaved: onSaved,
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
                children: List.generate(formState.value?.length ?? 0, (index) {
                  List<Service> servicesList =
                      GetIt.I<InternalStorage>().read("servicesList");
                  return Row(mainAxisSize: MainAxisSize.min, children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: DropdownButtonFormField<int>(
                          items: List.generate(
                              servicesList.length,
                              (index) => DropdownMenuItem(
                                  value: servicesList[index].id,
                                  child: Text(servicesList[index].name))),
                          onChanged: alwaysEnabled ??
                                  false || _enable(formState.value![index])
                              ? (value) {
                                  if (value == null) return;
                                  formState.setState(() {
                                    formState.setValue(List.generate(
                                        formState.value!.length, (i) {
                                      if (i == index) {
                                        return Addition.fromJson(_generateJson(
                                            value, null, null, null));
                                      }
                                      return formState.value![i];
                                    }));
                                  });
                                  _exec(formState.value, onChanged);
                                }
                              : null,
                          validator: Validators().notNullValidator,
                          value: formState.value?[index].serviceID == -1
                              ? null
                              : formState.value?[index].serviceID,
                          decoration: const InputDecoration(
                              errorMaxLines: 2,
                              labelText: "Loại dịch vụ",
                              border: OutlineInputBorder()),
                        ),
                      ),
                    ),
                    if (servicesList.any((element) =>
                        element.id == formState.value?[index].serviceID))
                      (servicesList
                              .firstWhere((element) =>
                                  element.id ==
                                  formState.value?[index].serviceID)
                              .distanceNeed)
                          ? Flexible(
                              child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: LocationPicker(
                                  enabled: alwaysEnabled ??
                                          formState.value?[index].time == null
                                      ? true
                                      : DateTime.now().isBefore(
                                          formState.value![index].time!),
                                  initialValue:
                                      formState.value![index].distance,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    formState.setState(() {
                                      formState.setValue(List.generate(
                                          formState.value!.length, (i) {
                                        if (i == index) {
                                          return Addition.fromJson(
                                              _generateJson(
                                                  formState
                                                      .value![index].serviceID,
                                                  value,
                                                  formState
                                                      .value![index].quantity,
                                                  formState
                                                      .value![index].time));
                                        }
                                        return formState.value![i];
                                      }));
                                    });
                                    _exec(formState.value, onChanged);
                                  }),
                            ))
                          : Flexible(flex: 0, child: Container()),
                    if (servicesList.any((element) =>
                        element.id == formState.value?[index].serviceID))
                      (servicesList
                              .firstWhere((element) =>
                                  element.id ==
                                  formState.value?[index].serviceID)
                              .timeNeed)
                          ? Flexible(
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 16),
                                  child: DateTimePicker(
                                    enabled: alwaysEnabled ??
                                            formState.value?[index].time == null
                                        ? true
                                        : DateTime.now().isBefore(
                                            formState.value![index].time!),
                                    validator: Validators(
                                            checkIn: DateTime.now(),
                                            checkOut: checkOut)
                                        .additionsTimeValidator,
                                    title: "Thời gian",
                                    initialValue: formState.value![index].time,
                                    onChanged: (value) {
                                      if (value == null) return;
                                      formState.setState(() {
                                        formState.setValue(List.generate(
                                            formState.value!.length, (i) {
                                          if (i == index) {
                                            return Addition.fromJson(
                                                _generateJson(
                                                    formState.value![index]
                                                        .serviceID,
                                                    formState
                                                        .value![index].distance,
                                                    formState
                                                        .value![index].quantity,
                                                    value));
                                          }
                                          return formState.value![i];
                                        }));
                                      });
                                      _exec(formState.value, onChanged);
                                    },
                                  )))
                          : Flexible(flex: 0, child: Container()),
                    if (servicesList.any((element) =>
                        element.id == formState.value?[index].serviceID))
                      (servicesList
                              .firstWhere((element) =>
                                  element.id ==
                                  formState.value?[index].serviceID)
                              .quantityNeed)
                          ? Flexible(
                              child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              child: TextFormField(
                                enabled: alwaysEnabled ??
                                        formState.value?[index].time == null
                                    ? true
                                    : DateTime.now().isBefore(
                                        formState.value![index].time!),
                                validator: Validators().intValidator,
                                initialValue:
                                    formState.value?[index].quantity == null
                                        ? null
                                        : formState.value![index].quantity
                                            .toString(),
                                onChanged: (value) {
                                  var newValue = int.tryParse(value);
                                  formState.setState(() {
                                    formState.setValue(List.generate(
                                        formState.value!.length, (i) {
                                      if (i == index) {
                                        return Addition.fromJson(_generateJson(
                                            formState.value![index].serviceID,
                                            formState.value![index].distance,
                                            newValue,
                                            formState.value![index].time));
                                      }
                                      return formState.value![i];
                                    }));
                                  });
                                  _exec(formState.value, onChanged);
                                },
                                decoration: const InputDecoration(
                                    label: Text("Số lượng"),
                                    border: OutlineInputBorder()),
                              ),
                            ))
                          : Flexible(flex: 0, child: Container()),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: ElevatedButton(
                          onPressed: alwaysEnabled ??
                                  false || _enable(formState.value![index])
                              ? () {
                                  var newAdditionsList = formState.value;
                                  newAdditionsList?.removeAt(index);
                                  formState.setState(() {
                                    formState.setValue(newAdditionsList);
                                  });
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffff6961),
                            foregroundColor: Colors.black,
                          ),
                          child: const Text("Xoá dịch vụ")),
                    )
                  ]);
                }),
              ),
              ElevatedButton(
                  onPressed: () {
                    if (formState.value == null) {
                      formState.setState(() {
                        formState.setValue([Addition.empty()]);
                      });
                      _exec(formState.value, onChanged);
                      return;
                    }
                    formState.setState(() {
                      formState
                          .setValue([...formState.value!, Addition.empty()]);
                    });
                    _exec(formState.value, onChanged);
                  },
                  child: const Text("Thêm dịch vụ"))
            ],
          ),
        ),
      ),
    );
  }

  void _exec(List<Addition>? value, void Function(List<Addition>?)? func) {
    if (func != null) func(value);
  }

  Map<String, dynamic> _generateJson(
      int serviceID, String? distance, int? quantity, DateTime? time) {
    return {
      "service_id": serviceID,
      "distance": distance,
      "quantity": quantity,
      "time": time?.toString()
    };
  }

  bool _enable(Addition? addition) {
    if (addition?.time?.isBefore(DateTime.now()) == true) return false;
    return true;
  }
}
