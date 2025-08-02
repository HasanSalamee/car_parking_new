import 'package:car_parking/core/errors/failure.dart';
import 'package:car_parking/features/auth/Domain/Entities/token_entity.dart';
import 'package:car_parking/features/auth/Domain/Entities/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> signup(
      {required String email, required String password});
  Future<Either<Failure, TokenEntity>> login(
      {required String email, required String password});
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, String>> getToken();
  Future<Either<Failure, Unit>> deleteToken();
  Future<Either<Failure, UserEntity>> getCurrentUser();
}
