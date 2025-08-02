import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GarageEntity extends Equatable {
  final String id;
  final String name;
  final LatLng location;
  final int capacity;
  final int pricePerHour;
  final String area;
  final int availableSpot;

  const GarageEntity({
    required this.id,
    required this.capacity,
    required this.location,
    required this.pricePerHour,
    required this.name,
    required this.area,
    required this.availableSpot,
  });

  @override
  List<Object> get props =>
      [id, capacity, location, pricePerHour, name, area, availableSpot];
}
