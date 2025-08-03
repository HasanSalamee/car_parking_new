import 'package:car_parking/features/payment/Domain/entity/transaction_entity.dart';
import 'package:car_parking/features/payment/Domain/repository/payment_reposiory.dart';
import 'package:car_parking/features/payment/data/datasources/payment_local_datasource.dart';
import 'package:car_parking/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:car_parking/Core/errors/Failure.dart';
import 'package:dio/dio.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;
  final PaymentLocalDataSource localDataSource;

  PaymentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, double>> getWalletBalance(String userId) async {
    try {
      final balance = await remoteDataSource.getWalletBalance(userId);
      return Right(balance);
    } on DioException catch (e) {
      return Left(NetworkFailure(
        message1: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      ));
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    } catch (e) {
      return Left(UnknownFailure.fromError(e));
    }
  }

  @override
  Future<Either<Failure, void>> addFunds(String userId, double amount) async {
    try {
      if (amount <= 0) {
        return Left(WrongDataFailure('Amount must be greater than zero'));
      }

      await remoteDataSource.updateWalletBalance(userId, amount);
      return const Right(null);
    } on DioException catch (e) {
      return Left(NetworkFailure(
        message1: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      ));
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    } catch (e) {
      return Left(UnknownFailure.fromError(e));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> processPayment({
    required String userId,
    required String bookingId,
    required double amount,
  }) async {
    try {
      // 1. Check balance sufficiency
      final isSufficient = await checkBalanceSufficiency(userId, amount);
      if (isSufficient.isLeft() || !(isSufficient.getOrElse(() => false))) {
        return Left(GarageNotAvailableFailure('Insufficient balance'));
      }

      // 2. Deduct amount
  //  await remoteDataSource.updateWalletBalance(userId, -amount);

      // 3. Create transaction
      final transaction = await remoteDataSource.createPaymentTransaction(
        userId: userId,
        bookingId: bookingId,
        amount: amount,
      );

      // 4. Update booking status
      await updateBookingStatus(bookingId: bookingId, status: 'paid');

      return Right(transaction);
    } on DioException catch (e) {
      return Left(NetworkFailure(
        message1: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      ));
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    } catch (e) {
      return Left(UnknownFailure.fromError(e));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> refundPayment({
    required String userId,
    required String bookingId,
  }) async {
    try {
      // 1. Get original transaction
      final originalTransaction = await _getOriginalTransaction(bookingId);

      // 2. Add funds to wallet
      await addFunds(userId, originalTransaction.amount);

      // 3. Create refund transaction
      final refundTransaction = await remoteDataSource.createRefundTransaction(
        userId: userId,
        bookingId: bookingId,
        amount: originalTransaction.amount,
        originalTransactionId: originalTransaction.id,
      );

      // 4. Update booking status
      await updateBookingStatus(bookingId: bookingId, status: 'refunded');

      return Right(refundTransaction);
    } on DioException catch (e) {
      return Left(NetworkFailure(
        message1: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      ));
    } on Exception catch (e) {
      // تم استبدال DatabaseException
      return Left(DatabaseFailure(e.toString()));
    } catch (e) {
      return Left(UnknownFailure.fromError(e));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> verifyPayment(
      String paymentId) async {
    try {
      final transaction = await remoteDataSource.getTransaction(paymentId);

      if (transaction.status.toLowerCase() != 'success') {
        return Left(WrongDataFailure('Payment not verified'));
      }

      return Right(transaction);
    } on DioException catch (e) {
      return Left(NetworkFailure(
        message1: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      ));
    } on Exception catch (e) {
      // تم استبدال DatabaseException
      return Left(DatabaseFailure(e.toString()));
    } catch (e) {
      return Left(UnknownFailure.fromError(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      await remoteDataSource.updateBookingStatus(bookingId, status);
      return const Right(null);
    } on DioException catch (e) {
      return Left(NetworkFailure(
        message1: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      ));
    } on Exception catch (e) {
      // تم استبدال DatabaseException
      return Left(DatabaseFailure(e.toString()));
    } catch (e) {
      return Left(UnknownFailure.fromError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> checkBalanceSufficiency(
      String userId, double amount) async {
    try {
      final balance = await remoteDataSource.getWalletBalance(userId);
      return Right(balance >= amount);
    } on DioException catch (e) {
      return Left(NetworkFailure(
        message1: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      ));
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    } catch (e) {
      return Left(UnknownFailure.fromError(e));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransactionDetails(
      String transactionId) async {
    try {
      final transaction = await remoteDataSource.getTransaction(transactionId);
      return Right(transaction);
    } on DioException catch (e) {
      return Left(NetworkFailure(
        message1: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      ));
    } on Exception catch (e) {
      // تم استبدال DatabaseException
      return Left(DatabaseFailure(e.toString()));
    } catch (e) {
      return Left(UnknownFailure.fromError(e));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getUserTransactions({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final transactions = await remoteDataSource.getUserTransactions(
        userId: userId,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(transactions);
    } on DioException catch (e) {
      return Left(NetworkFailure(
        message1: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      ));
    } on Exception catch (e) {
      // تم استبدال DatabaseException
      return Left(DatabaseFailure(e.toString()));
    } catch (e) {
      return Left(UnknownFailure.fromError(e));
    }
  }

  // Helper method: Get original payment transaction
  Future<TransactionEntity> _getOriginalTransaction(String bookingId) async {
    try {
      final transactions = await remoteDataSource.getTransactionsByBooking(
        bookingId: bookingId,
        type: 'payment',
      );

      if (transactions.isEmpty) {
        throw Exception('Original payment not found');
      }

      return transactions.first;
    } on DioException catch (e) {
      throw NetworkFailure(
        message1: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } on Exception catch (e) {
      throw DatabaseFailure(e.toString());
    } catch (e) {
      throw UnknownFailure.fromError(e);
    }
  }

  @override
  Future<void> updateWalletBalanceOnServer(
      String userId, double newBalance) async {
    return remoteDataSource.updateWalletBalance(userId, newBalance);
  }

  @override
  Future<double> fetchAndCacheWalletBalance(String userId) async {
    try {
      final balance = await remoteDataSource.getWalletBalanceFromServer(userId);

      await localDataSource.cacheWalletBalance(userId, balance);

      return balance;
    } catch (e) {
      return localDataSource.getWalletBalanceForDisplay(userId);
    }
  }

  @override
  Future<double> getWalletBalanceFromServer(String userId) async {
    return await remoteDataSource.getWalletBalance(userId);
  }
}
