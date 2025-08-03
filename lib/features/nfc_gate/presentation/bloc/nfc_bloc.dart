import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:car_parking/features/nfc_gate/data/repositories/nfc_repository_impl.dart';
import 'package:car_parking/features/nfc_gate/domain/entities/nfs_ticket.dart';
import 'package:car_parking/features/nfc_gate/domain/repositories/nfc_repository.dart';
import 'package:car_parking/features/nfc_gate/domain/usecases/generate_ticket.dart';
import 'package:car_parking/features/nfc_gate/domain/usecases/write_nfc_ticket.dart';
import 'package:car_parking/features/nfc_gate/domain/usecases/send_ticket_via_bluetooth_usecase.dart'; // استيراد جديد
import 'package:car_parking/features/nfc_gate/presentation/bloc/nfc_event.dart';
import 'package:car_parking/features/nfc_gate/presentation/bloc/nfc_state.dart';

class NfcBloc extends Bloc<NfcEvent, NfcState> {
  final NfcRepository repository;

  NfcBloc(this.repository) : super(NfcInitial()) {
    on<GenerateNfcTicketEvent>(_onGenerateTicket);
    on<WriteNfcTicketEvent>(_onWriteTicket);
    on<SendTicketViaBluetoothEvent>(_onSendTicketViaBluetooth); // إضافة
    on<ResetNfcStateEvent>(_onResetState);
  }

  Future<void> _onGenerateTicket(
    GenerateNfcTicketEvent event,
    Emitter<NfcState> emit,
  ) async {
    emit(GeneratingTicket());

    final result = await GenerateTicket(repository)(bookingId: event.bookingId);

    result.fold(
      (failure) => emit(NfcError(failure.message)),
      (ticket) => emit(TicketGenerated(ticket)),
    );
  }

  Future<void> _onWriteTicket(
    WriteNfcTicketEvent event,
    Emitter<NfcState> emit,
  ) async {
    emit(WritingTicket());

    final result = await WriteTicket(repository)(event.ticket);

    result.fold(
      (failure) => emit(NfcError(failure.message)),
      (_) => emit(TicketWritten('تمت الكتابة على البطاقة بنجاح!')),
    );
  }

  Future<void> _onSendTicketViaBluetooth(
    SendTicketViaBluetoothEvent event,
    Emitter<NfcState> emit,
  ) async {
    emit(SendingTicketViaBluetooth());

    final ticketData = _serializeTicket(event.ticket);

    final result = await SendTicketViaBluetoothUseCase(repository)(ticketData);

    result.fold(
      (failure) => emit(NfcError(failure.message)),
      (_) =>
          emit(TicketSentViaBluetooth('تم إرسال التذكرة عبر البلوتوث بنجاح!')),
    );
  }

  void _onResetState(
    ResetNfcStateEvent event,
    Emitter<NfcState> emit,
  ) {
    emit(NfcInitial());
  }

  String _serializeTicket(NfcTicket ticket) {
    return '${ticket.id}|${ticket.token}|${ticket.bookingId}|'
        '${ticket.userId}|'
        '${ticket.validFrom.toIso8601String()}|'
        '${ticket.validTo.toIso8601String()}|'
        '${ticket.isUsed}';
  }
}
