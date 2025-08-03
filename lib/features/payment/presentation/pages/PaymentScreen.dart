import 'package:car_parking/Core/router/router.dart';
import 'package:car_parking/features/payment/presentation/bolc/payment_bloc.dart';
import 'package:car_parking/features/payment/presentation/bolc/payment_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_parking/features/payment/presentation/bolc/payment_event.dart';

class PaymentScreen extends StatelessWidget {
  final String userId;
  final String bookingId;
  final double amount;
  final String garageName;

  const PaymentScreen({
    super.key,
    required this.userId,
    required this.bookingId,
    required this.amount,
    required this.garageName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentWalletBloc, PaymentWalletState>(
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
      child: Scaffold(
        appBar: AppBar(
          title: Text('دفع - $garageName'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildPaymentMethodCard(
                context,
                'بطاقة الائتمان',
                Icons.credit_card,
                Colors.grey, 
                'credit_card',
              ),
              _buildPaymentMethodCard(
                context,
                'محفظة إلكترونية',
                Icons.wallet,
                Colors.green,
                'e_wallet',
              ),
              _buildPaymentMethodCard(
                context,
                'نقداً عند الوصول',
                Icons.money,
                Colors.grey, 
                'cash',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // عرض رسالة أن الخدمة غير مفعلة
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('خدمة الدفع ببطاقة الائتمان غير مفعلة حالياً'),
                      ),
                    );
                  },
                  child: const Text('دفع الآن'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String paymentType,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: color == Colors.grey ? Colors.grey : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          _showPaymentConfirmation(context, title, paymentType);
        },
      ),
    );
  }

  void _showPaymentConfirmation(
      BuildContext context, String method, String paymentType) {
    // التحقق إذا كانت الخدمة غير مفعلة
    if (paymentType == 'credit_card' || paymentType == 'cash') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خدمة الدفع بـ $method غير مفعلة حالياً'),
          duration: const Duration(seconds: 3),
        ),
      );
      return; // الخروج من الدالة دون عرض التأكيد
    }

    // إذا كانت الخدمة مفعلة (المحفظة الإلكترونية)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الدفع'),
        content: Text('هل تريد تأكيد الدفع باستخدام $method؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PaymentWalletBloc>().add(
                    ProcessPayment(
                      userId: userId,
                      bookingId: bookingId,
                      amount: amount,
                      method: 'wallet',
                    ),
                  );
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
