import '../../../../core/utils/typedefs.dart';
import '../entities/comment_entity.dart';

abstract class CommentsRepository {
  ResultFuture<List<CommentEntity>> getComments();
  ResultFuture<CommentEntity> getCommentById(int id);
  ResultFuture<List<CommentEntity>> getCommentsByPostId(int postId);
  ResultFuture<CommentEntity> createComment(CommentEntity comment);
}

