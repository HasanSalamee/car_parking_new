import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/Parking/Domain/Repositories/Bookind_Reposiory.dart';
import 'package:dartz/dartz.dart';

class SendNotificationUseCase {
  final ParkingBookingRepository repository;

  SendNotificationUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String userId,
    required String message,
    required String notificationType,
  }) async {
    return await repository.sendNotification(
      userId: userId,
      message: message,
      notificationType: notificationType,
    );
  }
}
