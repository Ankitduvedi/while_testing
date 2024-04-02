import 'package:com.while.while_app/data/model/failure.dart';
import 'package:fpdart/fpdart.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;

typedef Futurevoid = FutureEither<void>;
