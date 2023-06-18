import 'package:flutter/material.dart';
import '../../model/room_model.dart';
import '../validators/validators.dart';

class RoomInfoDialog {
  final formKey = GlobalKey<FormState>();
  final String title;
  final Room? initialValue;
  RoomInfoDialog({this.initialValue, required this.title});

  Future<Room?> showRoomInfoDialog(BuildContext context) async {
    return showDialog<Room?>(
        context: context,
        builder: (context) => SizedBox.expand(
            child: Center(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width / 3 * 2,
                    height: MediaQuery.of(context).size.height / 3 * 2,
                    child: _RoomInfoForm(
                        initialValue: initialValue,
                        formKey: formKey,
                        title: title)))),
        barrierDismissible: false);
  }
}

class _RoomInfoForm extends StatelessWidget {
  final Room? initialValue;
  final GlobalKey<FormState> formKey;
  final String title;
  final roomID = TextEditingController();
  final roomType = TextEditingController();
  final roomPrice = TextEditingController();
  final roomTotal = TextEditingController();

  _RoomInfoForm(
      {required this.title, this.initialValue, required this.formKey});

  @override
  Widget build(BuildContext context) {
    if (initialValue != null) {
      roomID.text = initialValue!.id;
      roomType.text = initialValue!.type;
      roomPrice.text = initialValue!.price.toInt().toString();
      roomTotal.text = initialValue!.total.toString();
    }
    return Scaffold(
      body: Form(
        key: formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Center(child: Text(title)),
          ),
          Flexible(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: roomID,
              validator: Validators().notNullValidator,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Mã phòng"),
            ),
          )),
          Flexible(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: roomType,
              validator: Validators().nameValidator,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Loại phòng"),
            ),
          )),
          Flexible(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: roomPrice,
              validator: Validators().intValidator,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Giá phòng"),
            ),
          )),
          Flexible(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: roomTotal,
              validator: Validators().intValidator,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Số phòng con"),
            ),
          )),
          Flexible(
              child: (Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() == true) {
                          save(context);
                        }
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
    Navigator.of(context).pop<Room?>(Room.fromJson({
      "id": roomID.text,
      "type": roomType.text,
      "price": double.parse(roomPrice.text),
      "total": int.parse(roomTotal.text)
    }));
  }

  void cancel(BuildContext context) {
    Navigator.of(context).pop<Room?>(null);
  }
}
