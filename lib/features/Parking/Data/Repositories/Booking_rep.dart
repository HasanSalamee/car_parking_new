import 'dart:io';
import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/Parking/Data/Datasources/Booking_remotly.dart';
import 'package:car_parking/features/Parking/Data/Models/booking_model.dart';
import 'package:car_parking/features/Parking/Domain/Entities/booking_entity.dart';
import 'package:car_parking/features/Parking/Domain/Entities/garage_entity.dart';
import 'package:car_parking/features/Parking/Domain/Repositories/Bookind_Reposiory.dart';
import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingParkingRepositoryImpl implements ParkingBookingRepository {
  final ParkingRemoteDataSource remoteDataSource;

  BookingParkingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<GarageEntity>>> searchAvailableGarages({
    required DateTime arrivalTime,
    required DateTime departureTime,
    required LatLng userLocation,
    double? maxDistance,
  }) async {
    try {
      final garages = await remoteDataSource.searchAvailableGarages(
        arrivalTime: arrivalTime,
        departureTime: departureTime,
        userLocation: userLocation,
      );
      return Right(garages);
    } on SocketException {
      return Left(NetworkFailure(message1: 'فشل الاتصال بالانترنت'));
    } on HttpException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<GarageEntity>>> searchAvailableGarages1({
    required DateTime arrivalTime,
    required DateTime departureTime,
    required String city,
  }) async {
    try {
      final garages = await remoteDataSource.searchAvailableGarages1(
        arrivalTime: arrivalTime,
        departureTime: departureTime,
        city: city,
      );
      return Right(garages);
    } on SocketException {
      return Left(NetworkFailure(message1: 'فشل الاتصال بالانترنت'));
    } on HttpException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> createBooking(
      BookingEntity booking) async {
    try {
      final createdBooking = await remoteDataSource.createBooking(booking);
      return Right(createdBooking.toEntity());
    } on SocketException {
      return Left(NetworkFailure(message1: 'فشل الاتصال بالانترنت'));
    } on HttpException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<bool> checkAvailability({
    required String garageId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      return await remoteDataSource.checkAvailability(
        garageId: garageId,
        startTime: startTime,
        endTime: endTime,
      );
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, void>> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      await remoteDataSource.updateBookingStatus(
        bookingId: bookingId,
        status: status,
      );
      return const Right(null);
    } on SocketException {
      return Left(NetworkFailure(message1: 'فشل الاتصال بالانترنت'));
    } on HttpException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking(String bookingId) async {
    try {
      await remoteDataSource.cancelBooking(bookingId);
      return const Right(null);
    } on SocketException {
      return Left(NetworkFailure(message1: 'فشل الاتصال بالانترنت'));
    } on HttpException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> confirmBooking(
      String bookingId) async {
    try {
      final booking = await remoteDataSource.confirmBooking(bookingId);
      return Right(booking);
    } on SocketException {
      return Left(NetworkFailure(message1: 'فشل الاتصال بالانترنت'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingModel>> extendBooking(
    String bookingId,
    DateTime newEndTime,
  ) async {
    try {
      final booking = await remoteDataSource.extendBooking(
        bookingId,
        newEndTime,
      );
      return Right(booking);
    } on SocketException {
      return Left(NetworkFailure(message1: 'فشل الاتصال بالانترنت'));
    } on HttpException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

/*
  @override
  Future<Either<Failure, List<BookingModel>>> getUserBookings(
      String userId) async {
    try {
      final bookings = await remoteDataSource.getUserBookings();
      return Right(bookings);
    } on SocketException {
      return Left(NetworkFailure(message1: 'فشل الاتصال بالانترنت'));
    } on HttpException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure());
    }
  }*/
//new after update
  @override
  Future<Either<Failure, List<BookingEntity>>> getUserBookings(
      String userId) async {
    try {
      final bookings = await remoteDataSource.getUserBookings();

      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfToday =
          DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

      final filteredBookings = bookings.where((booking) {
        final isActive = booking.end.isAfter(now);

        final endedToday = booking.end.isAfter(startOfToday) &&
            booking.end.isBefore(endOfToday);

        return isActive || endedToday;
      }).toList();

      return Right(filteredBookings);
    } on SocketException {
      return Left(NetworkFailure(message1: 'فشل الاتصال بالانترنت'));
    } on HttpException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, BookingModel>> handleEarlyArrival(
    String bookingId,
    DateTime actualArrivalTime,
  ) async {
    try {
      final booking = await remoteDataSource.handleEarlyArrival(
        bookingId,
        actualArrivalTime,
      );
      return Right(booking);
    } on SocketException {
      return Left(NetworkFailure(message1: 'فشل الاتصال بالانترنت'));
    } on HttpException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> sendNotification({
    required String userId,
    required String message,
    required String notificationType,
  }) async {
    try {
      await remoteDataSource.sendNotification(
        userId: userId,
        message: message,
        notificationType: notificationType,
      );
      return const Right(null);
    } on SocketException {
      return Left(NetworkFailure(message1: 'فشل الاتصال بالانترنت'));
    } on HttpException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> validateParking({
    required String token,
    required String garageId,
  }) async {
    try {
      final isValid = await remoteDataSource.validateParking(
        token: token,
        garageId: garageId,
      );
      return Right(isValid);
    } on SocketException {
      return Left(NetworkFailure(message1: 'فشل الاتصال بالانترنت'));
    } on HttpException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure());
    }
  }
}
