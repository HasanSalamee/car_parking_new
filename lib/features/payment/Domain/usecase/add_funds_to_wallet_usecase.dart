import 'package:car_parking/features/payment/Domain/repository/payment_reposiory.dart';
import 'package:dartz/dartz.dart';
import 'package:car_parking/Core/errors/Failure.dart';

class AddFundsToWalletUseCase {
  final PaymentRepository repository;

  AddFundsToWalletUseCase({required this.repository});

  Future<Either<Failure, void>> call({
    required String userId,
    required double amount,
  }) async {
    return await repository.addFunds(userId, amount);
  }
}
