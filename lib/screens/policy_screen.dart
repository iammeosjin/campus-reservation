import 'package:flutter/material.dart';

class PolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Policy",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                "Booking Policies",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 20),

              // Policy List Items
              _buildPolicyItem(
                "1. Cancellations of booking are not ALLOWED.",
                Icons.cancel,
                Colors.redAccent,
              ),
              _buildPolicyItem(
                "2. Only registered users are permitted to book resources.",
                Icons.person_outline,
                Colors.blueAccent,
              ),
              _buildPolicyItem(
                "3. Resources must be booked at least 24 hours in advance.",
                Icons.access_time,
                Colors.orangeAccent,
              ),
              _buildPolicyItem(
                "4. Users must use resources responsibly and report any issues.",
                Icons.report_problem_outlined,
                Colors.purpleAccent,
              ),
              _buildPolicyItem(
                "5. Violating policies may result in booking restrictions.",
                Icons.warning_amber_rounded,
                Colors.redAccent,
              ),

              const SizedBox(height: 40),

              // Quotation Section for Emphasis
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[900] as Color, width: 1.5),
                ),
                child: const Text(
                  "\"Reserve your resources seamlessly and make every moment count — "
                      "our booking application ensures that what you need is just a click away.\"",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Method for Building Policy Items
  Widget _buildPolicyItem(String text, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
