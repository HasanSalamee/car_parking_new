import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/Parking/Data/Models/booking_model.dart';
import 'package:car_parking/features/Parking/Domain/Entities/booking_entity.dart';
import 'package:car_parking/features/Parking/Domain/Entities/garage_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';

abstract class ParkingBookingRepository {
  Future<Either<Failure, List<GarageEntity>>> searchAvailableGarages({
    required DateTime arrivalTime,
    required DateTime departureTime,
    required LatLng userLocation,
    double? maxDistance,
  });
  Future<Either<Failure, List<GarageEntity>>> searchAvailableGarages1({
    required DateTime arrivalTime,
    required DateTime departureTime,
    required String city,
  });

  // إنشاء حجز جديد مع توليد التوكن
  // Future<Either<Failure, BookingEntity>> createBooking(BookingEntity booking);

  Future<Either<Failure, BookingModel>> createBooking(BookingModel booking);
  // التحقق من توفر الموقف (مثال)
  Future<bool> checkAvailability({
    required String garageId,
    required DateTime startTime,
    required DateTime endTime,
  });

  // (إضافي) تحديث حالة الحجز
  Future<Either<Failure, void>> updateBookingStatus({
    required String bookingId,
    required String status,
  });

  cancelBooking(String bookingId) {}

  Future<Either<Failure, BookingEntity>> confirmBooking(String bookingId);

  extendBooking(String bookingId, DateTime newEndTime) {}

  Future<Either<Failure, List<BookingEntity>>> getUserBookings(String userId);

  handleEarlyArrival(String bookingId, DateTime actualArrivalTime) {}

  sendNotification(
      {required String userId,
      required String message,
      required String notificationType}) {}

  validateParking({required String token, required String garageId}) {}
}
