import '../../../../core/error/exceptions.dart';
import '../../../../shared/data/datasources/local_data_source.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
  Future<String?> getAuthToken();
  Future<void> saveAuthToken(String token);
  Future<void> clearAuthToken();
}

class AuthLocalDataSourceImpl extends LocalDataSource
    implements AuthLocalDataSource {
  static const String _userCacheKey = 'cached_user';
  static const String _authTokenKey = 'auth_token';

  AuthLocalDataSourceImpl({
    required super.hiveStorage,
    required super.secureStorage,
  });

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await setHiveData(_userCacheKey, user.toJson());
    } catch (e) {
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = getHiveData<Map<String, dynamic>>(_userCacheKey);
      if (userJson != null) {
        return UserModel.fromJson(userJson);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached user: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await deleteHiveData(_userCacheKey);
      await clearAuthToken();
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }

  @override
  Future<String?> getAuthToken() async {
    return await getSecureData(_authTokenKey);
  }

  @override
  Future<void> saveAuthToken(String token) async {
    await setSecureData(_authTokenKey, token);
  }

  @override
  Future<void> clearAuthToken() async {
    await deleteSecureData(_authTokenKey);
  }
}
