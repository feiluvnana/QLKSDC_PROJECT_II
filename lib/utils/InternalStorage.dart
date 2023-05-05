class InternalStorage {
  Map<String, dynamic> _storage;

  InternalStorage() : _storage = {};

  void write(String key, dynamic value) {
    _storage.addAll({key: value});
  }

  dynamic read(String key) {
    if (!_storage.keys.contains(key)) return null;
    return _storage[key];
  }

  void remove(String key) {
    _storage.remove(key);
  }
}
