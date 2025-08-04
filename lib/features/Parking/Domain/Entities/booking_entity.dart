import 'package:equatable/equatable.dart';

enum BookingStatus { pending, confirmed, canceled }

class BookingEntity extends Equatable {
  final String id;
  final DateTime start;
  final DateTime end;
  final String userId;
  final String garageId;

  const BookingEntity({
    required this.id,
    required this.start,
    required this.end,
    required this.userId,
    required this.garageId,
  });

  @override
  List<Object> get props => [
        id,
        start,
        end,
        userId,
        garageId,
      ];
}
