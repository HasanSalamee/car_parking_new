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
            SnackBar(
              content: Text(state.failure.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'دفع - $garageName',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.indigo.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.2, 0.8],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF5F9FF), Color(0xFFE6F0FF)],
            ),
          ),
          child: Padding(
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.indigo.shade700],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade300,
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'خدمة الدفع ببطاقة الائتمان غير مفعلة حالياً'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      splashColor: Colors.white.withOpacity(0.3),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Center(
                          child: Text(
                            'دفع الآن',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: Colors.blue.shade100,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  color == Colors.grey ? Colors.grey.shade700 : Colors.black87,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.blue),
          onTap: () {
            _showPaymentConfirmation(context, title, paymentType);
          },
        ),
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
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return; // الخروج من الدالة دون عرض التأكيد
    }

    // إذا كانت الخدمة مفعلة (المحفظة الإلكترونية)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'تأكيد الدفع',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('هل تريد تأكيد الدفع باستخدام $method؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.red)),
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
            child: const Text('تأكيد', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
