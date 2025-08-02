import 'package:car_parking/core/errors/failure.dart';
import 'package:car_parking/features/auth/Domain/Entities/token_entity.dart';
import 'package:car_parking/features/auth/Domain/Entities/user_entity.dart';
import 'package:car_parking/features/auth/Domain/Repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.getCurrentUser();
  }
}
