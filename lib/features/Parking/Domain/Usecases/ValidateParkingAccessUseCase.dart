import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/Parking/Domain/Repositories/Bookind_Reposiory.dart';
import 'package:dartz/dartz.dart';

class ValidateParkingUseCase {
  final ParkingBookingRepository repository;

  ValidateParkingUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String token,
    required String garageId,
  }) async {
    return await repository.validateParking(
      token: token,
      garageId: garageId,
    );
  }
}
