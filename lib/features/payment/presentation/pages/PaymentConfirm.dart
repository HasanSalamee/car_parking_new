/*//////////////////////////////////////////////
import 'package:car_parking/Core/router/router.dart';
import 'package:car_parking/features/payment/presentation/bolc/payment_bloc.dart';
import 'package:car_parking/features/payment/presentation/bolc/payment_event.dart';
import 'package:car_parking/features/payment/presentation/bolc/payment_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  final String userId;
  final String bookingId;
  final double amount;
  final String garageName;
  final String paymentMethod;

  const PaymentConfirmationScreen({
    super.key,
    required this.userId,
    required this.bookingId,
    required this.amount,
    required this.garageName,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد الدفع'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان الشاشة
            const Text(
              'مراجعة المعلومات',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // تفاصيل الحجز
            _buildDetailItem('الكراج:', garageName),
            _buildDetailItem('طريقة الدفع:', _getPaymentMethodName()),
            _buildDetailItem('المبلغ:', '${amount.toStringAsFixed(2)} ر.س'),

            const Spacer(),

            // زر التأكيد
            BlocConsumer<PaymentWalletBloc, PaymentWalletState>(
              listener: (context, state) {
                if (state is PaymentSuccess) {
                  Navigator.pushNamed(
                    context,
                    AppRouter.paymentSuccess,
                    arguments: state.transaction,
                  );
                }
                if (state is PaymentWalletError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.failure.message)),
                  );
                }
              },
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: state is PaymentWalletLoading
                        ? null
                        : () {
                            context.read<PaymentWalletBloc>().add(
                                  ProcessPayment(
                                    userId: userId,
                                    bookingId: bookingId,
                                    amount: amount,
                                    method: paymentMethod,
                                  ),
                                );
                          },
                    child: state is PaymentWalletLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(width: 12),
                              Text('جاري المعالجة...'),
                            ],
                          )
                        : const Text('تأكيد الدفع'),
                  ),
                );
              },
            ),

            // زر الإلغاء
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text('إلغاء', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName() {
    switch (paymentMethod) {
      case 'e_wallet':
        return 'المحفظة الإلكترونية';
      case 'credit_card':
        return 'بطاقة الائتمان';
      case 'cash':
        return 'نقداً عند الوصول';
      default:
        return paymentMethod;
    }
  }
}
*/
