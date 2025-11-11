import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/comment_entity.dart';
import '../repositories/comments_repository.dart';

class CreateCommentUseCase implements UseCase<CommentEntity, CreateCommentParams> {
  final CommentsRepository repository;

  CreateCommentUseCase(this.repository);

  @override
  ResultFuture<CommentEntity> call(CreateCommentParams params) async {
    return await repository.createComment(params.comment);
  }
}

class CreateCommentParams extends Equatable {
  final CommentEntity comment;

  const CreateCommentParams({required this.comment});

  @override
  List<Object> get props => [comment];
}

