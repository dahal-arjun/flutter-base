import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/data/repositories/base_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/users_local_data_source.dart';
import '../datasources/users_remote_data_source.dart';

class UsersRepositoryImpl with BaseRepository implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;
  final UsersLocalDataSource localDataSource;

  UsersRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  ResultFuture<List<UserEntity>> getUsers() async {
    return handleException(() async {
      final connectivityService = di.getIt<ConnectivityService>();
      final isOnline =
          connectivityService.currentStatus == NetworkStatus.online;

      // Try cache first - always return cached data if available
      final cachedUsers = await localDataSource.getCachedUsers();
      if (cachedUsers != null && cachedUsers.isNotEmpty) {
        // If online, try to refresh in background
        if (isOnline) {
          _refreshUsersInBackground();
        }
        // Return cached data immediately (works offline)
        return cachedUsers.map((model) => model.toEntity()).toList();
      }

      // If no cache and offline, return error with helpful message
      if (!isOnline) {
        throw Exception(
          'No internet connection. Please connect to the internet to load users.',
        );
      }

      // If online and no cache, fetch from remote
      final remoteUsers = await remoteDataSource.getUsers();
      await localDataSource.cacheUsers(remoteUsers);
      return remoteUsers.map((model) => model.toEntity()).toList();
    });
  }

  @override
  ResultFuture<UserEntity> getUserById(int id) async {
    return handleException(() async {
      // Try cache first
      final cachedUser = await localDataSource.getCachedUser(id);
      if (cachedUser != null) {
        // Return cached data immediately, then refresh in background
        _refreshUserInBackground(id);
        return cachedUser.toEntity();
      }

      // Fetch from remote if no cache
      final remoteUser = await remoteDataSource.getUserById(id);
      await localDataSource.cacheUser(remoteUser);
      return remoteUser.toEntity();
    });
  }

  // Refresh users in background without blocking
  void _refreshUsersInBackground() async {
    try {
      final connectivityService = di.getIt<ConnectivityService>();
      // Only refresh if online
      if (connectivityService.currentStatus == NetworkStatus.online) {
        final remoteUsers = await remoteDataSource.getUsers();
        await localDataSource.cacheUsers(remoteUsers);
      }
    } catch (e) {
      // Silently fail - we already have cached data
    }
  }

  // Refresh single user in background without blocking
  void _refreshUserInBackground(int id) async {
    try {
      final remoteUser = await remoteDataSource.getUserById(id);
      await localDataSource.cacheUser(remoteUser);
    } catch (e) {
      // Silently fail - we already have cached data
    }
  }
}
