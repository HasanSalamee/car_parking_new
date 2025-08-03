import 'package:car_parking/features/Notification/Domain/Entity/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required String notificationId,
    required String message,
    required String type,
    required DateTime sentAt,
    required String userId,
    String? bookingId,
  }) : super(
          notificationId: notificationId,
          message: message,
          type: type,
          sentAt: sentAt,
          userId: userId,
          bookingId: bookingId,
        );

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      sentAt: DateTime.parse(json['sentAt']),
      userId: json['userId'] as String,
      bookingId: json['bookingId'],
    );
  }

  Map<String, dynamic> toEntity() {
    return {
      'notificationId': notificationId,
      'message': message,
      'type': type,
      'sentAt': sentAt.toIso8601String(),
      'userId': userId,
      'bookingId': bookingId,
    };
  }
}
