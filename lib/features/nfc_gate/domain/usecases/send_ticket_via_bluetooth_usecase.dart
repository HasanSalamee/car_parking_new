import 'package:dartz/dartz.dart';
import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/nfc_gate/domain/repositories/nfc_repository.dart';

class SendTicketViaBluetoothUseCase {
  final NfcRepository repository;

  SendTicketViaBluetoothUseCase(this.repository);

  Future<Either<Failure, void>> call(String ticketData) {
    return repository.sendTicketViaBluetooth(ticketData);
  }
}
