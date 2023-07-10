import 'package:flutter/material.dart';

class NoticeDialog {
  static Future showErrDialog(BuildContext context,
      {required dynamic errList, required String firstText}) async {
    Map<String, String> map = Map.from(errList);
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
            title: const Text("Thông báo"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(firstText),
                ...List.generate(
                    map.length,
                    (index) => Text(
                        "Mã lỗi ${map.keys.elementAt(index)}:${map.values.elementAt(index)}"))
              ],
            )));
  }

  static Future showMessageDialog(BuildContext context,
      {required String text}) async {
    return showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(title: const Text("Thông báo"), content: Text(text)));
  }

  static Future<bool?> showConfirmDialog(BuildContext context,
      {required String text}) async {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text("Xác nhận"),
              content: Text(
                  "$text\nHành động này là không thể đảo ngược, tiếp tục chứ?"),
              actions: [
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(foregroundColor: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Xác nhận"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffff6961),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  child: const Text("Huỷ"),
                ),
              ],
            ));
  }

  static Future<bool?> showCheckoutDialog(BuildContext context,
      {String? text}) async {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text("Xác nhận"),
              content: Text(
                  "${text != null ? "$text\n" : ""}Hành động này là không thể đảo ngược, tiếp tục chứ?"),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffff6961),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("Check-out (để đổi phòng)"),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(foregroundColor: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Check-out"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffff6961),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  child: const Text("Huỷ"),
                ),
              ],
            ));
  }
}
