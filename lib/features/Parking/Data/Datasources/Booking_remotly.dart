import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/Parking/Data/Models/booking_model.dart';
import 'package:car_parking/features/Parking/Data/Models/garage_model.dart';
import 'package:car_parking/features/Parking/Domain/Entities/booking_entity.dart';
import 'package:car_parking/features/Parking/Domain/Entities/garage_entity.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class ParkingRemoteDataSource {
  Future<List<GarageEntity>> searchAvailableGarages({
    required DateTime arrivalTime,
    required DateTime departureTime,
    required LatLng userLocation,
  });
  Future<List<GarageEntity>> searchAvailableGarages1({
    required DateTime arrivalTime,
    required DateTime departureTime,
    required String city,
  });

  Future<BookingModel> createBooking(BookingEntity booking);
  Future<bool> checkAvailability({
    required String garageId,
    required DateTime startTime,
    required DateTime endTime,
  });
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  });
  Future<void> cancelBooking(String bookingId);
  Future<BookingEntity> confirmBooking(String bookingId);
  Future<BookingModel> extendBooking(String bookingId, DateTime newEndTime);
  Future<List<BookingModel>> getUserBookings();

  Future<void> sendNotification({
    required String userId,
    required String message,
    required String notificationType,
  });
  Future<bool> validateParking({
    required String token,
    required String garageId,
  });

  Future<BookingModel> handleEarlyArrival(
      String bookingId, DateTime actualArrivalTime);
}

class ParkingRemoteDataSourceImpl implements ParkingRemoteDataSource {
  final Dio dio;

  ParkingRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<GarageEntity>> searchAvailableGarages({
    required DateTime arrivalTime,
    required DateTime departureTime,
    required LatLng userLocation,
  }) async {
    try {
      final response = await dio.get('api/garages/available', queryParameters: {
        'arrivalTime': arrivalTime.toIso8601String(),
        'departureTime': departureTime.toIso8601String(),
        'userLat': userLocation.latitude,
        'userLon': userLocation.longitude,
      });

      return (response.data as List)
          .map((e) => GarageModel.fromJson(e).toEntity())
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }

  @override
  Future<List<GarageEntity>> searchAvailableGarages1({
    required DateTime arrivalTime,
    required DateTime departureTime,
    required String city, // تم استبدال LatLng بـ String للمدينة
  }) async {
    try {
      final response = await dio.get('api/Garage/search', queryParameters: {
        'arrivalTime': arrivalTime.toIso8601String(),
        'departureTime': departureTime.toIso8601String(),
        'city': city, // إرسال اسم المدينة بدلاً من الإحداثيات
      });
      print(response.data);

      return (response.data as List)
          .map((e) => GarageModel.fromJson(e).toEntity())
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }

  @override
  Future<BookingModel> createBooking(BookingEntity booking) async {
    try {
      // استخدام BookingModel مباشرة كما في الكود الأصلي
      final bookingModel = BookingModel(
        id: booking.id,
        start: booking.start,
        end: booking.end,
        status: booking.status,
        userId: booking.userId,
        garageId: booking.garageId,
      );

      final response = await dio.post(
        'api/booking/create',
        data: bookingModel.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 201) {
        return BookingModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Failed to create booking: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }
  

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      final response = await dio.delete(
        'api/booking/cancel/$bookingId',
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status == 200 || status == 404,
        ),
      );

      if (response.statusCode == 404) {
        throw ServerException(message: 'Booking not found', statusCode: 404);
      }
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }

  @override
  Future<List<BookingModel>> getUserBookings() async {
    try {
      final response = await dio.get(
        'api/Booking/my-bookings',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return (response.data as List)
          .map((e) => BookingModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }

  @override
  Future<bool> checkAvailability({
    required String garageId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final response = await dio.get(
        'garages/availability',
        queryParameters: {
          'garageId': garageId,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
        },
      );

      return response.data['isAvailable'] as bool;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return false;
      }
      throw ServerException.fromDioError(e);
    }
  }

  @override
  Future<BookingEntity> confirmBooking(String bookingId) async {
    try {
      final response = await dio.patch(
        '/bookings/$bookingId/confirm',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data).toEntity();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to confirm booking',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }

  ServerException _handleDioError(DioException e) {
    final errorData = e.response?.data as Map<String, dynamic>?;
    return ServerException(
      message: errorData?['message'] ?? 'Booking confirmation failed',
      statusCode: e.response?.statusCode,
    );
  }

  @override
  Future<BookingModel> extendBooking(
      String bookingId, DateTime newEndTime) async {
    try {
      final response = await dio.patch(
        'bookings/extend',
        data: {
          'new_end_time': newEndTime.toUtc().toIso8601String(),
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to extend booking',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleExtendError(e);
    }
  }

  ServerException _handleExtendError(DioException e) {
    final statusCode = e.response?.statusCode;
    final errorData = e.response?.data as Map<String, dynamic>?;

    String message = 'Booking extension failed';
    if (errorData?['message'] != null) {
      message = errorData!['message'];
    } else if (statusCode == 400) {
      message = 'Invalid extension time';
    } else if (statusCode == 409) {
      message = 'Time slot not available';
    }

    return ServerException(
      message: message,
      statusCode: statusCode,
    );
  }

  @override
  Future<void> sendNotification({
    required String userId,
    required String message,
    required String notificationType,
  }) async {
    try {
      final response = await dio.post(
        'notifications/send',
        data: {
          'user_id': userId,
          'message': message,
          'type': notificationType,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status == 200 || status == 202,
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 202) {
        throw ServerException(
          message: 'Failed to send notification',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleNotificationError(e);
    }
  }

  ServerException _handleNotificationError(DioException e) {
    final statusCode = e.response?.statusCode;
    final errorData = e.response?.data as Map<String, dynamic>?;

    String errorMessage = 'Notification sending failed';
    if (errorData?['error'] != null) {
      errorMessage = errorData!['error'];
    } else if (statusCode == 401) {
      errorMessage = 'Unauthorized to send notifications';
    } else if (statusCode == 429) {
      errorMessage = 'Too many notification requests';
    }

    return ServerException(
      message: errorMessage,
      statusCode: statusCode,
    );
  }

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      final response = await dio.patch(
        'bookings/status',
        data: {'status': status},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status == 200 || status == 204,
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: 'Failed to update booking status',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleStatusUpdateError(e, bookingId, status);
    }
  }

  ServerException _handleStatusUpdateError(
    DioException e,
    String bookingId,
    String status,
  ) {
    final statusCode = e.response?.statusCode;
    final errorData = e.response?.data as Map<String, dynamic>?;

    String errorMessage =
        'Failed to update booking $bookingId to status $status';
    if (errorData?['error'] != null) {
      errorMessage = errorData!['error'];
    } else if (statusCode == 400) {
      errorMessage = 'Invalid status transition';
    } else if (statusCode == 404) {
      errorMessage = 'Booking not found';
    } else if (statusCode == 409) {
      errorMessage = 'Conflict in booking status';
    }

    return ServerException(
      message: errorMessage,
      statusCode: statusCode,
    );
  }

  @override
  Future<bool> validateParking({
    required String token,
    required String garageId,
  }) async {
    try {
      final response = await dio.post(
        'parking/validate',
        data: {
          'token': token,
          'garage_id': garageId,
          'validation_time': DateTime.now().toUtc().toIso8601String(),
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) =>
              status == 200 || status == 400 || status == 403,
        ),
      );

      switch (response.statusCode) {
        case 200:
          return response.data['is_valid'] as bool;
        case 400:
          throw WrongDataFailure('Token غير صالح أو منتهي الصلاحية');
        case 403:
          throw WrongDataFailure('ليس لديك صلاحية للوصول لهذا الموقف');
        default:
          throw ServerFailure('فشل عملية التحقق من الصلاحية');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw OfflineFailure('لا يوجد اتصال بالإنترنت');
      }
      throw ServerFailure.fromDioError(e).message;
    } catch (e) {
      throw UnknownFailure.fromError(e);
    }
  }

  @override
  Future<BookingModel> handleEarlyArrival(
    String bookingId,
    DateTime actualArrivalTime,
  ) async {
    try {
      final response = await dio.patch(
        'api/booking/early-arrival/$bookingId',
        data: {
          'actualArrivalTime': actualArrivalTime.toUtc().toIso8601String(),
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      return BookingModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }
}
