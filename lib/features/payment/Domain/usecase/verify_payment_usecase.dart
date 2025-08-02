import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/payment/Domain/entity/transaction_entity.dart';
import 'package:car_parking/features/payment/Domain/repository/payment_reposiory.dart';
import 'package:dartz/dartz.dart';

class VerifyPaymentUseCase {
  final PaymentRepository repository;

  VerifyPaymentUseCase(this.repository);

  Future<Either<Failure, TransactionEntity>> call(String paymentId) async {
    return repository.verifyPayment(paymentId);
  }
}
