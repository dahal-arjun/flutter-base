import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/get_posts_usecase.dart';

part 'posts_event.dart';
part 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final GetPostsUseCase getPostsUseCase;

  PostsBloc({required this.getPostsUseCase}) : super(PostsInitial()) {
    on<GetPostsRequested>(_onGetPostsRequested);
    on<RefreshPostsRequested>(_onRefreshPostsRequested);
  }

  Future<void> _onGetPostsRequested(
    GetPostsRequested event,
    Emitter<PostsState> emit,
  ) async {
    emit(PostsLoading());

    final result = await getPostsUseCase(NoParams());

    result.fold(
      (failure) => emit(PostsError(failure.message)),
      (posts) => emit(PostsLoaded(posts)),
    );
  }

  Future<void> _onRefreshPostsRequested(
    RefreshPostsRequested event,
    Emitter<PostsState> emit,
  ) async {
    if (state is PostsLoaded) {
      emit(PostsRefreshing((state as PostsLoaded).posts));
    } else {
      emit(PostsLoading());
    }

    final result = await getPostsUseCase(NoParams());

    result.fold(
      (failure) => emit(PostsError(failure.message)),
      (posts) => emit(PostsLoaded(posts)),
    );
  }
}
