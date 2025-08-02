import 'package:car_parking/features/payment/Domain/entity/wallet_entity.dart';

class WalletModel extends WalletEntity {
  const WalletModel(
      {required super.walletid,
      required super.balance,
      required super.userId,
      required super.lastUpdate});

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      walletid: json['walletid'] as String,
      balance: json['balance'] as double,
      userId: json['userId'] as String,
      lastUpdate: json['lastUpdate'] as DateTime,
    );
  }

  WalletEntity toEntity() {
    return WalletEntity(
      walletid: walletid,
      balance: balance,
      userId: userId,
      lastUpdate: lastUpdate,
    );
  }
}
