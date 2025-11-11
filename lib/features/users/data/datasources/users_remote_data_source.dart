import '../../../../core/error/exceptions.dart';
import '../../../../shared/data/datasources/remote_data_source.dart';
import '../models/user_model.dart';

abstract class UsersRemoteDataSource {
  Future<List<UserModel>> getUsers();
  Future<UserModel> getUserById(int id);
}

class UsersRemoteDataSourceImpl extends RemoteDataSource
    implements UsersRemoteDataSource {
  UsersRemoteDataSourceImpl(super.httpClient);

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await get('/users');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException('Failed to fetch users');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error fetching users: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getUserById(int id) async {
    try {
      final response = await get('/users/$id');

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to fetch user');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error fetching user: ${e.toString()}');
    }
  }
}
