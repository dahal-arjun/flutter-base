part of 'posts_bloc.dart';

abstract class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object> get props => [];
}

class GetPostsRequested extends PostsEvent {
  const GetPostsRequested();
}

class RefreshPostsRequested extends PostsEvent {
  const RefreshPostsRequested();
}
