import '../../../core/error/exceptions.dart';
import '../../../services/storage/hive_storage_service.dart';
import '../../../services/storage/secure_storage_service.dart';

abstract class LocalDataSource {
  final HiveStorageService hiveStorage;
  final SecureStorageService secureStorage;

  LocalDataSource({required this.hiveStorage, required this.secureStorage});

  // Hive storage methods
  T? getHiveData<T>(String key, {T? defaultValue}) {
    try {
      return hiveStorage.get<T>(key, defaultValue: defaultValue);
    } catch (e) {
      throw CacheException('Failed to get data: ${e.toString()}');
    }
  }

  Future<void> setHiveData<T>(String key, T value) async {
    try {
      await hiveStorage.set(key, value);
    } catch (e) {
      throw CacheException('Failed to save data: ${e.toString()}');
    }
  }

  Future<void> deleteHiveData(String key) async {
    try {
      await hiveStorage.delete(key);
    } catch (e) {
      throw CacheException('Failed to delete data: ${e.toString()}');
    }
  }

  // Secure storage methods
  Future<String?> getSecureData(String key) async {
    try {
      return await secureStorage.get(key);
    } catch (e) {
      throw CacheException('Failed to get secure data: ${e.toString()}');
    }
  }

  Future<void> setSecureData(String key, String value) async {
    try {
      await secureStorage.set(key, value);
    } catch (e) {
      throw CacheException('Failed to save secure data: ${e.toString()}');
    }
  }

  Future<void> deleteSecureData(String key) async {
    try {
      await secureStorage.delete(key);
    } catch (e) {
      throw CacheException('Failed to delete secure data: ${e.toString()}');
    }
  }
}
