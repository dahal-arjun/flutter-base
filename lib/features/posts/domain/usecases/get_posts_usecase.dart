import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/post_entity.dart';
import '../repositories/posts_repository.dart';

class GetPostsUseCase implements UseCase<List<PostEntity>, NoParams> {
  final PostsRepository repository;

  GetPostsUseCase(this.repository);

  @override
  ResultFuture<List<PostEntity>> call(NoParams params) async {
    return await repository.getPosts();
  }
}
