import 'package:car_parking/features/Parking/Data/Models/booking_model.dart';
import 'package:car_parking/features/nfc_gate/domain/entities/nfs_ticket.dart';
import 'package:car_parking/features/payment/Domain/entity/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.type,
    required super.status,
    required super.createdAt,
    required super.walletId,
    required String userId,
    required super.nfcTicket,
  }) : super(
            userId: userId); // نمرر الـ BookingModel لأنه يمتد من BookingEntity

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: json['type'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt']),
        walletId: json['walletId'] as String,
        userId: json['userId'] as String,
        nfcTicket: NfcTicket.fromJson(json['nfcTicket']));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'walletId': walletId,
      'bookingId': userId,
      'nfcTicket': (nfcTicket as NfcTicket).toJson(),
    };
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
        id: id,
        amount: amount,
        type: type,
        status: status,
        createdAt: createdAt,
        walletId: walletId,
        userId: userId,
        nfcTicket: nfcTicket);
  }
}
