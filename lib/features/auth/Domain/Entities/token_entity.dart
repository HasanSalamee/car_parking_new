import 'package:equatable/equatable.dart';

class TokenEntity extends Equatable {
  final String id;
  final String value;
//  final DateTime validFrom;
//  final DateTime validTo;

  const TokenEntity({
    required this.id,
    required this.value,
    //   required this.validFrom,
    // required this.validTo,
  });

  @override
  List<Object?> get props => [id, value, ];
}
