import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/Parking/Domain/Entities/booking_entity.dart';
import 'package:car_parking/features/Parking/Domain/Repositories/Bookind_Reposiory.dart';
import 'package:dartz/dartz.dart';

class ConfirmBookingUseCase {
  final ParkingBookingRepository repository;

  ConfirmBookingUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> call(
      {required String bookingId}) async {
    return await repository.confirmBooking(bookingId);
  }
}
