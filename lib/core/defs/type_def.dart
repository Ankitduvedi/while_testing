import 'package:com.example.while_app/core/failure.dart';
import 'package:fpdart/fpdart.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;

typedef Futurevoid = FutureEither<void>;
