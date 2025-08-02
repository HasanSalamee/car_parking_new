import 'package:car_parking/features/auth/Domain/Entities/token_entity.dart';

class TokenModel extends TokenEntity {
  const TokenModel({
    required super.id,
    required super.value,
    // required super.validFrom,
    //required super.validTo,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      id: json['id'] as String,
      value: json['value'] as String,
      //     validFrom: DateTime.parse(json['validFrom'] as String),
      //    validTo: DateTime.parse(json['validTo'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      //   'validFrom': validFrom.toIso8601String(),
      // 'validTo': validTo.toIso8601String(),
    };
  }

  TokenEntity toEntity() {
    return TokenEntity(
      id: id,
//      validFrom: validFrom,
      //    validTo: validTo,
      value: value,
    );
  }
}
