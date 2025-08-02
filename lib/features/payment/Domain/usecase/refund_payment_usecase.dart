import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/payment/Domain/entity/transaction_entity.dart';
import 'package:car_parking/features/payment/Domain/repository/payment_reposiory.dart';
import 'package:dartz/dartz.dart';

class RefundPaymentUseCase {
  final PaymentRepository repository;

  RefundPaymentUseCase(this.repository);

  Future<Either<Failure, TransactionEntity>> call({
    required String userId,
    required String bookingId,
  }) async {
    return repository.refundPayment(
      userId: userId,
      bookingId: bookingId,
    );
  }
}
