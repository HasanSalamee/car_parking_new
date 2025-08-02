import 'dart:ui';
import 'package:car_parking/Core/router/router.dart';
import 'package:car_parking/features/Parking/Domain/Entities/garage_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingDetailsScreen extends StatelessWidget {
  final GarageEntity garage;
  final DateTime arrivalTime;
  final DateTime departureTime;

  const BookingDetailsScreen({
    super.key,
    required this.garage,
    required this.arrivalTime,
    required this.departureTime,
  });

  @override
  Widget build(BuildContext context) {
    final totalHours = departureTime.difference(arrivalTime).inHours;
    final totalAmount = garage.pricePerHour * totalHours;

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الحجز - ${garage.name}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات المواقف
            _buildGarageInfo(),
            const SizedBox(height: 20),

            // معلومات التوقيت
            _buildTimeInfo(totalHours),
            const SizedBox(height: 20),

            // ملخص الدفع
            _buildPaymentSummary(totalAmount.toDouble()),
            const Spacer(),

            // زر تأكيد الحجز
            _buildBookButton(context, totalAmount.toDouble()),
          ],
        ),
      ),
    );
  }

  Widget _buildGarageInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              garage.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "${garage.location.latitude.toStringAsFixed(5)}, ${garage.location.longitude.toStringAsFixed(5)}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'السعة: ${garage.capacity} مركبات',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(int totalHours) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تفاصيل الوقت',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الوصول:', style: TextStyle(fontSize: 16)),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(arrivalTime),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('المغادرة:', style: TextStyle(fontSize: 16)),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(departureTime),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('المدة:', style: TextStyle(fontSize: 16)),
                Text(
                  '$totalHours ساعة',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(double totalAmount) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ملخص الدفع',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('سعر الساعة:', style: TextStyle(fontSize: 16)),
                Text(
                  '${garage.pricePerHour} ر.س',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المبلغ الإجمالي:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$totalAmount ر.س',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton(BuildContext context, double totalAmount) {
    return SizedBox(
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
          // استخدام الدالة الجديدة في الراوتر للانتقال إلى الدفع
          AppRouter.pushToPayment(
            context: context,
            bookingId: _generateBookingId(),
            amount: totalAmount,
            garageName: garage.name,
            userId: "",
          );
        },
        child: const Text(
          'انتقل للدفع',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _generateBookingId() {
    return 'BK${DateTime.now().millisecondsSinceEpoch}';
  }
}
