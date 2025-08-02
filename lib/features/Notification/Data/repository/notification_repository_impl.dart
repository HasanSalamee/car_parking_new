import 'package:car_parking/core/errors/failure.dart';
import 'package:car_parking/features/Notification/Data/DataSources/notification_local_data_source.dart';
import 'package:car_parking/features/Notification/Domain/Repository/notification_repository.dart';
import 'package:dartz/dartz.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource localDataSource;

  NotificationRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Unit>> scheduleReminderNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      await localDataSource.scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
      );
      return Right(unit);
    } catch (e) {
      return Left(UnknownFailure.fromError(e));
    }
  }
}
