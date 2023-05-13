import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoomPage extends StatelessWidget {
  const RoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          flex: 4,
          child: Container(padding: const EdgeInsets.all(20), child: const Placeholder()),
        ),
        Flexible(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.black),
                  onPressed: () async {
                    await GetConnect().post("http://localhost/php-crash/room.php", {});
                  },
                  child: Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: const Text("Thêm"),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xfffaf884),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => {},
                  child: Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: const Text("Sửa"),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffff6961),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => {},
                  child: Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: const Text("Xóa"),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
