import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'reset_password_screen.dart';
import '../utils/get_url.dart';

class EnterCodeScreen extends StatefulWidget {
  final String email; // Required email parameter
  const EnterCodeScreen({super.key, required this.email});

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;
  final Dio dio = Dio();

  // API Base URLs
  final String verifyCodeApiUrl =
      '$apiURL/api/users/verify-code';
  final String resendCodeApiUrl =
      '$apiURL/api/users/forgot-password';

  // Verify Code Logic
  Future<void> _submitCode() async {
    if (codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the code."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      debugPrint(
          "Submitting code: ${codeController.text} for email: ${widget.email}");
      final response = await dio.post(
        verifyCodeApiUrl,
        data: {"code": codeController.text, "email": widget.email},
        options: Options(
            headers: {"Content-Type": "application/json"},
            validateStatus: (status) {
              // Treat all HTTP statuses as valid responses
              // You can customize it further if needed
              return status != null && status < 500;
            }),
      );
      if (response.statusCode == 200) {
        // Navigate to Reset Password Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(email: widget.email)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data ?? "Invalid code."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Resend Code Logic
  Future<void> _resendCode() async {
    setState(() {
      isLoading = true;
    });

    try {
      debugPrint("Resending code to email: ${widget.email}");
      final response = await dio.post(
        resendCodeApiUrl,
        data: {"email": widget.email},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Code resent successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(response.data['message'] ?? "Failed to resend code."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter Reset Code"),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter the code sent to your email.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: "Reset Code",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          _resendCode();
                        },
                  child: const Text("Resend Code"),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : _submitCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 30),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
