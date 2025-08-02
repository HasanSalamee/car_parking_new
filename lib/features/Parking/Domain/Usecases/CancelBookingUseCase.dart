import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/Parking/Domain/Repositories/Bookind_Reposiory.dart';
import 'package:dartz/dartz.dart';

class CancelBookingUseCase {
  final ParkingBookingRepository repository;

  CancelBookingUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String bookingId,
  }) async {
    return await repository.cancelBooking(bookingId);

    /* try {
      await repository.cancelBooking(bookingId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure("حدث خطأ في الخادم. الرجاء المحاولة لاحقاً"));
    }*/
  }
}
