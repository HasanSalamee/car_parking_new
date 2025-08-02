import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final String walletid;
  final double balance;
  final String userId;
  final DateTime lastUpdate;

  const WalletEntity(
      {required this.walletid,
      required this.balance,
      required this.userId,
      required this.lastUpdate});

  @override
  List<Object?> get props => [walletid, balance, userId, lastUpdate];
}
