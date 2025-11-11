import '../../../../core/error/exceptions.dart';
import '../../../../shared/data/datasources/local_data_source.dart';
import '../models/comment_model.dart';

abstract class CommentsLocalDataSource {
  Future<void> cacheComments(List<CommentModel> comments);
  Future<List<CommentModel>?> getCachedComments();
  Future<void> cacheCommentsByPostId(int postId, List<CommentModel> comments);
  Future<List<CommentModel>?> getCachedCommentsByPostId(int postId);
  Future<void> clearCache();
}

class CommentsLocalDataSourceImpl extends LocalDataSource
    implements CommentsLocalDataSource {
  static const String _commentsCacheKey = 'cached_comments';
  static const String _commentsByPostPrefix = 'cached_comments_post_';

  CommentsLocalDataSourceImpl({
    required super.hiveStorage,
    required super.secureStorage,
  });

  Map<String, dynamic> _convertMap(Map map) {
    return Map<String, dynamic>.from(
      map.map((key, value) {
        if (value is Map) {
          return MapEntry(key.toString(), _convertMap(value));
        } else if (value is List) {
          return MapEntry(
            key.toString(),
            value.map((item) => item is Map ? _convertMap(item) : item).toList(),
          );
        } else {
          return MapEntry(key.toString(), value);
        }
      }),
    );
  }

  @override
  Future<void> cacheComments(List<CommentModel> comments) async {
    try {
      final commentsJson = comments.map((comment) => comment.toJson()).toList();
      await setHiveData(_commentsCacheKey, commentsJson);
    } catch (e) {
      throw CacheException('Failed to cache comments: ${e.toString()}');
    }
  }

  @override
  Future<List<CommentModel>?> getCachedComments() async {
    try {
      final commentsJson = getHiveData<List<dynamic>>(_commentsCacheKey);
      if (commentsJson != null) {
        return commentsJson
            .map((json) {
              final commentMap = json as Map;
              final convertedMap = _convertMap(commentMap);
              return CommentModel.fromJson(convertedMap);
            })
            .toList();
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached comments: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheCommentsByPostId(int postId, List<CommentModel> comments) async {
    try {
      final commentsJson = comments.map((comment) => comment.toJson()).toList();
      await setHiveData('$_commentsByPostPrefix$postId', commentsJson);
    } catch (e) {
      throw CacheException('Failed to cache comments by post: ${e.toString()}');
    }
  }

  @override
  Future<List<CommentModel>?> getCachedCommentsByPostId(int postId) async {
    try {
      final commentsJson = getHiveData<List<dynamic>>('$_commentsByPostPrefix$postId');
      if (commentsJson != null) {
        return commentsJson
            .map((json) {
              final commentMap = json as Map;
              final convertedMap = _convertMap(commentMap);
              return CommentModel.fromJson(convertedMap);
            })
            .toList();
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached comments by post: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await deleteHiveData(_commentsCacheKey);
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }
}

