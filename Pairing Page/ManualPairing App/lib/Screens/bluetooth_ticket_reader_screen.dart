import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManualTicketValidationScreen extends StatefulWidget {
  @override
  _ManualTicketValidationScreenState createState() =>
      _ManualTicketValidationScreenState();
}

class _ManualTicketValidationScreenState
    extends State<ManualTicketValidationScreen> {
  final TextEditingController _ticketController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _bookingIdController = TextEditingController();

  String verificationResult = "";
  bool isLoading = false;

  final String validateUrl =
      "https://27162546ab51.ngrok-free.app/api/Token/validate";

  Future<void> verifyToken() async {
    final token = _ticketController.text;
    final userId = _userIdController.text;
    final bookingId = _bookingIdController.text;

    if (token.isEmpty || userId.isEmpty || bookingId.isEmpty) {
      setState(() => verificationResult = "⚠️ الرجاء ملء جميع الحقول");
      return;
    }

    setState(() {
      isLoading = true;
      verificationResult = "⏳ جارٍ التحقق من التذكرة...";
    });

    try {
      final response = await http.post(
        Uri.parse(validateUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "userId": userId,
          "bookingId": bookingId,
        }),
      );

      final result = jsonDecode(response.body);
      print(response.body);

      setState(() {
        verificationResult = result == 'valid'
            ? "✅ الحجز صالح - مرحبًا بك!"
            : "❌ رمز التذكرة غير صالح";
      });
    } catch (e) {
      setState(() {
        verificationResult = "⚠️ فشل التحقق من التذكرة: ${e.toString()}";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _ticketController.dispose();
    _userIdController.dispose();
    _bookingIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text("مدخل التذاكر اليدوي")),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // حقل إدخال معرف المستخدم
              TextField(
                controller: _userIdController,
                decoration: InputDecoration(
                  labelText: 'معرف المستخدم (User ID)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.person),
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 16),

              // حقل إدخال معرف الحجز
              TextField(
                controller: _bookingIdController,
                decoration: InputDecoration(
                  labelText: 'معرف الحجز (Booking ID)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.confirmation_number),
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 16),

              // حقل إدخال التذكرة
              TextField(
                controller: _ticketController,
                decoration: InputDecoration(
                  labelText: 'رمز التذكرة (Token)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.vpn_key),
                ),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 24),

              // زر التحقق
              ElevatedButton(
                onPressed: isLoading ? null : verifyToken,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("تحقق من التذكرة", style: TextStyle(fontSize: 18)),
              ),

              const SizedBox(height: 20),

              // نتيجة التحقق
              Text(
                verificationResult,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(verificationResult),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لتحديد لون النتيجة
  Color _getStatusColor(String status) {
    if (status.contains("✅")) return Colors.green;
    if (status.contains("❌") || status.contains("⚠️")) return Colors.red;
    return Colors.blue;
  }
}
