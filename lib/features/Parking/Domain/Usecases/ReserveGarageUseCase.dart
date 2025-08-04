/*// في ملف ReserveGarageUseCase
import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/Parking/Data/Models/booking_model.dart';
import 'package:car_parking/features/Parking/Domain/Entities/booking_entity.dart';
import 'package:car_parking/features/Parking/Domain/Repositories/Bookind_Reposiory.dart';
import 'package:dartz/dartz.dart';

class ReserveGarageUseCase {
  final ParkingBookingRepository repository;

  ReserveGarageUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> call({
    required String garageId,
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      /*
      final isAvailable = await repository.checkAvailability(
        garageId: garageId,
        startTime: startTime,
        endTime: endTime,
      );*/
/*
      if (!isAvailable) {
        return Left(GarageNotAvailableFailure());
      }
*/
      final BookingEntity booking = BookingEntity(
        id: "", // سيتم تعبئته لاحقًا
        start: startTime,
        end: endTime,
        status: BookingStatus.pending,
        userId: userId,
        garageId: garageId,
      );

      return await repository.createBooking(booking);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}*/
// في ملف ReserveGarageUseCase
import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/Parking/Data/Models/booking_model.dart';
import 'package:car_parking/features/Parking/Domain/Entities/booking_entity.dart';
import 'package:car_parking/features/Parking/Domain/Repositories/Bookind_Reposiory.dart';
import 'package:dartz/dartz.dart';

class ReserveGarageUseCase {
  final ParkingBookingRepository repository;

  ReserveGarageUseCase(this.repository);

  Future<Either<Failure, BookingModel>> call({
    required String garageId,
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      /*
      final isAvailable = await repository.checkAvailability(
        garageId: garageId,
        startTime: startTime,
        endTime: endTime,
      );*/
/*
      if (!isAvailable) {
        return Left(GarageNotAvailableFailure());
      }
*/
      final BookingModel booking = BookingModel(
        id: "", // سيتم تعبئته لاحقًا
        start: startTime,
        end: endTime,
        userId: userId,
        garageId: garageId,
      );

      print(booking);

      return await repository.createBooking(booking);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
