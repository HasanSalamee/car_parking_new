import 'package:car_parking/features/Parking/Domain/Entities/booking_entity.dart';
import 'package:car_parking/features/Parking/Domain/Entities/garage_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class ParkingBookingState extends Equatable {
  const ParkingBookingState();

  @override
  List<Object?> get props => [];
}

// الحالات الأساسية
class ParkingBookingInitial extends ParkingBookingState {}

class ParkingBookingLoading extends ParkingBookingState {
  final String message;

  const ParkingBookingLoading({this.message = 'جاري المعالجة...'});

  @override
  List<Object?> get props => [message];
}

class ParkingBookingError extends ParkingBookingState {
  final String error;

  const ParkingBookingError(this.error);

  @override
  List<Object?> get props => [error];
}

// حالات إدارة المواقف
class GaragesLoadedState extends ParkingBookingState {
  final List<GarageEntity> garages;
  final LatLng userLocation;

  const GaragesLoadedState({
    required this.garages,
    required this.userLocation,
  });

  @override
  List<Object?> get props => [garages, userLocation];
}

// حالات إدارة المواقف
class GaragesLoadedState1 extends ParkingBookingState {
  final List<GarageEntity> garages;
  final String city;

  const GaragesLoadedState1({
    required this.garages,
    required this.city,
  });

  @override
  List<Object?> get props => [garages, city];
}

class PriceCalculatedState extends ParkingBookingState {
  final double totalPrice;
  final double basePrice;
  final double taxes;

  const PriceCalculatedState({
    required this.totalPrice,
    required this.basePrice,
    required this.taxes,
  });

  @override
  List<Object?> get props => [totalPrice, basePrice, taxes];
}

// حالات إدارة الحجوزات
class GarageReservedState extends ParkingBookingState {
  final BookingEntity temporaryBooking;
  final Duration validFor;

  const GarageReservedState({
    required this.temporaryBooking,
    required this.validFor,
  });

  @override
  List<Object?> get props => [temporaryBooking, validFor];
}

class BookingConfirmedState extends ParkingBookingState {
  final BookingEntity confirmedBooking;

  const BookingConfirmedState({
    required this.confirmedBooking,
  });

  @override
  List<Object?> get props => [confirmedBooking];
}

class BookingCancelledState extends ParkingBookingState {
  final String bookingId;
  final double? refundAmount;

  const BookingCancelledState({
    required this.bookingId,
    this.refundAmount,
  });

  @override
  List<Object?> get props => [bookingId, refundAmount];
}

class BookingExtendedState extends ParkingBookingState {
  final BookingEntity updatedBooking;

  const BookingExtendedState({
    required this.updatedBooking,
  });

  @override
  List<Object?> get props => [updatedBooking];
}

class UserBookingsLoadedState extends ParkingBookingState {
  final List<BookingEntity> activeBookings;
  final List<BookingEntity> pastBookings;

  const UserBookingsLoadedState({
    required this.activeBookings,
    required this.pastBookings,
  });

  @override
  List<Object?> get props => [activeBookings, pastBookings];
}

// حالات التحقق والإشعارات
class ParkingValidatedState extends ParkingBookingState {
  final bool isValid;
  final String garageId;

  const ParkingValidatedState({
    required this.isValid,
    required this.garageId,
  });

  @override
  List<Object?> get props => [isValid, garageId];
}

class EarlyArrivalHandledState extends ParkingBookingState {
  final BookingEntity updatedBooking;
  final DateTime actualArrivalTime;

  const EarlyArrivalHandledState({
    required this.updatedBooking,
    required this.actualArrivalTime,
  });

  @override
  List<Object?> get props => [updatedBooking, actualArrivalTime];
}

class NotificationSentState extends ParkingBookingState {
  final String userId;
  final String notificationType;

  const NotificationSentState({
    required this.userId,
    required this.notificationType,
  });

  @override
  List<Object?> get props => [userId, notificationType];
}
