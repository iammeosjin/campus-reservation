import 'package:flutter/material.dart';
import 'home_screen.dart';

class OTPVerificationScreen extends StatelessWidget {
  final TextEditingController otpController = TextEditingController();

  OTPVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('OTP Verification', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text("We've sent a verification code to your email."),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
              },
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
