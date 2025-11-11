import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // Get a value
  Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }

  // Set a value
  Future<void> set(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Delete a value
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Delete all values
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  // Get all keys
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
}
