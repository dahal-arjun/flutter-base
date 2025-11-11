import 'package:dartz/dartz.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';

/// Base repository mixin that provides exception handling
/// Converts exceptions to failures for use in the domain layer
/// All repository implementations should use this mixin
mixin BaseRepository {
  /// Handles exceptions and converts them to failures
  /// [call] - The function to execute that may throw exceptions
  /// Returns Either<Failure, T> where T is the expected return type
  Future<Either<Failure, T>> handleException<T>(
    Future<T> Function() call,
  ) async {
    try {
      final result = await call();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on Exception catch (e) {
      // Handle generic exceptions (like connectivity issues)
      final message = e.toString().replaceFirst('Exception: ', '');
      if (message.toLowerCase().contains('internet') ||
          message.toLowerCase().contains('connection') ||
          message.toLowerCase().contains('network')) {
        return Left(NetworkFailure(message));
      }
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
