import 'package:car_parking/features/payment/Domain/repository/payment_reposiory.dart';
import 'package:dartz/dartz.dart';
import 'package:car_parking/Core/errors/Failure.dart';

class CheckBalanceSufficiencyUseCase {
  final PaymentRepository repository;

  CheckBalanceSufficiencyUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String userId,
    required double amount,
  }) async {
    return await repository.checkBalanceSufficiency(userId, amount);
  }
}
