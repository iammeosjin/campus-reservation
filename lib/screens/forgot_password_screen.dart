import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'enter_code_screen.dart';
import '../utils/get_url.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  // Base URL for API
  final String apiBaseUrl =
      '$apiURL/api/users/forgot-password';

  // Handle Forgot Password Request
  Future<void> _sendResetPassword() async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter your email."),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final dio = Dio();
      print("apiBaseUrl $apiBaseUrl");
      final response = await dio.post(
        apiBaseUrl,
        data: {"email": emailController.text},
        options: Options(
            headers: {"Content-Type": "application/json"},
            validateStatus: (status) {
              // Treat all HTTP statuses as valid responses
              // You can customize it further if needed
              return status != null && status < 500;
            }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Reset code sent to your email."),
              backgroundColor: Colors.green),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EnterCodeScreen(
                    email: emailController.text,
                  )),
        );
      } else if (response.statusCode == 401)  {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Invalid email"),
              backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: ${response.data}"),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An error occurred. Please try again."),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter your email address to receive a reset code.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _sendResetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Send Reset Password",
                        style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
