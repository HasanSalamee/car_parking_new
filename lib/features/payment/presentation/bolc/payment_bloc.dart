import 'package:car_parking/features/payment/Domain/usecase/add_funds_to_wallet_usecase.dart';
import 'package:car_parking/features/payment/Domain/usecase/generate_payment_receipt_usecase.dart';
import 'package:car_parking/features/payment/Domain/usecase/get_transaction_history_usecase.dart';
import 'package:car_parking/features/payment/Domain/usecase/get_wallet_balance_usecase.dart';
import 'package:car_parking/features/payment/Domain/usecase/process_payment_usecase.dart';
import 'package:car_parking/features/payment/Domain/usecase/refund_payment_usecase.dart';
import 'package:car_parking/features/payment/Domain/usecase/verify_payment_usecase.dart';
import 'package:car_parking/features/payment/presentation/bolc/payment_event.dart';
import 'package:car_parking/features/payment/presentation/bolc/payment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/payment/Domain/repository/payment_reposiory.dart';

class PaymentWalletBloc extends Bloc<PaymentWalletEvent, PaymentWalletState> {
  final PaymentRepository repository;

  PaymentWalletBloc({required this.repository})
      : super(PaymentWalletInitial()) {
    // Payment events
    on<ProcessPayment>(_onProcessPayment);
    on<VerifyPayment>(_onVerifyPayment);
    on<RefundPayment>(_onRefundPayment);
    on<GetTransactionDetails>(_onGetTransactionDetails);
    // Wallet events
    on<LoadWalletBalance>(_onLoadWalletBalance);
    on<AddFundsToWallet>(_onAddFundsToWallet);
    on<RefreshWalletBalance>(_onRefreshWalletBalance);
    on<FetchWalletBalance>(_onFetchWalletBalance);
    // Transaction history event
    on<GetTransactionHistory>(_onGetTransactionHistory); 
  }

  Future<void> _onProcessPayment(
    ProcessPayment event,
    Emitter<PaymentWalletState> emit,
  ) async {
    emit(PaymentWalletLoading());
    final result = await ProcessPaymentUseCase(repository)(
      userId: event.userId,
      bookingId: event.bookingId,
      amount: event.amount,
    );
    result.fold(
      (failure) => emit(PaymentWalletError(failure)),
      (transaction) => emit(PaymentSuccess(transaction)),
    );
  }

  Future<void> _onVerifyPayment(
    VerifyPayment event,
    Emitter<PaymentWalletState> emit,
  ) async {
    emit(PaymentWalletLoading());
    final result = await VerifyPaymentUseCase(repository)(event.paymentId);
    result.fold(
      (failure) => emit(PaymentWalletError(failure)),
      (transaction) => emit(PaymentSuccess(transaction)),
    );
  }

  Future<void> _onRefundPayment(
    RefundPayment event,
    Emitter<PaymentWalletState> emit,
  ) async {
    emit(PaymentWalletLoading());
    final result = await RefundPaymentUseCase(repository)(
      userId: event.userId,
      bookingId: event.bookingId,
    );
    result.fold(
      (failure) => emit(PaymentWalletError(failure)),
      (transaction) => emit(PaymentRefunded(transaction)),
    );
  }

  Future<void> _onGetTransactionDetails(
    GetTransactionDetails event,
    Emitter<PaymentWalletState> emit,
  ) async {
    emit(PaymentWalletLoading());
    final result =
        await GeneratePaymentReceiptUseCase(repository)(event.transactionId);
    result.fold(
      (failure) => emit(PaymentWalletError(failure)),
      (transaction) => emit(TransactionLoaded(transaction)),
    );
  }

  Future<void> _onLoadWalletBalance(
    LoadWalletBalance event,
    Emitter<PaymentWalletState> emit,
  ) async {
    emit(PaymentWalletLoading());
    final result = await GetWalletBalanceUseCase(repository)(event.userId);
    _handleWalletResult(result as Either<Failure, double>, emit);
  }

  Future<void> _onAddFundsToWallet(
    AddFundsToWallet event,
    Emitter<PaymentWalletState> emit,
  ) async {
    emit(PaymentWalletLoading());
    final result = await AddFundsToWalletUseCase(repository: repository)(
        amount: event.amount, userId: event.userId);
    result.fold(
      (failure) => emit(PaymentWalletError(failure)),
      (_) async {
        final balanceResult = await repository.getWalletBalance(event.userId);
        balanceResult.fold(
          (failure) => emit(PaymentWalletError(failure)),
          (balance) => emit(FundsAddedSuccess(balance)),
        );
      },
    );
  }

  Future<void> _onFetchWalletBalance(
    FetchWalletBalance event,
    Emitter<PaymentWalletState> emit,
  ) async {
    emit(PaymentWalletLoading());
    final result = await GetWalletBalanceUseCase(repository)(event.userId);
    _handleWalletResult(result, emit);
  }

  Future<void> _onRefreshWalletBalance(
    RefreshWalletBalance event,
    Emitter<PaymentWalletState> emit,
  ) async {
    final currentState = state;
    if (currentState is WalletLoaded) {
      emit(WalletLoadingWithCache(currentState.balance));
    } else {
      emit(PaymentWalletLoading());
    }
    final result = await repository.getWalletBalance(event.userId);
    _handleWalletResult(result, emit);
  }

  Future<void> _onGetTransactionHistory(
    GetTransactionHistory event,
    Emitter<PaymentWalletState> emit,
  ) async {
    emit(PaymentWalletLoading());
    final result = await GetTransactionHistoryUseCase(repository)(
      userId: event.userId,
      limit: event.limit,
      startDate: event.startDate,
      endDate: event.endDate,
    );
    result.fold(
      (failure) => emit(PaymentWalletError(failure)),
      (transactions) => emit(TransactionHistoryLoaded(transactions)),
    );
  }

  void _handleWalletResult(
    Either<Failure, double> result,
    Emitter<PaymentWalletState> emit,
  ) {
    result.fold(
      (failure) => emit(PaymentWalletError(failure)),
      (balance) => emit(WalletLoaded(balance, DateTime.now())),
    );
  }
}