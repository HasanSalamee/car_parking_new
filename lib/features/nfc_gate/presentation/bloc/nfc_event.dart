import 'package:car_parking/features/nfc_gate/domain/entities/nfs_ticket.dart';
import 'package:equatable/equatable.dart';

abstract class NfcEvent extends Equatable {
  const NfcEvent();

  @override
  List<Object> get props => [];
}

class GenerateNfcTicketEvent extends NfcEvent {
  final String bookingId;

  const GenerateNfcTicketEvent({
    required this.bookingId,
  });

  @override
  List<Object> get props => [bookingId];
}

class WriteNfcTicketEvent extends NfcEvent {
  final NfcTicket ticket;

  const WriteNfcTicketEvent(this.ticket);

  @override
  List<Object> get props => [ticket];
}

class SendTicketViaBluetoothEvent extends NfcEvent {
  final NfcTicket ticket;

  const SendTicketViaBluetoothEvent(this.ticket);

  @override
  List<Object> get props => [ticket];
}

class ResetNfcStateEvent extends NfcEvent {
  const ResetNfcStateEvent();
}
