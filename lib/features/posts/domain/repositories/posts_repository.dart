import '../../../../core/utils/typedefs.dart';
import '../entities/post_entity.dart';

abstract class PostsRepository {
  ResultFuture<List<PostEntity>> getPosts();
  ResultFuture<PostEntity> getPostById(int id);
  ResultFuture<List<PostEntity>> getPostsByUserId(int userId);
  ResultFuture<PostEntity> createPost(PostEntity post);
  ResultFuture<PostEntity> updatePost(PostEntity post);
  ResultFuture<void> deletePost(int id);
}
