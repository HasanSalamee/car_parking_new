import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/Parking/Domain/Entities/garage_entity.dart';
import 'package:car_parking/features/Parking/Domain/Repositories/Bookind_Reposiory.dart';
import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchAvailableGaragesUseCase1 {
  final ParkingBookingRepository repository;

  SearchAvailableGaragesUseCase1(this.repository);

  Future<Either<Failure, List<GarageEntity>>> call({
    required DateTime arrivalTime,
    required DateTime departureTime,
    required String city,
  }) async {
    return await repository.searchAvailableGarages1(
      arrivalTime: arrivalTime,
      departureTime: departureTime,
      city: city,
    );
  }
}
