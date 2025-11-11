import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/get_post_by_id_usecase.dart';

part 'post_detail_event.dart';
part 'post_detail_state.dart';

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  final GetPostByIdUseCase getPostByIdUseCase;

  PostDetailBloc({required this.getPostByIdUseCase}) : super(PostDetailInitial()) {
    on<GetPostByIdRequested>(_onGetPostByIdRequested);
  }

  Future<void> _onGetPostByIdRequested(
    GetPostByIdRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    emit(PostDetailLoading());

    final result = await getPostByIdUseCase(
      GetPostByIdParams(id: event.postId),
    );

    result.fold(
      (failure) => emit(PostDetailError(failure.message)),
      (post) => emit(PostDetailLoaded(post)),
    );
  }
}
