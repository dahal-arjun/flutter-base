part of 'users_bloc.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object> get props => [];
}

class GetUsersRequested extends UsersEvent {
  const GetUsersRequested();
}

class RefreshUsersRequested extends UsersEvent {
  const RefreshUsersRequested();
}

