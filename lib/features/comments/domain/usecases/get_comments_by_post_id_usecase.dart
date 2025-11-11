import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/comment_entity.dart';
import '../repositories/comments_repository.dart';

class GetCommentsByPostIdUseCase implements UseCase<List<CommentEntity>, GetCommentsByPostIdParams> {
  final CommentsRepository repository;

  GetCommentsByPostIdUseCase(this.repository);

  @override
  ResultFuture<List<CommentEntity>> call(GetCommentsByPostIdParams params) async {
    return await repository.getCommentsByPostId(params.postId);
  }
}

class GetCommentsByPostIdParams extends Equatable {
  final int postId;

  const GetCommentsByPostIdParams({required this.postId});

  @override
  List<Object> get props => [postId];
}

