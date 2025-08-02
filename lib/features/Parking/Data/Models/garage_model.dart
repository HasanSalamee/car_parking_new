import 'package:car_parking/features/Parking/Domain/Entities/garage_entity.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GarageModel extends GarageEntity {
  const GarageModel({
    required super.id,
    required super.name,
    required super.location,
    required super.capacity,
    required super.pricePerHour,
    required super.area,
    required super.availableSpot,
  });

  factory GarageModel.fromJson(Map<String, dynamic> json) {
    return GarageModel(
        id: json['garageId'], // تحويل GUID إلى سلسلة نصية
        name: json['name'], // قيمة افتراضية في حالة null
        location: LatLng(
          (json['latitude'] as num?)?.toDouble() ?? 0.0, // تحويل وافتراضي
          (json['longitude'] as num?)?.toDouble() ?? 0.0, // تحويل وافتراضي
        ),
        capacity: (json['capacity'] as num?)?.toInt() ?? 0, // تحويل وافتراضي
        pricePerHour:
            (json['pricePerHour'] as num?)?.toInt() ?? 0, // تحويل وافتراضي
        area: (json['Area'] as num?)?.toString() ?? "",
        availableSpot: (json['AvailableSpot'] as num?)?.toInt() ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': {
        'lat': location.latitude,
        'lng': location.longitude,
      },
      'capacity': capacity,
      'pricePerHour': pricePerHour,
    };
  }

  @override
  GarageEntity toEntity() {
    return GarageEntity(
      id: id,
      name: name,
      location: location,
      capacity: capacity,
      pricePerHour: pricePerHour,
      area: area,
      availableSpot: availableSpot,
    );
  }
}
