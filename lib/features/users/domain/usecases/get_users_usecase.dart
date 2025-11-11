import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/user_entity.dart';
import '../repositories/users_repository.dart';

class GetUsersUseCase implements UseCase<List<UserEntity>, NoParams> {
  final UsersRepository repository;

  GetUsersUseCase(this.repository);

  @override
  ResultFuture<List<UserEntity>> call(NoParams params) async {
    return await repository.getUsers();
  }
}

