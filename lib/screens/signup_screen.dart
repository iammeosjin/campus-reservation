import 'package:flutter/material.dart';
import 'login_screen.dart'; // For JSON encoding/decoding
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for Text Fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool obscurePassword = true;

  // Base URL of your DenoJS API
  final String apiBaseUrl =
      '${kDebugMode ? 'http://10.0.2.2:3000' : 'https://campus-management-test.deno.dev'}/api/users'; // Replace with your server's URL

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: Colors.blue,
                ),
                const SizedBox(width: 20),
                const Text(
                  "Processing...",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context, rootNavigator: true)
        .pop(); // Close the loading dialog
  }

  // ✅ Validation Logic
  String? _validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return "$fieldName cannot be empty";
    }
    return null;
  }

  // ✅ Password Visibility Toggle
  void _togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  // ✅ Call API to Create User
  Future<void> _createUser() async {
    final dio = Dio();

    // Show the loading dialog
    _showLoadingDialog();

    try {
      final response = await dio.post(
        apiBaseUrl,
        data: {
          "name": fullNameController.text,
          "email": emailController.text,
          "sid": idNumberController.text,
          "password": passwordController.text,
          "role": "STUDENT"
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      // Hide the loading dialog
      _hideLoadingDialog();

      if (response.statusCode == 201) {
        // Success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("User created successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        // Redirect to LoginScreen after successful signup
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        // Show error message from API response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Error: ${response.data['message'] ?? 'Something went wrong!'}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on DioError catch (e) {
      // Hide the loading dialog
      _hideLoadingDialog();

      // Handle DioError (e.g., network issues, timeout, etc.)
      String errorMessage = "An unexpected error occurred.";
      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        errorMessage = e.response!.data['message'] ?? "Something went wrong!";
      } else if (e.response != null) {
        errorMessage = "${e.response}";
      } else if (e.type == DioErrorType.connectTimeout) {
        errorMessage = "Connection timeout. Please try again.";
      } else if (e.type == DioErrorType.receiveTimeout) {
        errorMessage = "Server took too long to respond. Please try again.";
      } else if (e.type == DioErrorType.other) {
        errorMessage = "No internet connection. Please check your network.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // Hide the loading dialog
      _hideLoadingDialog();

      // Handle unexpected exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ Sign Up Button Logic
  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match!")),
        );
      } else {
        // Call the API
        _createUser();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Create an Account",
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: fullNameController,
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) =>
                              _validateField(value, "Full Name"),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) => _validateField(value, "Email"),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: idNumberController,
                          decoration: InputDecoration(
                            labelText: "ID Number",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) =>
                              _validateField(value, "ID Number"),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.blue,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                          ),
                          validator: (value) =>
                              _validateField(value, "Password"),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.blue,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                          ),
                          validator: (value) =>
                              _validateField(value, "Confirm Password"),
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 80),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            onPressed: _handleSignUp,
                            child: const Text("Sign Up"),
                          ),
                        ),
                        const Spacer(),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Already have an account? Log In",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.blueAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
