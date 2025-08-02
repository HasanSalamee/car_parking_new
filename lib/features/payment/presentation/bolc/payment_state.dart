import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/payment/Domain/entity/transaction_entity.dart';
import 'package:equatable/equatable.dart';

abstract class PaymentWalletState extends Equatable {
  const PaymentWalletState();

  @override
  List<Object?> get props => [];
}

/// الحالة الابتدائية
class PaymentWalletInitial extends PaymentWalletState {}

/// جاري المعالجة العامة (مثل الدفع أو شحن المحفظة)
class PaymentWalletLoading extends PaymentWalletState {}

/// حالة التحميل مع وجود رصيد محفوظ مؤقتًا (للمحفظة)
class WalletLoadingWithCache extends PaymentWalletState {
  final double cachedBalance;

  const WalletLoadingWithCache(this.cachedBalance);

  @override
  List<Object?> get props => [cachedBalance];
}

/// تم تحميل رصيد المحفظة
class WalletLoaded extends PaymentWalletState {
  final double balance;
  final DateTime lastUpdated;

  const WalletLoaded(this.balance, this.lastUpdated);

  @override
  List<Object?> get props => [balance, lastUpdated];
}

/// تم إضافة أموال إلى المحفظة
class FundsAddedSuccess extends PaymentWalletState {
  final double newBalance;

  const FundsAddedSuccess(this.newBalance);

  @override
  List<Object?> get props => [newBalance];
}

/// نجاح عملية الدفع
class PaymentSuccess extends PaymentWalletState {
  final TransactionEntity transaction;

  const PaymentSuccess(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// تم تنفيذ استرداد مبلغ (refund)
class PaymentRefunded extends PaymentWalletState {
  final TransactionEntity refundTransaction;

  const PaymentRefunded(this.refundTransaction);

  @override
  List<Object?> get props => [refundTransaction];
}

/// تم تحميل عملية دفع معينة
class TransactionLoaded extends PaymentWalletState {
  final TransactionEntity transaction;

  const TransactionLoaded(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// تم تحميل سجل المعاملات
class TransactionHistoryLoaded extends PaymentWalletState {
  final List<TransactionEntity> transactions;

  const TransactionHistoryLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

/// حدث خطأ أثناء أي عملية
class PaymentWalletError extends PaymentWalletState {
  final Failure failure;

  const PaymentWalletError(this.failure);

  @override
  List<Object?> get props => [failure];
}
