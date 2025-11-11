import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_users_usecase.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUsersUseCase getUsersUseCase;

  UsersBloc({required this.getUsersUseCase}) : super(UsersInitial()) {
    on<GetUsersRequested>(_onGetUsersRequested);
    on<RefreshUsersRequested>(_onRefreshUsersRequested);
  }

  Future<void> _onGetUsersRequested(
    GetUsersRequested event,
    Emitter<UsersState> emit,
  ) async {
    emit(UsersLoading());

    final result = await getUsersUseCase(NoParams());

    result.fold(
      (failure) => emit(UsersError(failure.message)),
      (users) => emit(UsersLoaded(users)),
    );
  }

  Future<void> _onRefreshUsersRequested(
    RefreshUsersRequested event,
    Emitter<UsersState> emit,
  ) async {
    if (state is UsersLoaded) {
      emit(UsersRefreshing((state as UsersLoaded).users));
    } else {
      emit(UsersLoading());
    }

    final result = await getUsersUseCase(NoParams());

    result.fold(
      (failure) => emit(UsersError(failure.message)),
      (users) => emit(UsersLoaded(users)),
    );
  }
}

