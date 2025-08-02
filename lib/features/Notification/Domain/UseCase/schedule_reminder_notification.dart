import 'package:car_parking/core/errors/failure.dart';
import 'package:car_parking/features/Notification/Domain/Repository/notification_repository.dart';
import 'package:dartz/dartz.dart';

class ScheduleReminderNotificationUseCase {
  final NotificationRepository repository;

  ScheduleReminderNotificationUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) {
    return repository.scheduleReminderNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
    );
  }
}
