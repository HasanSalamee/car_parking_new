import 'package:car_parking/features/Parking/Data/Models/booking_model.dart';
import 'package:car_parking/features/Parking/Domain/Entities/booking_entity.dart';
import 'package:car_parking/features/nfc_gate/domain/entities/nfs_ticket.dart';
import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final double amount;
  final String type;
  final String status;
  final DateTime createdAt;
  final String walletId;
  final BookingEntity booking;
  final NfcTicket nfcTicket;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.walletId,
    required this.booking,
    required this.nfcTicket,
  });

  @override
  List<Object> get props =>
      [id, amount, type, status, walletId, booking, createdAt];
}
