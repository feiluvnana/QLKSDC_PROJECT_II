import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/RoomModel.dart';
import '../dependencies/internal_storage.dart';
import 'package:http/http.dart' as http;

class RoomRelatedWorkProvider {
  static Future<List<Room>> getRoomsList() async {
    var roomList =
        await http.post(Uri.http("localhost", "php-crash/getRoom.php"), body: {
      "sessionID":
          (await SharedPreferences.getInstance()).getString("sessionID"),
    }).then(
      (res) {
        if (jsonDecode(res.body)["status"] == "successed") {
          return jsonDecode(jsonDecode(res.body)["result"]);
        }
        return [];
      },
    );
    List<Room> list = List.generate(
        roomList.length, (index) => Room.fromJson(roomList[index]));
    GetIt.I<InternalStorage>().write("roomsList", list);
    return list;
  }
}
