import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePicker extends StatelessWidget {
  final String title;
  final String? Function(DateTime?)? validator;
  final void Function(DateTime?)? onSaved, onChanged;
  final DateTime? initialValue;

  const DateTimePicker(
      {super.key,
      required this.title,
      this.validator,
      this.onSaved,
      this.onChanged,
      this.initialValue});

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: initialValue,
      validator: validator,
      onSaved: onSaved,
      builder: (formState) {
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
            // ignore: use_build_context_synchronously
            var time = (await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              helpText: "Chọn giờ",
              cancelText: "Hủy",
              confirmText: "Xác nhận",
            ));
            if (time == null) return;
            date = DateTime(
                date.year, date.month, date.day, time.hour, time.minute);
            if (context.mounted) {
              _exec(date, onChanged);
              formState.setState(() {
                formState.setValue(date);
              });
            }
          },
          child: InputDecorator(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                errorMaxLines: 2,
                labelText: title,
              ).applyDefaults(Theme.of(context).inputDecorationTheme),
              child: formState.value == null
                  ? null
                  : Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(formState.value!))),
        );
      },
    );
  }

  void _exec(DateTime? value, void Function(DateTime?)? func) {
    if (func != null) func(value);
  }
}
