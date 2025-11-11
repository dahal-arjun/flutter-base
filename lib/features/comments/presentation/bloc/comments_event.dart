part of 'comments_bloc.dart';

abstract class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object> get props => [];
}

class GetCommentsByPostIdRequested extends CommentsEvent {
  final int postId;

  const GetCommentsByPostIdRequested(this.postId);

  @override
  List<Object> get props => [postId];
}

class CreateCommentRequested extends CommentsEvent {
  final CommentEntity comment;

  const CreateCommentRequested(this.comment);

  @override
  List<Object> get props => [comment];
}

