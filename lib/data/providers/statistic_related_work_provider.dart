import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/statistic_model.dart';
import 'package:http/http.dart' as http;
import '../dependencies/internal_storage.dart';

class StatisticRelatedWorkProvider {
  static Future<void> getStatistic() async {
    Statistic? statistic = await http
        .post(Uri.http("localhost", "php-crash/statistic.php"), body: {
      "session_id":
          (await SharedPreferences.getInstance()).getString("session_id"),
      "data": jsonEncode(
          {"month": DateTime.now().month, "year": DateTime.now().year})
    }).then((res) {
      if (jsonDecode(res.body)["errors"].length == 0 &&
          (jsonDecode(res.body)["results"].length != 0)) {
        return Statistic.fromJson(jsonDecode(res.body)["results"]);
      }
      return null;
    });
    GetIt.I<InternalStorage>().write("statistic", statistic);
  }

  static void clearStatistic() {
    GetIt.I<InternalStorage>().remove("statistic");
  }
}
