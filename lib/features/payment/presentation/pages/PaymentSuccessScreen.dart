import 'package:car_parking/Core/router/router.dart';
import 'package:car_parking/features/nfc_gate/presentation/pages/nfc_gate_page.dart';
import 'package:car_parking/features/payment/Domain/entity/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final TransactionEntity transaction;

  const PaymentSuccessScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تمت العملية بنجاح'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text(
              'تمت عملية الدفع بنجاح',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('رقم المرجع: ${transaction.id}'),
            Text('المبلغ: ${transaction.amount} ر.س'),
            Text(
              'التاريخ: ${DateFormat('yyyy-MM-dd HH:mm').format(transaction.createdAt)}',
            ),
            const SizedBox(height: 32),
            // زر الاقتران
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PairingScreen(
                      nfcTicket: transaction.nfcTicket,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.send),
                  SizedBox(width: 8),
                  Text('إرسال التذكرة'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.home,
                  (route) => false,
                  arguments:
                      transaction.userId, // تمرير userId من BookingEntity
                );
              },
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    );
  }
}
