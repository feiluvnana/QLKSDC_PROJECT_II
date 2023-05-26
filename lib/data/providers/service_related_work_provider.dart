import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/ServiceModel.dart';
import '../dependencies/internal_storage.dart';

class ServiceRelatedWorkProvider {
  static Future<void> getServicesList() async {
    List<dynamic> resList = await http
        .post(Uri.http("localhost", "php-crash/getService.php"), body: {
      "sessionID":
          (await SharedPreferences.getInstance()).getString("sessionID")
    }).then((res) {
      if (jsonDecode(res.body)["status"] == "successed") {
        return jsonDecode(jsonDecode(res.body)["result"]);
      }
      return [];
    });
    List<Service> list = [];
    for (var s in resList) {
      list.add(Service.fromJson(s));
    }
    GetIt.I<InternalStorage>().write("servicesList", list);
  }
}
