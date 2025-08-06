import 'package:car_parking/Core/router/router.dart';
import 'package:car_parking/features/Parking/Presentation/Bloc/parking_booking_bloc.dart';
import 'package:car_parking/features/Parking/Presentation/Bloc/parking_booking_event.dart';
import 'package:car_parking/features/nfc_gate/domain/entities/nfs_ticket.dart';
import 'package:car_parking/features/nfc_gate/presentation/bloc/nfc_bloc.dart';
import 'package:car_parking/features/nfc_gate/presentation/bloc/nfc_event.dart';
import 'package:car_parking/features/nfc_gate/presentation/bloc/nfc_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

enum SendMethod { bluetooth, nfc }

class PairingScreen extends StatefulWidget {
  final NfcTicket nfcTicket;

  const PairingScreen({Key? key, required this.nfcTicket}) : super(key: key);

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  SendMethod _selectedMethod = SendMethod.bluetooth;

  void _returnToHomeAndUpdateBookings() {
    // الخطوة 1: إرسال طلب لتحديث بيانات الحجوزات في الصفحة الرئيسية
    context
        .read<ParkingBookingBloc>()
        .add(GetUserBookingsEvent(userId: widget.nfcTicket.userId));

    // الخطوة 2: العودة مباشرة إلى الصفحة الرئيسية وإغلاق كل الصفحات التي فوقها
    Navigator.popUntil(context, ModalRoute.withName(AppRouter.home));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إرسال التذكرة'),
        // تعديل: إضافة زر رجوع مخصص لضمان تحديث البيانات عند الخروج
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _returnToHomeAndUpdateBookings,
        ),
      ),
      body: BlocConsumer<NfcBloc, NfcState>(
        listener: (context, state) {
          if (state is NfcError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          } else if (state is TicketWritten) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is TicketSentViaBluetooth) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              // تعديل: إضافة SingleChildScrollView لتجنب تجاوز المحتوى
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اختر طريقة الإرسال:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('بلوتوث (BLE)'),
                        selected: _selectedMethod == SendMethod.bluetooth,
                        onSelected: (selected) {
                          setState(() {
                            _selectedMethod = SendMethod.bluetooth;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      ChoiceChip(
                        label: const Text('NFC'),
                        selected: _selectedMethod == SendMethod.nfc,
                        onSelected: (selected) {
                          setState(() {
                            _selectedMethod = SendMethod.nfc;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildTicketInfo(widget.nfcTicket, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketInfo(NfcTicket ticket, NfcState state) {
    if (state is WritingTicket || state is SendingTicketViaBluetooth) {
      return Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              state is WritingTicket
                  ? 'جهز بطاقة NFC للكتابة...'
                  : 'جاري إرسال التذكرة عبر البلوتوث...',
              style: const TextStyle(fontSize: 16),
            ),
            if (state is WritingTicket)
              const Text('قرّب البطاقة من الجهاز',
                  style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    } else if (state is TicketWritten || state is TicketSentViaBluetooth) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            Text(
              state is TicketWritten
                  ? state.message
                  : (state as TicketSentViaBluetooth).message,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed:
                  _returnToHomeAndUpdateBookings, // *** التعديل الرئيسي هنا ***
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      );
    } else if (state is NfcError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 80),
            const SizedBox(height: 16),
            Text(
              state.error,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_selectedMethod == SendMethod.bluetooth) {
                  context
                      .read<NfcBloc>()
                      .add(SendTicketViaBluetoothEvent(ticket));
                } else {
                  context.read<NfcBloc>().add(WriteNfcTicketEvent(ticket));
                }
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    } else {
      // الحالة الافتراضية قبل الضغط على أي زر
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تفاصيل التذكرة:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoField('معرف المستخدم', ticket.userId),
          _buildInfoField('معرف الحجز', ticket.bookingId),
          _buildInfoField('رقم التذكرة', ticket.tokenId.toString()),
          _buildInfoField('صالح من',
              DateFormat('yyyy-MM-dd HH:mm').format(ticket.tokenValidFrom)),
          _buildInfoField('صالح إلى',
              DateFormat('yyyy-MM-dd HH:mm').format(ticket.tokenValidTo)),
          _buildInfoField('الحالة', ticket.isUsed ? "مستخدم" : "غير مستخدم"),
          _buildInfoField('سلسلة التذكرة', ticket.tokenValue,
              canCopy: true, isLongText: true),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              icon: Icon(_selectedMethod == SendMethod.bluetooth
                  ? Icons.bluetooth
                  : Icons.nfc),
              label: Text(_selectedMethod == SendMethod.bluetooth
                  ? 'إرسال عبر البلوتوث'
                  : 'كتابة على بطاقة NFC'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              onPressed: () {
                if (_selectedMethod == SendMethod.bluetooth) {
                  context
                      .read<NfcBloc>()
                      .add(SendTicketViaBluetoothEvent(ticket));
                } else {
                  context.read<NfcBloc>().add(WriteNfcTicketEvent(ticket));
                }
              },
            ),
          ),
        ],
      );
    }
  }

  // ويدجت مساعد لتحسين شكل عرض البيانات
  Widget _buildInfoField(String label, String value,
      {bool canCopy = true, bool isLongText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onLongPress: canCopy
                ? () async {
                    await Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم نسخ $label')),
                    );
                  }
                : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                value,
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    height: isLongText ? 1.5 : 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
