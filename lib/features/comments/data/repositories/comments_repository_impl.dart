import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/data/repositories/base_repository.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comments_repository.dart';
import '../datasources/comments_local_data_source.dart';
import '../datasources/comments_remote_data_source.dart';
import '../models/comment_model.dart';

class CommentsRepositoryImpl with BaseRepository implements CommentsRepository {
  final CommentsRemoteDataSource remoteDataSource;
  final CommentsLocalDataSource localDataSource;

  CommentsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  ResultFuture<List<CommentEntity>> getComments() async {
    return handleException(() async {
      final connectivityService = di.getIt<ConnectivityService>();
      final isOnline =
          connectivityService.currentStatus == NetworkStatus.online;

      final cachedComments = await localDataSource.getCachedComments();
      if (cachedComments != null && cachedComments.isNotEmpty) {
        if (isOnline) {
          _refreshCommentsInBackground();
        }
        return cachedComments.map((model) => model.toEntity()).toList();
      }

      if (!isOnline) {
        throw Exception(
          'No internet connection. Please connect to the internet to load comments.',
        );
      }

      final remoteComments = await remoteDataSource.getComments();
      await localDataSource.cacheComments(remoteComments);
      return remoteComments.map((model) => model.toEntity()).toList();
    });
  }

  @override
  ResultFuture<CommentEntity> getCommentById(int id) async {
    return handleException(() async {
      final remoteComment = await remoteDataSource.getCommentById(id);
      return remoteComment.toEntity();
    });
  }

  @override
  ResultFuture<List<CommentEntity>> getCommentsByPostId(int postId) async {
    return handleException(() async {
      final connectivityService = di.getIt<ConnectivityService>();
      final isOnline =
          connectivityService.currentStatus == NetworkStatus.online;

      final cachedComments = await localDataSource.getCachedCommentsByPostId(postId);
      if (cachedComments != null && cachedComments.isNotEmpty) {
        if (isOnline) {
          _refreshCommentsByPostInBackground(postId);
        }
        return cachedComments.map((model) => model.toEntity()).toList();
      }

      if (!isOnline) {
        throw Exception(
          'No internet connection. Please connect to the internet to load comments.',
        );
      }

      final remoteComments = await remoteDataSource.getCommentsByPostId(postId);
      await localDataSource.cacheCommentsByPostId(postId, remoteComments);
      return remoteComments.map((model) => model.toEntity()).toList();
    });
  }

  /// Refresh comments in the background without blocking the UI
  Future<void> _refreshCommentsInBackground() async {
    try {
      final connectivityService = di.getIt<ConnectivityService>();
      if (connectivityService.currentStatus == NetworkStatus.online) {
        final remoteComments = await remoteDataSource.getComments();
        await localDataSource.cacheComments(remoteComments);
      }
    } catch (e) {
      // Log error but don't throw - background refresh failures shouldn't block UI
      AppLogger.w('Background comments refresh failed', e);
    }
  }

  /// Refresh comments for a specific post in the background without blocking the UI
  Future<void> _refreshCommentsByPostInBackground(int postId) async {
    try {
      final connectivityService = di.getIt<ConnectivityService>();
      if (connectivityService.currentStatus == NetworkStatus.online) {
        final remoteComments = await remoteDataSource.getCommentsByPostId(postId);
        await localDataSource.cacheCommentsByPostId(postId, remoteComments);
      }
    } catch (e) {
      // Log error but don't throw - background refresh failures shouldn't block UI
      AppLogger.w('Background comments refresh failed for post $postId', e);
    }
  }

  @override
  ResultFuture<CommentEntity> createComment(CommentEntity comment) async {
    return handleException(() async {
      final commentModel = CommentModel(
        id: comment.id,
        postId: comment.postId,
        name: comment.name,
        email: comment.email,
        body: comment.body,
      );
      final createdComment = await remoteDataSource.createComment(commentModel);
      // Refresh comments for this post
      await localDataSource.cacheCommentsByPostId(
        comment.postId,
        await remoteDataSource.getCommentsByPostId(comment.postId),
      );
      return createdComment.toEntity();
    });
  }
}

