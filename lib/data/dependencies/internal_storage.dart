// ignore_for_file: prefer_final_fields
import 'package:get_it/get_it.dart';
import 'package:project_ii/models/history_model.dart';
import '../../models/room_group_model.dart';
import '../../models/service_model.dart';
import 'package:rxdart/rxdart.dart';
import '../../models/statistic_model.dart';

class InternalStorage {
  static void init() {
    GetIt.I.registerSingleton<InternalStorage>(InternalStorage());
  }

  final Map<String, BehaviorSubject<dynamic>> _storage = {
    "statistic": BehaviorSubject<Statistic?>(),
    "historiesList": BehaviorSubject<List<History>?>(),
    "roomGroupsList": BehaviorSubject<List<RoomGroup>?>(),
    "servicesList": BehaviorSubject<List<Service>?>(),
  };

  dynamic read(String key) {
    return _storage[key]?.valueOrNull;
  }

  ValueStream<dynamic>? expose(String key) {
    return _storage[key]?.stream;
  }

  void write(String key, dynamic value) {
    _storage[key]?.add(value);
  }

  void remove(String key) {
    _storage[key]?.add(null);
  }
}
