import 'package:car_parking/features/nfc_gate/domain/entities/nfs_ticket.dart';
import 'package:car_parking/features/nfc_gate/presentation/bloc/nfc_bloc.dart';
import 'package:car_parking/features/nfc_gate/presentation/bloc/nfc_event.dart';
import 'package:car_parking/features/nfc_gate/presentation/bloc/nfc_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

enum SendMethod { bluetooth, nfc }

class PairingScreen extends StatefulWidget {
  final NfcTicket nfcTicket; // استقبال NfcTicket بدلاً من bookingId

  const PairingScreen({Key? key, required this.nfcTicket}) : super(key: key);

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  SendMethod _selectedMethod = SendMethod.bluetooth; // الوضع الافتراضي: بلوتوث

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إرسال التذكرة'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'اختر طريقة الإرسال:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // خيارات الإرسال (Bluetooth و NFC)
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
                // عرض تفاصيل التذكرة مباشرة من nfcTicket
                _buildTicketInfo(widget.nfcTicket, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketInfo(NfcTicket ticket, NfcState state) {
    if (state is WritingTicket) {
      return const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('جهز بطاقة NFC للكتابة...'),
          SizedBox(height: 8),
          Text('قرّب البطاقة من الجهاز', style: TextStyle(fontSize: 16)),
        ],
      );
    } else if (state is SendingTicketViaBluetooth) {
      return const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('جاري إرسال التذكرة عبر البلوتوث...'),
        ],
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
              onPressed: () => Navigator.pop(context),
              child: const Text('تم'),
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تفاصيل التذكرة:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('رقم التذكرة: ${ticket.id}'),
          Text('الحجز: ${ticket.bookingId}'),
          Text(
              'صالح من: ${DateFormat('yyyy-MM-dd HH:mm').format(ticket.validFrom)}'),
          Text(
              'صالح إلى: ${DateFormat('yyyy-MM-dd HH:mm').format(ticket.validTo)}'),
          Text('الحالة: ${ticket.isUsed ? "مستخدم" : "غير مستخدم"}'),
          const SizedBox(height: 32),
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
}
