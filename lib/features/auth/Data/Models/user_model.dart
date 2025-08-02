import 'package:car_parking/features/auth/Domain/Entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
//required super.phoneNumber,
    //     required super.passwordHash,
    // required super.createdAt
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      //phoneNumber: json['phoneNumber'] as String,
      //   passwordHash: json['passwordHash'] as String,
      // createdAt: json['createdAt']
      //     as DateTime, //DateTime.parse(json['createdAt'] as String)
    );
  }
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      //  passwordHash: passwordHash,
      // phoneNumber: phoneNumber,
      //  createdAt: createdAt,
    );
  }
}
