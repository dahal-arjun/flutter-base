import '../../../../core/error/exceptions.dart';
import '../../../../shared/data/datasources/remote_data_source.dart';
import '../models/post_model.dart';

abstract class PostsRemoteDataSource {
  Future<List<PostModel>> getPosts();
  Future<PostModel> getPostById(int id);
  Future<List<PostModel>> getPostsByUserId(int userId);
  Future<PostModel> createPost(PostModel post);
  Future<PostModel> updatePost(PostModel post);
  Future<void> deletePost(int id);
}

class PostsRemoteDataSourceImpl extends RemoteDataSource
    implements PostsRemoteDataSource {
  PostsRemoteDataSourceImpl(super.httpClient);

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      final response = await get('/posts');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException('Failed to get posts');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error getting posts: ${e.toString()}');
    }
  }

  @override
  Future<PostModel> getPostById(int id) async {
    try {
      final response = await get('/posts/$id');
      if (response.statusCode == 200 && response.data != null) {
        return PostModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to get post');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error getting post: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>> getPostsByUserId(int userId) async {
    try {
      final response = await get('/posts', queryParameters: {'userId': userId});
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException('Failed to get posts by user');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error getting posts by user: ${e.toString()}');
    }
  }

  @override
  Future<PostModel> createPost(PostModel post) async {
    try {
      final response = await this.post('/posts', data: post.toJson());
      if (response.statusCode == 201 && response.data != null) {
        return PostModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to create post');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error creating post: ${e.toString()}');
    }
  }

  @override
  Future<PostModel> updatePost(PostModel post) async {
    try {
      final response = await put('/posts/${post.id}', data: post.toJson());
      if (response.statusCode == 200 && response.data != null) {
        return PostModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to update post');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error updating post: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePost(int id) async {
    try {
      final response = await delete('/posts/$id');
      if (response.statusCode != 200) {
        throw ServerException('Failed to delete post');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error deleting post: ${e.toString()}');
    }
  }
}
