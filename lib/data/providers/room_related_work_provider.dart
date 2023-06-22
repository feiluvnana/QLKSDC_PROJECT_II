import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/room_model.dart';
import 'package:http/http.dart' as http;

class RoomRelatedWorkProvider {
  static Future<List<Room>> getRoomsList() async {
    var roomList =
        await http.post(Uri.http("localhost", "php-crash/room.php"), body: {
      "session_id":
          (await SharedPreferences.getInstance()).getString("session_id"),
    }).then((res) {
      if (jsonDecode(res.body)["errors"].length == 0 &&
          (jsonDecode(res.body)["results"].length != 0)) {
        return jsonDecode(res.body)["results"];
      }

      return [];
    });
    List<Room> list = List.generate(
        roomList.length, (index) => Room.fromJson(roomList[index]));
    return list;
  }

  static Future<http.Response> add(Room room) async {
    return http.post(Uri.http("localhost", "php-crash/room_related_work.php"),
        body: <String, String>{
          "data": jsonEncode({...room.toJson()}),
          "session_id":
              (await SharedPreferences.getInstance()).getString("session_id") ??
                  "",
          "flag": "add"
        });
  }

  static Future<http.Response> delete(Room room) async {
    return http.post(Uri.http("localhost", "php-crash/room_related_work.php"),
        body: <String, String>{
          "data": jsonEncode({...room.toJson()}),
          "session_id":
              (await SharedPreferences.getInstance()).getString("session_id") ??
                  "",
          "flag": "delete"
        });
  }

  static Future<http.Response> modify(Room room, Room oldRoom) async {
    return http.post(Uri.http("localhost", "php-crash/room_related_work.php"),
        body: <String, String>{
          "data": jsonEncode([room.toJson(), oldRoom.toJson()]),
          "session_id":
              (await SharedPreferences.getInstance()).getString("session_id") ??
                  "",
          "flag": "modify"
        });
  }
}
