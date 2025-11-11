import 'package:hive/hive.dart';

class HiveStorageService {
  final Box _box;

  HiveStorageService(this._box);

  // Generic getter
  T? get<T>(String key, {T? defaultValue}) {
    return _box.get(key, defaultValue: defaultValue) as T?;
  }

  // Generic setter
  Future<void> set<T>(String key, T value) async {
    await _box.put(key, value);
  }

  // Delete a key
  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  // Clear all data
  Future<void> clear() async {
    await _box.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return _box.containsKey(key);
  }

  // Get all keys
  Iterable<dynamic> getKeys() {
    return _box.keys;
  }
}
