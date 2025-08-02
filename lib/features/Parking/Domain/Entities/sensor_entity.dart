import 'package:equatable/equatable.dart';

class SensorEntity extends Equatable {
  final String id;
  final String status;
  final String garageId;
  final String type;

  const SensorEntity({
    required this.id,
    required this.garageId,
    required this.type,
    required this.status,
  });

  @override
  List<Object> get props => [id, garageId, type, status];
}
