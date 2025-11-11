import '../../../../core/error/exceptions.dart';
import '../../../../shared/data/datasources/remote_data_source.dart';
import '../models/comment_model.dart';

abstract class CommentsRemoteDataSource {
  Future<List<CommentModel>> getComments();
  Future<CommentModel> getCommentById(int id);
  Future<List<CommentModel>> getCommentsByPostId(int postId);
  Future<CommentModel> createComment(CommentModel comment);
}

class CommentsRemoteDataSourceImpl extends RemoteDataSource
    implements CommentsRemoteDataSource {
  CommentsRemoteDataSourceImpl(super.httpClient);

  @override
  Future<List<CommentModel>> getComments() async {
    try {
      final response = await get('/comments');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => CommentModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Failed to get comments');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error getting comments: ${e.toString()}');
    }
  }

  @override
  Future<CommentModel> getCommentById(int id) async {
    try {
      final response = await get('/comments/$id');
      if (response.statusCode == 200 && response.data != null) {
        return CommentModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to get comment');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error getting comment: ${e.toString()}');
    }
  }

  @override
  Future<List<CommentModel>> getCommentsByPostId(int postId) async {
    try {
      final response = await get('/comments', queryParameters: {'postId': postId});
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => CommentModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Failed to get comments by post');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error getting comments by post: ${e.toString()}');
    }
  }

  @override
  Future<CommentModel> createComment(CommentModel comment) async {
    try {
      final response = await this.post('/comments', data: comment.toJson());
      if (response.statusCode == 201 && response.data != null) {
        return CommentModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to create comment');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error creating comment: ${e.toString()}');
    }
  }
}

