import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/Core/network/tok.dart';
import 'package:car_parking/features/payment/Data/models/transaction_model.dart';
import 'package:car_parking/features/payment/Domain/entity/transaction_entity.dart';
import 'package:dio/dio.dart';

abstract class PaymentRemoteDataSource {
  Future<TransactionModel> createPaymentTransaction({
    required String userId,
    required String bookingId,
    required double amount,
  });

  Future<TransactionEntity> createRefundTransaction({
    required String userId,
    required String bookingId,
    required double amount,
    required String originalTransactionId,
  });

  Future<void> updateBookingStatus(String bookingId, String status);
  Future<TransactionEntity> getTransaction(String transactionId);
  Future<List<TransactionEntity>> getUserTransactions({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<TransactionEntity>> getTransactionsByBooking({
    required String bookingId,
    String? type,
  });

  Future<double> getWalletBalance(String userId);
  Future<void> updateWalletBalance(String userId, double newBalance);
  Future<double> getWalletBalanceFromServer(String userId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;
  final HttpHeadersProvider headersProvider;
  PaymentRemoteDataSourceImpl(this.dio, this.headersProvider);

  @override
  Future<TransactionModel> createPaymentTransaction({
    required String userId,
    required String bookingId,
    required double amount,
  }) async {
    final response = await dio.post(
      'api/Payment/confirm',
      data: {
        'userId': userId,
        'bookingId': bookingId,
        'amount': amount,
      },
    );

    if (response.statusCode == 200) {
      return TransactionModel.fromJson(response.data);
    }
    print("HIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII");
    print(response.data);

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      error: 'Failed to create payment transaction',
    );
  }

  @override
  Future<TransactionEntity> createRefundTransaction({
    required String userId,
    required String bookingId,
    required double amount,
    required String originalTransactionId,
  }) async {
    try {
      final response = await dio.post(
        '/transactions/refund',
        data: {
          'userId': userId,
          'bookingId': bookingId,
          'amount': amount,
          'originalTransactionId': originalTransactionId,
          'type': 'refund',
        },
      );

      if (response.statusCode == 201) {
        return TransactionModel.fromJson(response.data).toEntity();
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Failed to create refund transaction',
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<TransactionEntity> getTransaction(String transactionId) async {
    try {
      final response = await dio.get(
        '/transactions/$transactionId',
        options: Options(
          validateStatus: (status) => status == 200 || status == 404,
        ),
      );

      if (response.statusCode == 200) {
        return TransactionModel.fromJson(response.data).toEntity();
      } else if (response.statusCode == 404) {
        throw Exception('Transaction not found');
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch transaction',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Transaction not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load transaction: ${e.toString()}');
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByBooking({
    required String bookingId,
    String? type,
  }) async {
    try {
      final response = await dio.get(
        '/bookings/transactions',
        queryParameters: type != null ? {'type': type} : null,
        options: Options(
          validateStatus: (status) => status == 200 || status == 404,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> transactionsJson = response.data as List;
        return transactionsJson
            .map((json) => TransactionModel.fromJson(json).toEntity())
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch booking transactions',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load booking transactions: ${e.toString()}');
    }
  }

//للتنفيذ
  @override
  Future<List<TransactionEntity>> getUserTransactions({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await dio.get(
        'api/Payment/history',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(
          validateStatus: (status) => status == 200 || status == 204,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> transactionsJson = response.data as List;
        return transactionsJson
            .map((json) => TransactionModel.fromJson(json).toEntity())
            .toList();
      } else if (response.statusCode == 204) {
        return [];
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch user transactions',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load user transactions: ${e.toString()}');
    }
  }

//
  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      final response = await dio.patch(
        '/bookings/status',
        data: {'status': status},
        options: Options(
          validateStatus: (status) =>
              status == 200 || status == 404 || status == 400,
        ),
      );

      switch (response.statusCode) {
        case 200:
          return;
        case 404:
          throw Exception('Booking not found');
        case 400:
          throw Exception('Invalid status: $status');
        default:
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: 'Failed to update booking status',
          );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Booking not found');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid status: $status');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to update booking status: ${e.toString()}');
    }
  }

//
  @override
  Future<double> getWalletBalance(String userId) async {
    final headers = await headersProvider.getAuthHeaders();

    try {
      final response = await dio.get(
        'api/wallet/my-wallet',
        options: Options(headers: headers),
      );

      return (response.data as num).toDouble();
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
  Future<double> getWalletBalanceFromServer(String userId) async {
    return getWalletBalance(userId);
  }

  @override
  Future<void> updateWalletBalance(String userId, double newBalance) async {
    try {
      await dio.put(
        'wallet/balance',
        data: {'balance': newBalance},
      );
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
}
