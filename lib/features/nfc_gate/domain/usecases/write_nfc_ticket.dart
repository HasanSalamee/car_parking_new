// write_ticket.dart
import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/nfc_gate/domain/entities/nfs_ticket.dart';
import 'package:car_parking/features/nfc_gate/domain/repositories/nfc_repository.dart';
import 'package:dartz/dartz.dart';

class WriteTicket {
  final NfcRepository repository;

  WriteTicket(this.repository);

  Future<Either<Failure, void>> call(NfcTicket ticket) async {
    try {
      await repository.writeTicketToNfc(ticket);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stackTrace) {
      return Left(UnknownFailure.fromError(e, stackTrace));
    }
  }
}
