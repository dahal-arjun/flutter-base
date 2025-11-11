import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/comment_entity.dart';
import '../../domain/usecases/get_comments_by_post_id_usecase.dart';
import '../../domain/usecases/create_comment_usecase.dart';

part 'comments_event.dart';
part 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final GetCommentsByPostIdUseCase getCommentsByPostIdUseCase;
  final CreateCommentUseCase createCommentUseCase;

  CommentsBloc({
    required this.getCommentsByPostIdUseCase,
    required this.createCommentUseCase,
  }) : super(CommentsInitial()) {
    on<GetCommentsByPostIdRequested>(_onGetCommentsByPostIdRequested);
    on<CreateCommentRequested>(_onCreateCommentRequested);
  }

  Future<void> _onGetCommentsByPostIdRequested(
    GetCommentsByPostIdRequested event,
    Emitter<CommentsState> emit,
  ) async {
    emit(CommentsLoading());

    final result = await getCommentsByPostIdUseCase(
      GetCommentsByPostIdParams(postId: event.postId),
    );

    result.fold(
      (failure) => emit(CommentsError(failure.message)),
      (comments) => emit(CommentsLoaded(comments)),
    );
  }

  Future<void> _onCreateCommentRequested(
    CreateCommentRequested event,
    Emitter<CommentsState> emit,
  ) async {
    // Save previous comments if available
    List<CommentEntity>? previousComments;
    if (state is CommentsLoaded) {
      previousComments = (state as CommentsLoaded).comments;
      emit(CommentsCreating(previousComments));
    } else if (state is CommentsCreating) {
      previousComments = (state as CommentsCreating).comments;
    }

    final result = await createCommentUseCase(
      CreateCommentParams(comment: event.comment),
    );

    result.fold(
      (failure) {
        // Restore previous state on error
        if (previousComments != null) {
          emit(CommentsLoaded(previousComments));
        } else {
          emit(CommentsError(failure.message));
        }
      },
      (createdComment) {
        // Refresh comments after successful creation
        add(GetCommentsByPostIdRequested(event.comment.postId));
      },
    );
  }
}

