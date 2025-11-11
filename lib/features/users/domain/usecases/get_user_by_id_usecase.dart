import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/user_entity.dart';
import '../repositories/users_repository.dart';

class GetUserByIdUseCase implements UseCase<UserEntity, GetUserByIdParams> {
  final UsersRepository repository;

  GetUserByIdUseCase(this.repository);

  @override
  ResultFuture<UserEntity> call(GetUserByIdParams params) async {
    return await repository.getUserById(params.id);
  }
}

class GetUserByIdParams extends Equatable {
  final int id;

  const GetUserByIdParams({required this.id});

  @override
  List<Object> get props => [id];
}

