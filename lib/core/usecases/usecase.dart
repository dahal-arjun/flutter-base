import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Base class for use cases (async)
/// Use cases represent single business operations
/// [T] - Return type
/// [Params] - Parameters type
abstract class UseCase<T, Params> {
  /// Execute the use case
  /// [params] - Parameters for the use case
  /// Returns Either<Failure, T>
  Future<Either<Failure, T>> call(Params params);
}

/// Base class for synchronous use cases
/// Use cases represent single business operations
/// [T] - Return type
/// [Params] - Parameters type
abstract class UseCaseSync<T, Params> {
  /// Execute the use case synchronously
  /// [params] - Parameters for the use case
  /// Returns Either<Failure, T>
  Either<Failure, T> call(Params params);
}

/// Empty parameters class for use cases that don't require parameters
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object> get props => [];
}
