import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ubook/screens/main_screen.dart';
import 'package:ubook/utils/get_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class BookingConfirmationScreen extends StatefulWidget {
  final String resource;
  final String item;
  final String date;
  final String dateTimeStarted;
  final String dateTimeEnded;
  final String image;
  final String resourceId; // Pass resource ID for API

  const BookingConfirmationScreen({
    super.key,
    required this.resource,
    required this.item,
    required this.date,
    required this.dateTimeStarted,
    required this.dateTimeEnded,
    required this.image,
    required this.resourceId, // Resource ID from GET /api/resources
  });

  @override
  _BookingConfirmationScreenState createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool isLoading = false; // Loading state for the API request
  File? requestFormImage; // File for proof of request
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        requestFormImage = File(pickedFile.path);
      });
    }
  }

  // Function to Send POST Request with FormData
  Future<void> _confirmBooking() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Retrieve token from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("Authorization token not found");
      }

      // Prepare request body and headers
      final Dio dio = Dio();
      final FormData formData = FormData.fromMap({
        'resource':
            jsonEncode([widget.resourceId]), // Pass resource ID as an array
        'dateStarted': widget.date, // Pass selected date
        'dateTimeStarted': widget.dateTimeStarted, // Pass full date-time
        'dateTimeEnded': widget.dateTimeEnded, // Pass full date-time
        if (requestFormImage != null) // Attach proof image if exists
          'requestFormImage': await MultipartFile.fromFile(
            requestFormImage!.path,
            filename: requestFormImage!.path.split('/').last,
          ),
      });

      final response = await dio.post(
        '$apiURL/api/reservations',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) {
            // Treat all HTTP statuses as valid responses
            // You can customize it further if needed
            return status != null && status < 500;
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Booking successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Booking confirmed successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        // Redirect to MainScreen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
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
        title: const Text("Booking Confirmation"),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Prevents infinite height issue
            children: [
              Text(
                "Booking Confirmation",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Resource Image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://gateway.pinata.cloud/ipfs/${widget.image}',
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 250,
                        height: 250,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Booking Details Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("Resource", widget.resource),
                    const SizedBox(height: 10),
                    _buildDetailRow("Item", widget.item),
                    const SizedBox(height: 10),
                    _buildDetailRow("Date", widget.date),
                    const SizedBox(height: 10),
                    _buildDetailRow("Time",
                        "${widget.dateTimeStarted} - ${widget.dateTimeEnded}"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Proof Image Upload Section
              Text(
                "Upload Proof of Request (Optional)",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900]),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.image),
                    label: const Text("Gallery"),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Preview Selected Image
              if (requestFormImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    requestFormImage!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 20), // Replace Spacer()

              // Confirm Button
              ElevatedButton(
                onPressed: isLoading ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLoading ? Colors.grey : Colors.blue[900],
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Confirm Booking",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 20), // Ensure bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // Helper to Build Detail Rows
  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label:",
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 18, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
