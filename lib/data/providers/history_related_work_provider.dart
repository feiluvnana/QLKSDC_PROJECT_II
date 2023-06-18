import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/history_model.dart';
import 'package:http/http.dart' as http;

import '../dependencies/internal_storage.dart';

class HistoryRelatedWorkProvider {
  static Future<List<History>> getHistoriesList() async {
    var historiesList =
        await http.post(Uri.http("localhost", "php-crash/history.php"), body: {
      "session_id":
          (await SharedPreferences.getInstance()).getString("session_id"),
    }).then((res) {
      if (jsonDecode(res.body)["errors"].length == 0 &&
          (jsonDecode(res.body)["results"].length != 0)) {
        return jsonDecode(res.body)["results"];
      }
      return [];
    });
    List<History> list = List.generate(historiesList.length,
        (index) => History.fromJson(historiesList[index]));
    GetIt.I<InternalStorage>().write("historiesList", list);
    return list;
  }

  static void clearHistoriesList() {
    GetIt.I<InternalStorage>().remove("historiesList");
  }
}
