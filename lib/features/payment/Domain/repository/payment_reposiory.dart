import 'package:car_parking/features/payment/Domain/entity/transaction_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:car_parking/Core/errors/Failure.dart';

abstract class PaymentRepository {
  // Wallet Operations
  Future<Either<Failure, double>> getWalletBalance(String userId);
  Future<Either<Failure, void>> addFunds(String userId, double amount);

  // Transaction Operations
  Future<Either<Failure, TransactionEntity>> processPayment({
    required String userId,
    required String bookingId,
    required double amount,
  });

  Future<Either<Failure, TransactionEntity>> refundPayment({
    required String userId,
    required String bookingId,
  });

  // Verification
  Future<Either<Failure, TransactionEntity>> verifyPayment(String paymentId);

  // Booking Operations
  Future<Either<Failure, void>> updateBookingStatus({
    required String bookingId,
    required String status,
  });

  Future<Either<Failure, bool>> checkBalanceSufficiency(
      String userId, double amount);
  Future<Either<Failure, TransactionEntity>> getTransactionDetails(
      String transactionId);
  Future<Either<Failure, List<TransactionEntity>>> getUserTransactions({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<double> getWalletBalanceFromServer(String userId);

  Future<void> updateWalletBalanceOnServer(String userId, double newBalance);

  Future<double> fetchAndCacheWalletBalance(String userId);
}
