import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/nfc_gate/domain/entities/nfs_ticket.dart';
import 'package:car_parking/features/nfc_gate/domain/repositories/nfc_repository.dart';
import 'package:dartz/dartz.dart';

class GenerateTicket {
  final NfcRepository repository;

  GenerateTicket(this.repository);

  Future<Either<Failure, NfcTicket>> call({
    required String bookingId,
  }) async {
    return await repository.generateTicket(
      bookingId: bookingId,
    );
  }
}
