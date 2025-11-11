import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/post_entity.dart';
import '../repositories/posts_repository.dart';

class GetPostByIdUseCase implements UseCase<PostEntity, GetPostByIdParams> {
  final PostsRepository repository;

  GetPostByIdUseCase(this.repository);

  @override
  ResultFuture<PostEntity> call(GetPostByIdParams params) async {
    return await repository.getPostById(params.id);
  }
}

class GetPostByIdParams extends Equatable {
  final int id;

  const GetPostByIdParams({required this.id});

  @override
  List<Object> get props => [id];
}
