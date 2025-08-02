import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/nfc_gate/domain/entities/nfs_ticket.dart';
import 'package:dartz/dartz.dart';

abstract class NfcRepository {
  Future<Either<Failure, NfcTicket>> generateTicket({
    required String bookingId,
  });

  Future<Either<Failure, void>> writeTicketToNfc(NfcTicket ticket);

  Future<Either<Failure, bool>> validateAccess(NfcTicket ticket);

  Future<Either<Failure, NfcTicket?>> getCachedTicket();

  Future<Either<Failure, void>> clearCachedTicket();
  //New
  Future<Either<Failure, Unit>> sendTicketViaBluetooth(String ticketData);
}
