// الـ Entity الأساسية للإشعارات (مطابقة لـ ERD + متطلبات النظام)
import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String notificationId;
  final String message;
  final String type; 
  final DateTime sentAt;
  final String userId; 
  final String? bookingId; 

  const NotificationEntity({
    required this.notificationId,
    required this.message,
    required this.type,
    required this.sentAt,
    required this.userId,
    this.bookingId,
  });

  @override
  List<Object?> get props =>
      [notificationId, message, type, sentAt, userId, bookingId];
}
