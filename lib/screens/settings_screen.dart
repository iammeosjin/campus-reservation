import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'reservations_screen.dart'; // Import ReservationScreen
import 'policy_screen.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.blue[900],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Button
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text("Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          const Divider(),

          // Reservation Button
          ListTile(
            leading: const Icon(Icons.history, color: Colors.blue),
            title: const Text("Reservations"), // Updated title
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReservationScreen()), // Updated screen
              );
            },
          ),
          const Divider(),

          // Policy Button
          ListTile(
            leading: const Icon(Icons.policy, color: Colors.blue),
            title: const Text("Policy"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PolicyScreen()),
              );
            },
          ),
          const Divider(),

          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () async {
              final SharedPreferences prefs =
              await SharedPreferences.getInstance();

              // Clear all stored data
              await prefs.clear();

              // Navigate to LoginScreen and remove all previous routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
