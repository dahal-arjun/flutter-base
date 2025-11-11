import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// TODO: Uncomment when Firebase is configured
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

import '../../core/constants/app_constants.dart';
import '../../services/storage/hive_storage_service.dart';
import '../../services/storage/secure_storage_service.dart';
import '../../services/auth/local_auth_service.dart';
import '../../services/notifications/notification_service.dart';
import '../../services/http/http_client_service.dart';
import '../../services/language/language_service.dart';
import '../../services/theme/theme_service.dart';

// Auth Feature
import '../../features/auth/data/datasources/auth_local_data_source.dart';
// TODO: Uncomment when auth API is available
// import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Users Feature
import '../../features/users/data/datasources/users_local_data_source.dart';
import '../../features/users/data/datasources/users_remote_data_source.dart';
import '../../features/users/data/repositories/users_repository_impl.dart';
import '../../features/users/domain/repositories/users_repository.dart';
import '../../features/users/domain/usecases/get_user_by_id_usecase.dart';
import '../../features/users/domain/usecases/get_users_usecase.dart';
import '../../features/users/presentation/bloc/users_bloc.dart';

// Posts Feature
import '../../features/posts/data/datasources/posts_local_data_source.dart';
import '../../features/posts/data/datasources/posts_remote_data_source.dart';
import '../../features/posts/data/repositories/posts_repository_impl.dart';
import '../../features/posts/domain/repositories/posts_repository.dart';
import '../../features/posts/domain/usecases/get_posts_usecase.dart';
import '../../features/posts/domain/usecases/get_post_by_id_usecase.dart';
import '../../features/posts/presentation/bloc/posts_bloc.dart';
import '../../features/posts/presentation/bloc/post_detail_bloc.dart';

// Comments Feature
import '../../features/comments/data/datasources/comments_local_data_source.dart';
import '../../features/comments/data/datasources/comments_remote_data_source.dart';
import '../../features/comments/data/repositories/comments_repository_impl.dart';
import '../../features/comments/domain/repositories/comments_repository.dart';
import '../../features/comments/domain/usecases/get_comments_by_post_id_usecase.dart';
import '../../features/comments/domain/usecases/create_comment_usecase.dart';
import '../../features/comments/presentation/bloc/comments_bloc.dart';

// Network
import '../../core/network/connectivity_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // TODO: Uncomment when Firebase is configured
  // Initialize Firebase (optional - only if Firebase config files exist)
  // try {
  //   await Firebase.initializeApp();
  // } catch (e) {
  //   // Firebase not configured - skip initialization
  //   // This is fine if you're not using Firebase features
  //   debugPrint('Firebase initialization skipped: $e');
  // }

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Box
  final hiveBox = await Hive.openBox(AppConstants.hiveBoxName);
  getIt.registerLazySingleton<Box>(() => hiveBox);

  // Storage Services
  // Register HiveStorageService first (needed as fallback for SecureStorageService)
  getIt.registerLazySingleton<HiveStorageService>(
    () => HiveStorageService(getIt<Box>()),
  );
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  // Provide Hive storage as fallback for macOS development (when secure storage fails)
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(
      getIt<FlutterSecureStorage>(),
      fallbackStorage: getIt<HiveStorageService>(),
    ),
  );

  // Language Service
  getIt.registerLazySingleton<LanguageService>(
    () => LanguageService(getIt<SecureStorageService>()),
  );

  // Theme Service
  getIt.registerLazySingleton<ThemeService>(
    () => ThemeService(getIt<SecureStorageService>()),
  );

  // Auth Services
  getIt.registerLazySingleton<LocalAuthentication>(() => LocalAuthentication());
  getIt.registerLazySingleton<LocalAuthService>(
    () => LocalAuthService(getIt<LocalAuthentication>()),
  );

  // Notification Services
  getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );

  // TODO: Uncomment when Firebase is configured
  // Firebase Messaging (register only if Firebase was initialized)
  // FirebaseMessaging? firebaseMessaging;
  // try {
  //   firebaseMessaging = FirebaseMessaging.instance;
  //   getIt.registerLazySingleton<FirebaseMessaging>(() => firebaseMessaging!);
  // } catch (e) {
  //   debugPrint('Firebase Messaging not available: $e');
  // }

  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(
      getIt<FlutterLocalNotificationsPlugin>(),
      // TODO: Uncomment when Firebase is configured
      // firebaseMessaging ?? FirebaseMessaging.instance,
      null, // Firebase Messaging not configured yet
    ),
  );

  // HTTP Client
  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    ),
  );
  getIt.registerLazySingleton<HttpClientService>(
    () => HttpClientService(getIt<Dio>()),
  );

  // ========== Auth Feature ==========

  // Data Sources
  // TODO: Uncomment when auth API is available
  // getIt.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(getIt<HttpClientService>()),
  // );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      hiveStorage: getIt<HiveStorageService>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      // remoteDataSource: getIt<AuthRemoteDataSource>(), // Commented out - no auth API
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt<AuthRepository>()),
  );

  // BLoC
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    ),
  );

  // ========== Users Feature ==========

  // Data Sources
  getIt.registerLazySingleton<UsersRemoteDataSource>(
    () => UsersRemoteDataSourceImpl(getIt<HttpClientService>()),
  );
  getIt.registerLazySingleton<UsersLocalDataSource>(
    () => UsersLocalDataSourceImpl(
      hiveStorage: getIt<HiveStorageService>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<UsersRepository>(
    () => UsersRepositoryImpl(
      remoteDataSource: getIt<UsersRemoteDataSource>(),
      localDataSource: getIt<UsersLocalDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<GetUsersUseCase>(
    () => GetUsersUseCase(getIt<UsersRepository>()),
  );
  getIt.registerLazySingleton<GetUserByIdUseCase>(
    () => GetUserByIdUseCase(getIt<UsersRepository>()),
  );

  // BLoC
  getIt.registerFactory<UsersBloc>(
    () => UsersBloc(getUsersUseCase: getIt<GetUsersUseCase>()),
  );

  // ========== Posts Feature ==========

  // Data Sources
  getIt.registerLazySingleton<PostsRemoteDataSource>(
    () => PostsRemoteDataSourceImpl(getIt<HttpClientService>()),
  );
  getIt.registerLazySingleton<PostsLocalDataSource>(
    () => PostsLocalDataSourceImpl(
      hiveStorage: getIt<HiveStorageService>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<PostsRepository>(
    () => PostsRepositoryImpl(
      remoteDataSource: getIt<PostsRemoteDataSource>(),
      localDataSource: getIt<PostsLocalDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<GetPostsUseCase>(
    () => GetPostsUseCase(getIt<PostsRepository>()),
  );
  getIt.registerLazySingleton<GetPostByIdUseCase>(
    () => GetPostByIdUseCase(getIt<PostsRepository>()),
  );

  // BLoC
  getIt.registerFactory<PostsBloc>(
    () => PostsBloc(getPostsUseCase: getIt<GetPostsUseCase>()),
  );
  getIt.registerFactory<PostDetailBloc>(
    () => PostDetailBloc(getPostByIdUseCase: getIt<GetPostByIdUseCase>()),
  );

  // ========== Comments Feature ==========

  // Data Sources
  getIt.registerLazySingleton<CommentsRemoteDataSource>(
    () => CommentsRemoteDataSourceImpl(getIt<HttpClientService>()),
  );
  getIt.registerLazySingleton<CommentsLocalDataSource>(
    () => CommentsLocalDataSourceImpl(
      hiveStorage: getIt<HiveStorageService>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<CommentsRepository>(
    () => CommentsRepositoryImpl(
      remoteDataSource: getIt<CommentsRemoteDataSource>(),
      localDataSource: getIt<CommentsLocalDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<GetCommentsByPostIdUseCase>(
    () => GetCommentsByPostIdUseCase(getIt<CommentsRepository>()),
  );
  getIt.registerLazySingleton<CreateCommentUseCase>(
    () => CreateCommentUseCase(getIt<CommentsRepository>()),
  );

  // BLoC
  getIt.registerFactory<CommentsBloc>(
    () => CommentsBloc(
      getCommentsByPostIdUseCase: getIt<GetCommentsByPostIdUseCase>(),
      createCommentUseCase: getIt<CreateCommentUseCase>(),
    ),
  );

  // ========== Network Services ==========

  // Connectivity Service
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
}
