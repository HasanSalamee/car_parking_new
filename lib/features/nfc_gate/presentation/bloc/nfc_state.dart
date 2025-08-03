import 'package:car_parking/features/nfc_gate/domain/entities/nfs_ticket.dart';
import 'package:equatable/equatable.dart';

abstract class NfcState extends Equatable {
  const NfcState();

  @override
  List<Object> get props => [];
}

class NfcInitial extends NfcState {}

class GeneratingTicket extends NfcState {}

class TicketGenerated extends NfcState {
  final NfcTicket ticket;

  const TicketGenerated(this.ticket);

  @override
  List<Object> get props => [ticket];
}

class WritingTicket extends NfcState {}

class TicketWritten extends NfcState {
  final String message;

  const TicketWritten(this.message);

  @override
  List<Object> get props => [message];
}

class SendingTicketViaBluetooth extends NfcState {}

class TicketSentViaBluetooth extends NfcState {
  final String message;

  const TicketSentViaBluetooth(this.message);

  @override
  List<Object> get props => [message];
}

class NfcError extends NfcState {
  final String error;

  const NfcError(this.error);

  @override
  List<Object> get props => [error];
}
