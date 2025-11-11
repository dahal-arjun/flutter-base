import 'package:equatable/equatable.dart';

/// Base class for all failure types
/// Failures represent error states in the domain layer
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure representing a server error
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Failure representing a cache operation error
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Failure representing a network connectivity error
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure representing a validation error
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Failure representing an authentication error
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}
