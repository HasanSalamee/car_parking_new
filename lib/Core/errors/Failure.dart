import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class OfflineFailure extends Failure {
  // ignore: use_super_parameters
  const OfflineFailure(String message) : super(message);
}

class ServerFailure extends Failure {
  // ignore: use_super_parameters
  const ServerFailure(String message) : super(message);

  static fromDioError(DioException e) {}
}

class WrongDataFailure extends Failure {
  // ignore: use_super_parameters
  const WrongDataFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  final int? statusCode;
  final String message1;
  const NetworkFailure({required this.message1, this.statusCode})
      : super(message1);

  @override
  List<Object?> get props => [message, statusCode];
}

// Custom failure for invalid time range
class InvalidTimeRangeFailure extends Failure {
  const InvalidTimeRangeFailure(
      [super.message = 'وقت الوصول يجب أن يكون قبل وقت المغادرة']);

  @override
  List<Object> get props => [message];
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  factory ServerException.fromDioError(DioException e) {
    return ServerException(
      message: e.response?.data['message'] ?? e.message ?? 'Server Error',
      statusCode: e.response?.statusCode,
    );
  }

  @override
  String toString() =>
      'ServerException: $message (${statusCode ?? 'No Status'})';
}

class UnknownFailure extends Failure {
  final dynamic error;

  UnknownFailure({
    String message = 'حدث خطأ غير معروف',
    this.error,
    StackTrace? stackTrace,
  }) : super(message);

  factory UnknownFailure.fromError(dynamic error, [StackTrace? stackTrace]) {
    return UnknownFailure(
      message: _getErrorMessage(error),
      error: error,
      stackTrace: stackTrace,
    );
  }

  get stackTrace => null;

  static String _getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Error) return error.toString();
    if (error is Exception) return error.toString();
    return 'حدث خطأ غير متوقع';
  }

  @override
  String toString() {
    return 'UnknownFailure: $message\nError: $error\nStackTrace: $stackTrace';
  }
}

class GarageNotAvailableFailure extends Failure {
  const GarageNotAvailableFailure([
    super.message = 'الموقف غير متاح في الوقت المحدد. الرجاء اختيار وقت آخر',
  ]);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'GarageNotAvailableFailure: $message';
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'خطأ في قاعدة البيانات']);

  @override
  List<Object> get props => [message];
}

Exception handleDioError(DioException e) {
  if (e.response?.statusCode == 404) {
    return Exception('Transaction not found');
  } else if (e.response?.statusCode == 400) {
    return Exception('Invalid refund request');
  } else {
    return Exception('Payment processing error: ${e.message}');
  }
}

class UnimplementedFailure extends Failure {
  const UnimplementedFailure([super.message = 'الميزة غير مدعومة حالياً']);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'UnimplementedFailure: $message';
}

class DatabaseException implements Exception {
  final String message;
  const DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}

class NfcFailure extends Failure {
  final String message;

  const NfcFailure({required this.message}) : super(message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'NfcFailure: $message';
}
