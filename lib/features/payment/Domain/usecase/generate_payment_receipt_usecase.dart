import 'package:car_parking/features/payment/Domain/entity/transaction_entity.dart';
import 'package:car_parking/features/payment/Domain/repository/payment_reposiory.dart';
import 'package:dartz/dartz.dart';
import 'package:car_parking/Core/errors/Failure.dart';

class GeneratePaymentReceiptUseCase {
  final PaymentRepository repository;

  GeneratePaymentReceiptUseCase(this.repository);

  Future<Either<Failure, TransactionEntity>> call(String transactionId) async {
    return await repository.getTransactionDetails(transactionId);
  }
}
