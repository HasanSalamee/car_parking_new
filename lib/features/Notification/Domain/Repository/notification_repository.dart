import 'package:car_parking/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

abstract class NotificationRepository {
  /* Future<Either<Failure, List<NotificationEntity>>> getNotifications(
    String userId, {
    bool? unreadOnly,
  });
*/
  // Future<Either<Failure, Unit>> deleteNotification(String notificationId);

  // Future<Either<Failure, Unit>> markAsRead(String notificationId);

  Future<Either<Failure, Unit>> scheduleReminderNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  });
}
