import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/payment/Domain/repository/payment_reposiory.dart';
import 'package:dartz/dartz.dart';

class GetWalletBalanceUseCase {
  final PaymentRepository repository;

  GetWalletBalanceUseCase(this.repository);

  Future<Either<Failure, double>> call(String userId) async {
    return await repository.getWalletBalance(userId);
  }
}
