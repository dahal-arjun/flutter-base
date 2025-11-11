import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// Type alias for Future<Either<Failure, T>>
/// Used for async operations that may fail
typedef ResultFuture<T> = Future<Either<Failure, T>>;

/// Type alias for Either<Failure, T>
/// Used for sync operations that may fail
typedef Result<T> = Either<Failure, T>;

/// Type alias for Future<Either<Failure, void>>
/// Used for async operations that don't return a value
typedef ResultVoid = ResultFuture<void>;
