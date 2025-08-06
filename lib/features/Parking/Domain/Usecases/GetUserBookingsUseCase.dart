import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/Parking/Data/Models/booking_model.dart';
import 'package:car_parking/features/Parking/Domain/Entities/booking_entity.dart';
import 'package:car_parking/features/Parking/Domain/Repositories/Bookind_Reposiory.dart';
import 'package:dartz/dartz.dart';

class GetUserBookingsUseCase {
  final ParkingBookingRepository repository;

  GetUserBookingsUseCase(this.repository);

  Future<Either<Failure, List<BookingEntity>>> call({
    required String userId,
  }) async {
    return await repository.getUserBookings(userId);
  }
}
