import '../../../../core/utils/typedefs.dart';
import '../entities/user_entity.dart';

abstract class UsersRepository {
  ResultFuture<List<UserEntity>> getUsers();
  ResultFuture<UserEntity> getUserById(int id);
}

