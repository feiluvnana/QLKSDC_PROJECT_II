import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/service_model.dart';
import '../dependencies/internal_storage.dart';

class ServiceRelatedWorkProvider {
  static Future<List<Service>> getServicesList() async {
    var servicesList =
        await http.post(Uri.http("localhost", "php-crash/service.php"), body: {
      "session_id":
          (await SharedPreferences.getInstance()).getString("session_id"),
    }).then((res) {
      if (jsonDecode(res.body)["errors"].length == 0 &&
          (jsonDecode(res.body)["results"].length != 0)) {
        return jsonDecode(jsonDecode(res.body)["results"]);
      }
      return [];
    });
    List<Service> list = List.generate(
        servicesList.length, (index) => Service.fromJson(servicesList[index]));
    GetIt.I<InternalStorage>().write("servicesList", list);
    return list;
  }

  static Future<http.Response> add(Service service) async {
    return http.post(
        Uri.http("localhost", "php-crash/service_related_work.php"),
        body: <String, String>{
          "data": jsonEncode({...service.toJson()}),
          "session_id":
              (await SharedPreferences.getInstance()).getString("session_id") ??
                  "",
          "flag": "add"
        });
  }

  static Future<http.Response> delete(Service service) async {
    return http.post(
        Uri.http("localhost", "php-crash/service_related_work.php"),
        body: <String, String>{
          "data": jsonEncode({...service.toJson()}),
          "session_id":
              (await SharedPreferences.getInstance()).getString("session_id") ??
                  "",
          "flag": "delete"
        });
  }

  static Future<http.Response> modify(
      Service service, Service old_service) async {
    return http.post(
        Uri.http("localhost", "php-crash/service_related_work.php"),
        body: <String, String>{
          "data": jsonEncode([service.toJson(), old_service.toJson()]),
          "session_id":
              (await SharedPreferences.getInstance()).getString("session_id") ??
                  "",
          "flag": "modify"
        });
  }

  static void clearServicesList() {
    GetIt.I<InternalStorage>().remove("servicesList");
  }
}
