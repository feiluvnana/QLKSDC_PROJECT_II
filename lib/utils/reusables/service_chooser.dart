import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/AdditionModel.dart';
import '/utils/InternalStorage.dart';
import '../../model/ServiceModel.dart';
import 'date_time_picker.dart';
import 'location_picker.dart';

class AdditionChooser extends StatelessWidget {
  final List<Addition>? initialValue;
  final void Function(List<Addition>?)? onSaved;
  const AdditionChooser({super.key, this.initialValue, this.onSaved});
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
                      Get.find<InternalStorage>().read("servicesList");
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
                          onChanged: (value) {
                            if (value == null) return;
                            formState.setState(() {
                              formState.setValue(
                                  List.generate(formState.value!.length, (i) {
                                if (i == index) {
                                  return Addition.fromJson(_generateJson(
                                      value,
                                      servicesList
                                          .firstWhere(
                                              (element) => element.id == value)
                                          .name,
                                      servicesList
                                          .firstWhere(
                                              (element) => element.id == value)
                                          .price,
                                      null,
                                      null,
                                      null));
                                }
                                return formState.value![i];
                              }));
                            });
                          },
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
                    (servicesList
                                .firstWhereOrNull((element) =>
                                    element.id ==
                                    formState.value?[index].serviceID)
                                ?.distanceNeed ??
                            false)
                        ? Flexible(
                            child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            child: LocationPicker(
                                initialValue: formState.value![index].distance,
                                onChanged: (value) {
                                  if (value == null) return;
                                  formState.setState(() {
                                    formState.setValue(List.generate(
                                        formState.value!.length, (i) {
                                      if (i == index) {
                                        return Addition.fromJson(_generateJson(
                                            formState.value![index].serviceID,
                                            formState.value![index].serviceName,
                                            formState
                                                .value![index].servicePrice,
                                            value,
                                            formState.value![index].quantity,
                                            formState.value![index].time));
                                      }
                                      return formState.value![i];
                                    }));
                                  });
                                }),
                          ))
                        : Flexible(flex: 0, child: Container()),
                    (servicesList
                                .firstWhereOrNull((element) =>
                                    element.id ==
                                    formState.value?[index].serviceID)
                                ?.timeNeed ??
                            false)
                        ? Flexible(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 16),
                                child: DateTimePicker(
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
                                                  formState
                                                      .value![index].serviceID,
                                                  formState.value![index]
                                                      .serviceName,
                                                  formState.value![index]
                                                      .servicePrice,
                                                  formState
                                                      .value![index].distance,
                                                  formState
                                                      .value![index].quantity,
                                                  value));
                                        }
                                        return formState.value![i];
                                      }));
                                    });
                                  },
                                )))
                        : Flexible(flex: 0, child: Container()),
                    (servicesList
                                .firstWhereOrNull((element) =>
                                    element.id ==
                                    formState.value?[index].serviceID)
                                ?.quantityNeed ??
                            false)
                        ? Flexible(
                            child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            child: TextFormField(
                              initialValue: formState.value![index].quantity ==
                                      null
                                  ? null
                                  : formState.value![index].quantity.toString(),
                              onChanged: (value) {
                                if (value == null) return;
                                var newValue = int.tryParse(value);
                                formState.setState(() {
                                  formState.setValue(List.generate(
                                      formState.value!.length, (i) {
                                    if (i == index) {
                                      return Addition.fromJson(_generateJson(
                                          formState.value![index].serviceID,
                                          formState.value![index].serviceName,
                                          formState.value![index].servicePrice,
                                          formState.value![index].distance,
                                          newValue,
                                          formState.value![index].time));
                                    }
                                    return formState.value![i];
                                  }));
                                });
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
                          onPressed: () {
                            var newAdditionsList = formState.value;
                            newAdditionsList?.removeAt(index);
                            formState.setState(() {
                              formState.setValue(newAdditionsList);
                            });
                          },
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
                      return;
                    }
                    formState.setState(() {
                      formState
                          .setValue([...formState.value!, Addition.empty()]);
                    });
                  },
                  child: const Text("Thêm dịch vụ"))
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _generateJson(int serviceID, String serviceName,
      double servicePrice, String? distance, int? quantity, DateTime? time) {
    return {
      "service_id": serviceID,
      "service_name": serviceName,
      "service_price": servicePrice,
      "addition_distance": distance,
      "addition_quantity": quantity,
      "addition_time": time?.toString()
    };
  }
}
