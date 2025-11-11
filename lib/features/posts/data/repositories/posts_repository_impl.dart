import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/data/repositories/base_repository.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/posts_local_data_source.dart';
import '../datasources/posts_remote_data_source.dart';
import '../models/post_model.dart';

class PostsRepositoryImpl with BaseRepository implements PostsRepository {
  final PostsRemoteDataSource remoteDataSource;
  final PostsLocalDataSource localDataSource;

  PostsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  ResultFuture<List<PostEntity>> getPosts() async {
    return handleException(() async {
      final connectivityService = di.getIt<ConnectivityService>();
      final isOnline =
          connectivityService.currentStatus == NetworkStatus.online;

      final cachedPosts = await localDataSource.getCachedPosts();
      if (cachedPosts != null && cachedPosts.isNotEmpty) {
        if (isOnline) {
          _refreshPostsInBackground();
        }
        return cachedPosts.map((model) => model.toEntity()).toList();
      }

      if (!isOnline) {
        throw Exception(
          'No internet connection. Please connect to the internet to load posts.',
        );
      }

      final remotePosts = await remoteDataSource.getPosts();
      await localDataSource.cachePosts(remotePosts);
      return remotePosts.map((model) => model.toEntity()).toList();
    });
  }

  @override
  ResultFuture<PostEntity> getPostById(int id) async {
    return handleException(() async {
      final cachedPost = await localDataSource.getCachedPost(id);
      if (cachedPost != null) {
        _refreshPostInBackground(id);
        return cachedPost.toEntity();
      }

      final remotePost = await remoteDataSource.getPostById(id);
      await localDataSource.cachePost(remotePost);
      return remotePost.toEntity();
    });
  }

  @override
  ResultFuture<List<PostEntity>> getPostsByUserId(int userId) async {
    return handleException(() async {
      final remotePosts = await remoteDataSource.getPostsByUserId(userId);
      await localDataSource.cachePosts(remotePosts);
      return remotePosts.map((model) => model.toEntity()).toList();
    });
  }

  @override
  ResultFuture<PostEntity> createPost(PostEntity post) async {
    return handleException(() async {
      final postModel = PostModel(
        id: post.id,
        userId: post.userId,
        title: post.title,
        body: post.body,
      );
      final createdPost = await remoteDataSource.createPost(postModel);
      await localDataSource.cachePost(createdPost);
      return createdPost.toEntity();
    });
  }

  @override
  ResultFuture<PostEntity> updatePost(PostEntity post) async {
    return handleException(() async {
      final postModel = PostModel(
        id: post.id,
        userId: post.userId,
        title: post.title,
        body: post.body,
      );
      final updatedPost = await remoteDataSource.updatePost(postModel);
      await localDataSource.cachePost(updatedPost);
      return updatedPost.toEntity();
    });
  }

  @override
  ResultFuture<void> deletePost(int id) async {
    return handleException(() async {
      await remoteDataSource.deletePost(id);
      // Optionally clear from cache
    });
  }

  /// Refresh posts in the background without blocking the UI
  Future<void> _refreshPostsInBackground() async {
    try {
      final connectivityService = di.getIt<ConnectivityService>();
      if (connectivityService.currentStatus == NetworkStatus.online) {
        final remotePosts = await remoteDataSource.getPosts();
        await localDataSource.cachePosts(remotePosts);
      }
    } catch (e) {
      // Log error but don't throw - background refresh failures shouldn't block UI
      AppLogger.w('Background posts refresh failed', e);
    }
  }

  /// Refresh a single post in the background without blocking the UI
  Future<void> _refreshPostInBackground(int id) async {
    try {
      final remotePost = await remoteDataSource.getPostById(id);
      await localDataSource.cachePost(remotePost);
    } catch (e) {
      // Log error but don't throw - background refresh failures shouldn't block UI
      AppLogger.w('Background post refresh failed for id $id', e);
    }
  }
}
