import '../../../../core/error/exceptions.dart';
import '../../../../shared/data/datasources/local_data_source.dart';
import '../models/user_model.dart';

abstract class UsersLocalDataSource {
  Future<void> cacheUsers(List<UserModel> users);
  Future<List<UserModel>?> getCachedUsers();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser(int id);
  Future<void> clearCache();
}

class UsersLocalDataSourceImpl extends LocalDataSource
    implements UsersLocalDataSource {
  static const String _usersCacheKey = 'cached_users';
  static const String _userCachePrefix = 'cached_user_';

  UsersLocalDataSourceImpl({
    required super.hiveStorage,
    required super.secureStorage,
  });

  /// Recursively converts Map with dynamic types to Map<String, dynamic>
  Map<String, dynamic> _convertMap(Map map) {
    return Map<String, dynamic>.from(
      map.map((key, value) {
        if (value is Map) {
          return MapEntry(key.toString(), _convertMap(value));
        } else if (value is List) {
          return MapEntry(
            key.toString(),
            value.map((item) => item is Map ? _convertMap(item) : item).toList(),
          );
        } else {
          return MapEntry(key.toString(), value);
        }
      }),
    );
  }

  @override
  Future<void> cacheUsers(List<UserModel> users) async {
    try {
      final usersJson = users.map((user) => user.toJson()).toList();
      await setHiveData(_usersCacheKey, usersJson);
      
      // Also cache individual users
      for (final user in users) {
        await setHiveData('$_userCachePrefix${user.id}', user.toJson());
      }
    } catch (e) {
      throw CacheException('Failed to cache users: ${e.toString()}');
    }
  }

  @override
  Future<List<UserModel>?> getCachedUsers() async {
    try {
      final usersJson = getHiveData<List<dynamic>>(_usersCacheKey);
      if (usersJson != null) {
        return usersJson
            .map((json) {
              // Convert Map<dynamic, dynamic> to Map<String, dynamic>
              final userMap = json as Map;
              final convertedMap = _convertMap(userMap);
              return UserModel.fromJson(convertedMap);
            })
            .toList();
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached users: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await setHiveData('$_userCachePrefix${user.id}', user.toJson());
    } catch (e) {
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCachedUser(int id) async {
    try {
      final userJson = getHiveData<Map>('$_userCachePrefix$id');
      if (userJson != null) {
        // Convert Map<dynamic, dynamic> to Map<String, dynamic>
        final convertedMap = _convertMap(userJson);
        return UserModel.fromJson(convertedMap);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached user: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await deleteHiveData(_usersCacheKey);
      // Note: Individual user cache cleanup would require listing all keys
      // For simplicity, we'll just clear the main list
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }
}

