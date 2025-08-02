import 'package:equatable/equatable.dart';

// Unified Event for Payment + Wallet
sealed class PaymentWalletEvent extends Equatable {
  const PaymentWalletEvent();

  @override
  List<Object?> get props => [];
}

/// ====== 🟢 Events related to Payment ======

class ProcessPayment extends PaymentWalletEvent {
  final String userId;
  final String bookingId;
  final double amount;
  final String method;

  const ProcessPayment({
    required this.userId,
    required this.bookingId,
    required this.amount,
    required this.method,
  });

  @override
  List<Object?> get props => [userId, bookingId, amount, method];
}

class VerifyPayment extends PaymentWalletEvent {
  final String paymentId;

  const VerifyPayment(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

class RefundPayment extends PaymentWalletEvent {
  final String userId;
  final String bookingId;

  const RefundPayment(this.userId, this.bookingId);

  @override
  List<Object?> get props => [userId, bookingId];
}

class GetTransactionDetails extends PaymentWalletEvent {
  final String transactionId;

  const GetTransactionDetails(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

/// ====== 🟡 Events related to Wallet ======

class LoadWalletBalance extends PaymentWalletEvent {
  final String userId;

  const LoadWalletBalance(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddFundsToWallet extends PaymentWalletEvent {
  final String userId;
  final double amount;

  const AddFundsToWallet(this.userId, this.amount);

  @override
  List<Object?> get props => [userId, amount];
}

class RefreshWalletBalance extends PaymentWalletEvent {
  final String userId;

  const RefreshWalletBalance(this.userId);

  @override
  List<Object?> get props => [userId];
}

class FetchWalletBalance extends PaymentWalletEvent {
  final String userId;

  const FetchWalletBalance(this.userId);

  @override
  List<Object?> get props => [userId];
}

class GetTransactionHistory extends PaymentWalletEvent {
  final String userId;
  final int? limit;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetTransactionHistory({
    required this.userId,
    this.limit,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, limit, startDate, endDate];
}
