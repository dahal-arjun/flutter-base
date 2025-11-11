import '../../../../core/utils/typedefs.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  ResultFuture<User> login(String email, String password);
  ResultFuture<User> register(String email, String password, String name);
  ResultFuture<void> logout();
  ResultFuture<User?> getCurrentUser();
  ResultFuture<bool> isAuthenticated();
}

