import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userDetails; // Store user details
  bool isLoading = true; // Show loading state

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  // Fetch user details from API
  Future<void> _fetchUserDetails() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("Authorization token not found");
      }

      final Dio dio = Dio();
      final response = await dio.get(
        '${kDebugMode ? 'http://10.0.2.2:3000' : 'https://campus-management-test.deno.dev'}/api/users',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          userDetails = response.data;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch user details");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user details: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Section
            Center(
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue[100],
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Name
                  Text(
                    userDetails?['name'] ?? "Unknown User",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),

                  // User Role
                  Text(
                    userDetails?['role'] ?? "Role not assigned",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // User Details Section
            Expanded(
              child: ListView(
                children: [
                  _buildProfileInfoRow("Email", userDetails?['email'] ?? "N/A"),
                  _buildProfileInfoRow("ID Number", userDetails?['sid'] ?? "N/A"),
                  _buildProfileInfoRow("Role", userDetails?['role'] ?? "N/A"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Logout Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); // Clear token from storage
                  Navigator.pop(context); // Navigate to LoginScreen
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build profile information rows
  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto',
                color: Colors.blueGrey,
              ),
            ),
          ),

          // Value
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Roboto',
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
