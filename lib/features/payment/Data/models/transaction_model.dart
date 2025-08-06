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
      id: json['id']?.toString() ?? '', // مطلوب
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0, // مطلوب
      type: json['type']?.toString() ?? 'payment',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      walletId: json['walletId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      nfcTicket: NfcTicket(
        tokenId: json['tokenId']?.toString() ?? '',
        tokenValue: json['tokenValue']?.toString() ?? '',
        bookingId: json['bookingId']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        tokenValidFrom: json['tokenValidFrom'] != null
            ? DateTime.parse(json['tokenValidFrom'].toString())
            : DateTime.now(),
        tokenValidTo: json['tokenValidTo'] != null
            ? DateTime.parse(json['tokenValidTo'].toString())
            : DateTime.now().add(Duration(hours: 1)),
        isUsed: json['isUsed'] as bool? ?? false,
      ),
    );
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
