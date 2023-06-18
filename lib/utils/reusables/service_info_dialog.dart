import 'package:flutter/material.dart';
import '../../model/service_model.dart';
import '../validators/validators.dart';

class ServiceInfoDialog {
  final formKey = GlobalKey<FormState>();
  final String title;
  final Service? initialValue;
  ServiceInfoDialog({this.initialValue, required this.title});

  Future<Service?> showServiceInfoDialog(BuildContext context) async {
    return showDialog<Service?>(
        context: context,
        builder: (context) => SizedBox.expand(
            child: Center(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width / 3 * 2,
                    height: MediaQuery.of(context).size.height / 3 * 2,
                    child: _ServiceInfoForm(
                        initialValue: initialValue,
                        formKey: formKey,
                        title: title)))),
        barrierDismissible: false);
  }
}

class _ServiceInfoForm extends StatefulWidget {
  final Service? initialValue;
  final GlobalKey<FormState> formKey;
  final String title;

  _ServiceInfoForm(
      {required this.title, this.initialValue, required this.formKey});

  @override
  State<_ServiceInfoForm> createState() =>
      _ServiceInfoFormState(initialValue: initialValue);
}

class _ServiceInfoFormState extends State<_ServiceInfoForm> {
  final serviceName = TextEditingController();

  final servicePrice = TextEditingController();

  bool d_need, q_need, t_need;

  _ServiceInfoFormState({Service? initialValue})
      : d_need = initialValue?.distanceNeed ?? false,
        t_need = initialValue?.timeNeed ?? false,
        q_need = initialValue?.quantityNeed ?? false {
    serviceName.text = initialValue?.name ?? "";
    servicePrice.text = initialValue?.price.toInt().toString() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: widget.formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Center(child: Text(widget.title)),
              ),
              Flexible(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: serviceName,
                  validator: Validators().notNullValidator,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Tên dịch vụ"),
                ),
              )),
              Flexible(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: servicePrice,
                  validator: Validators().intValidator,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Giá dịch vụ"),
                ),
              )),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Thông tin cần cung cấp",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: d_need,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                d_need = value;
                              });
                            },
                          ),
                          const Text("Thông tin vị trí")
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: q_need,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                q_need = value;
                              });
                            },
                          ),
                          const Text("Số lượng")
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: t_need,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                t_need = value;
                              });
                            },
                          ),
                          const Text("Thời gian")
                        ],
                      ),
                    ],
                  )),
              Flexible(
                  child: Center(
                      child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            save(context);
                          },
                          child: const Text("Lưu")),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            cancel(context);
                          },
                          child: const Text("Huỷ")),
                    ),
                  )
                ],
              )))
            ]),
      ),
    );
  }

  void save(BuildContext context) {
    Navigator.of(context).pop<Service?>(Service.fromJson({
      "id": -1,
      "name": serviceName.text,
      "price": double.parse(servicePrice.text),
      "q_need": q_need ? 1 : 0,
      "t_need": t_need ? 1 : 0,
      "d_need": d_need ? 1 : 0
    }));
  }

  void cancel(BuildContext context) {
    Navigator.of(context).pop<Service?>(null);
  }
}
