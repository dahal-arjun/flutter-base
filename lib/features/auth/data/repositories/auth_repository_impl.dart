import '../../../../core/utils/typedefs.dart';
import '../../../../shared/data/repositories/base_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
// TODO: Uncomment when auth API is available
// import '../datasources/auth_remote_data_source.dart';

/// Implementation of AuthRepository
/// Currently supports only local authentication (biometric)
/// Remote authentication will be added when API is available
class AuthRepositoryImpl with BaseRepository implements AuthRepository {
  // Remote data source will be added when auth API is available
  // final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  /// Creates an AuthRepositoryImpl instance
  /// [localDataSource] - Local data source for caching user data
  AuthRepositoryImpl({
    // remoteDataSource will be required when auth API is available
    // required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Login user with email and password
  /// Note: Currently not implemented - use biometric authentication instead
  /// TODO: Implement when auth API is available
  @override
  ResultFuture<User> login(String email, String password) async {
    return handleException(() async {
      // TODO: Implement when auth API is available
      // For now, biometric login doesn't require API calls
      throw Exception(
        'Login API not available. Use biometric authentication instead.',
      );
    });
  }

  /// Register a new user
  /// Note: Currently not implemented
  /// TODO: Implement when auth API is available
  @override
  ResultFuture<User> register(
    String email,
    String password,
    String name,
  ) async {
    return handleException(() async {
      // TODO: Implement when auth API is available
      throw Exception('Registration API not available.');
    });
  }

  @override
  ResultFuture<void> logout() async {
    return handleException(() async {
      // No remote logout needed - just clear local cache
      // await remoteDataSource.logout(); // Commented out - no auth API
      await localDataSource.clearCache();
    });
  }

  @override
  ResultFuture<User?> getCurrentUser() async {
    return handleException(() async {
      final cachedUser = await localDataSource.getCachedUser();
      return cachedUser?.toEntity();
    });
  }

  @override
  ResultFuture<bool> isAuthenticated() async {
    return handleException(() async {
      final token = await localDataSource.getAuthToken();
      final user = await localDataSource.getCachedUser();
      return token != null && user != null;
    });
  }
}
