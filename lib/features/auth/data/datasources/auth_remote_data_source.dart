import '../../../../core/error/exceptions.dart';
import '../../../../shared/data/datasources/remote_data_source.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String name);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl extends RemoteDataSource
    implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(super.httpClient);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Login failed');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Login error: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register(String email, String password, String name) async {
    try {
      final response = await post(
        '/auth/register',
        data: {'email': email, 'password': password, 'name': name},
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Registration failed');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Registration error: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await post('/auth/logout');
    } catch (e) {
      throw ServerException('Logout error: ${e.toString()}');
    }
  }
}
