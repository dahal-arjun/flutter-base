part of 'post_detail_bloc.dart';

abstract class PostDetailEvent extends Equatable {
  const PostDetailEvent();

  @override
  List<Object> get props => [];
}

class GetPostByIdRequested extends PostDetailEvent {
  final int postId;

  const GetPostByIdRequested(this.postId);

  @override
  List<Object> get props => [postId];
}
