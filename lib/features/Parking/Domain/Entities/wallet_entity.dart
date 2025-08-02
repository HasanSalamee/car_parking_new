import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String id;
  final double balance;
  final String userId;

  const Wallet({
    required this.id,
    required this.balance,
    required this.userId,
  });

  @override
  List<Object?> get props => [id, balance, userId];
}
