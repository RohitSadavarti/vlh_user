import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'login_screen.dart';

class OtpScreen extends StatelessWidget {
  final String email;
  final TextEditingController _otpController = TextEditingController();

  OtpScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter OTP")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("OTP sent to $email"),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(labelText: "6-Digit OTP"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success = await ApiService.verifyOtp(
                  email,
                  _otpController.text,
                );
                if (success) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Invalid OTP")));
                }
              },
              child: Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }
}
