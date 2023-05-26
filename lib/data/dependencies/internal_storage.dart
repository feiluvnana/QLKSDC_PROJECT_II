// ignore_for_file: prefer_final_fields

import 'package:get_it/get_it.dart';

class InternalStorage {
  static void init() {
    GetIt.I.registerSingleton<InternalStorage>(InternalStorage());
  }

  Map<String, dynamic> _storage = {};

  dynamic read(String key) {
    return _storage.keys.any((element) => element == key)
        ? _storage[key]
        : null;
  }

  void write(String key, dynamic value) {
    _storage.addAll({key: value});
  }

  void remove(String key) {
    _storage.remove(key);
  }
}
