import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/Parking/Data/Models/booking_model.dart';
import 'package:car_parking/features/Parking/Domain/Repositories/Bookind_Reposiory.dart';
import 'package:dartz/dartz.dart';

class ExtendBookingUseCase {
  final ParkingBookingRepository repository;

  ExtendBookingUseCase(this.repository);

  Future<Either<Failure, BookingModel>> call({
    required String bookingId,
    required DateTime newEndTime,
  }) async {
    return await repository.extendBooking(bookingId, newEndTime);
  }
}
