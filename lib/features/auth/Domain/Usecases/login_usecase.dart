import 'package:car_parking/core/errors/failure.dart';
import 'package:car_parking/features/auth/Domain/Entities/token_entity.dart';
import 'package:car_parking/features/auth/Domain/Repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, TokenEntity>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }
}
