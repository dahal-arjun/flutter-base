import '../../../../core/error/exceptions.dart';
import '../../../../shared/data/datasources/local_data_source.dart';
import '../models/post_model.dart';

abstract class PostsLocalDataSource {
  Future<void> cachePosts(List<PostModel> posts);
  Future<List<PostModel>?> getCachedPosts();
  Future<void> cachePost(PostModel post);
  Future<PostModel?> getCachedPost(int id);
  Future<void> clearCache();
}

class PostsLocalDataSourceImpl extends LocalDataSource
    implements PostsLocalDataSource {
  static const String _postsCacheKey = 'cached_posts';
  static const String _postCachePrefix = 'cached_post_';

  PostsLocalDataSourceImpl({
    required super.hiveStorage,
    required super.secureStorage,
  });

  /// Recursively converts Map with dynamic types to Map<String, dynamic>
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
  Future<void> cachePosts(List<PostModel> posts) async {
    try {
      final postsJson = posts.map((post) => post.toJson()).toList();
      await setHiveData(_postsCacheKey, postsJson);
      
      for (final post in posts) {
        await setHiveData('$_postCachePrefix${post.id}', post.toJson());
      }
    } catch (e) {
      throw CacheException('Failed to cache posts: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>?> getCachedPosts() async {
    try {
      final postsJson = getHiveData<List<dynamic>>(_postsCacheKey);
      if (postsJson != null) {
        return postsJson
            .map((json) {
              final postMap = json as Map;
              final convertedMap = _convertMap(postMap);
              return PostModel.fromJson(convertedMap);
            })
            .toList();
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached posts: ${e.toString()}');
    }
  }

  @override
  Future<void> cachePost(PostModel post) async {
    try {
      await setHiveData('$_postCachePrefix${post.id}', post.toJson());
    } catch (e) {
      throw CacheException('Failed to cache post: ${e.toString()}');
    }
  }

  @override
  Future<PostModel?> getCachedPost(int id) async {
    try {
      final postJson = getHiveData<Map>('$_postCachePrefix$id');
      if (postJson != null) {
        final convertedMap = _convertMap(postJson);
        return PostModel.fromJson(convertedMap);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached post: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await deleteHiveData(_postsCacheKey);
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }
}
