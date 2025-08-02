import 'package:car_parking/core/errors/failure.dart';
import 'package:car_parking/features/auth/Domain/Entities/user_entity.dart';
import 'package:car_parking/features/auth/Domain/Repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class SignupUseCase {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String email,
    required String password,
  }) async {
    return await repository.signup(email: email, password: password);
  }
}
