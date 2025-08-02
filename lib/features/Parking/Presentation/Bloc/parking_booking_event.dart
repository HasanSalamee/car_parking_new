import 'package:car_parking/features/Parking/Domain/Entities/garage_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkingBookingEvent extends Equatable {
  const ParkingBookingEvent();
  @override
  List<Object?> get props => [];
}

// أحداث إدارة المواقف
class SearchGaragesEvent extends ParkingBookingEvent {
  final DateTime arrivalTime;
  final DateTime departureTime;
  final LatLng userLocation;
  final double? maxDistance;

  const SearchGaragesEvent({
    required this.arrivalTime,
    required this.departureTime,
    required this.userLocation,
    this.maxDistance,
  });
}

// أحداث إدارة المواقف
class SearchGaragesEvent1 extends ParkingBookingEvent {
  final DateTime arrivalTime;
  final DateTime departureTime;
  final String city;

  const SearchGaragesEvent1({
    required this.arrivalTime,
    required this.departureTime,
    required this.city,
  });

  @override
  List<Object?> get props =>
      [arrivalTime, departureTime, ];
}

class CalculatePriceEvent extends ParkingBookingEvent {
  final GarageEntity garage;
  final DateTime arrivalTime;
  final DateTime departureTime;

  const CalculatePriceEvent({
    required this.garage,
    required this.arrivalTime,
    required this.departureTime,
  });

  @override
  List<Object?> get props => [garage, arrivalTime, departureTime];
}

// أحداث إدارة الحجوزات
class ReserveGarageEvent extends ParkingBookingEvent {
  final String garageId;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;

  const ReserveGarageEvent({
    required this.garageId,
    required this.userId,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [garageId, userId, startTime, endTime];
}

class ConfirmBookingEvent extends ParkingBookingEvent {
  final String bookingId;

  const ConfirmBookingEvent({
    required this.bookingId,
  });

  @override
  List<Object?> get props => [bookingId];
}

class CancelBookingEvent extends ParkingBookingEvent {
  final String bookingId;

  const CancelBookingEvent({
    required this.bookingId,
  });

  @override
  List<Object?> get props => [bookingId];
}

class ExtendBookingEvent extends ParkingBookingEvent {
  final String bookingId;
  final DateTime newEndTime;

  const ExtendBookingEvent({
    required this.bookingId,
    required this.newEndTime,
  });

  @override
  List<Object?> get props => [bookingId, newEndTime];
}

class GetUserBookingsEvent extends ParkingBookingEvent {
  final String userId;

  const GetUserBookingsEvent({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId];
}

// أحداث التحقق والإشعارات
class ValidateParkingEvent extends ParkingBookingEvent {
  final String token;
  final String garageId;

  const ValidateParkingEvent({
    required this.token,
    required this.garageId,
  });

  @override
  List<Object?> get props => [token, garageId];
}

class HandleEarlyArrivalEvent extends ParkingBookingEvent {
  final String bookingId;
  final DateTime actualArrivalTime;

  const HandleEarlyArrivalEvent({
    required this.bookingId,
    required this.actualArrivalTime,
  });

  @override
  List<Object?> get props => [bookingId, actualArrivalTime];
}

class SendNotificationEvent extends ParkingBookingEvent {
  final String userId;
  final String message;
  final String notificationType;

  const SendNotificationEvent({
    required this.userId,
    required this.message,
    required this.notificationType,
  });

  @override
  List<Object?> get props => [userId, message, notificationType];
}
