// ignore_for_file: invalid_use_of_protected_member

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as ip;

class ImagePicker extends StatelessWidget {
  final void Function(Uint8List?)? onChanged, onSaved;
  final double? width, height;
  final Widget? initialWidget;

  const ImagePicker(
      {super.key,
      this.onChanged,
      this.width,
      this.height,
      this.onSaved,
      this.initialWidget});

  @override
  Widget build(BuildContext context) {
    return FormField<Uint8List>(
      initialValue: null,
      onSaved: onSaved,
      builder: (formState) {
        return Column(
          children: [
            InputDecorator(
              decoration: InputDecoration(
                constraints: BoxConstraints.loose(
                    (width != null && height != null)
                        ? Size(width!, height!)
                        : const Size(800, 800)),
                labelText: "Ảnh",
                errorText: formState.errorText,
                border: const OutlineInputBorder(),
              ),
              child: formState.value == null
                  ? initialWidget ?? const SizedBox.expand()
                  : Image.memory(
                      formState.value!,
                      width: width,
                      height: height,
                      fit: BoxFit.scaleDown,
                    ),
            ),
            ElevatedButton(
              onPressed: () async {
                ip.XFile? file = await ip.ImagePicker().pickImage(
                    source: ip.ImageSource.gallery,
                    imageQuality: 75,
                    maxWidth: 800,
                    maxHeight: 800);
                Uint8List? bytes =
                    (file == null) ? null : await file.readAsBytes();
                _exec(bytes, onChanged);
                formState.setState(() {
                  formState.setValue(bytes);
                });
              },
              child: const Text("Chọn ảnh"),
            )
          ],
        );
      },
    );
  }

  void _exec(Uint8List? value, void Function(Uint8List?)? func) {
    if (func != null) func(value);
  }
}
