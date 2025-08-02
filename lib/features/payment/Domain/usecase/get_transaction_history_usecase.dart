import 'package:car_parking/features/payment/Domain/entity/transaction_entity.dart';
import 'package:car_parking/features/payment/Domain/repository/payment_reposiory.dart';
import 'package:dartz/dartz.dart';
import 'package:car_parking/Core/errors/Failure.dart';

class GetTransactionHistoryUseCase {
  final PaymentRepository repository;

  GetTransactionHistoryUseCase(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // التحقق من صحة المدخلات

    return await repository.getUserTransactions(
      userId: userId,
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
