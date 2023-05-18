import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../model/ServiceModel.dart';
import '../../utils/InternalStorage.dart';

class ServiceDataProvider {
  Future<void> getServices() async {
    List<dynamic> resList = await GetConnect()
        .post(
      "http://localhost/php-crash/getService.php",
      FormData({"sessionID": GetStorage().read("sessionID")}),
    )
        .then((res) {
      if (res.body == null) return [];
      if (jsonDecode(res.body)["status"] == "successed") {
        return jsonDecode(jsonDecode(res.body)["result"]);
      }
      return [];
    });
    List<Service> list = [];
    for (var s in resList) {
      list.add(Service.fromJson(s));
    }
    Get.find<InternalStorage>().write("servicesList", list);
  }
}
