import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/payment/Domain/repository/payment_reposiory.dart';
import 'package:dartz/dartz.dart';

class UpdateBookingStatusAfterPaymentUseCase {
  final PaymentRepository repository;

  UpdateBookingStatusAfterPaymentUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String bookingId,
    required String status,
  }) async {
    return repository.updateBookingStatus(
      bookingId: bookingId,
      status: status,
    );
  }
}
