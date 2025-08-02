import 'package:car_parking/features/Parking/Domain/Entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.status,
    required super.start,
    required super.end,
    required super.userId,
    required super.garageId,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['bookingId'] as String,
      start: DateTime.parse(json['startTime'] as String),
      end: DateTime.parse(json['endTime'] as String),
      // start: json['start'] as DateTime,
      // end: json['end'] as DateTime,
      status: json['bookingStatus'] as BookingStatus,
      userId: json['userId'] as String,
      garageId: json['garageId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': id,
      'startTime': start.toIso8601String(), // تحويل DateTime لسلسلة نصية
      'endTime': end.toIso8601String(),
      'bookingStatus': status,
      'userId': userId,
      'garageId': garageId,
    };
  }

  BookingEntity toEntity() {
    return BookingEntity(
      id: id,
      start: start,
      end: end,
      status: status,
      userId: userId,
      garageId: garageId,
    );
  }
}
