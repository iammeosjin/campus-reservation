import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ubook/utils/get_url.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'notification_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final String apiBaseUrl = '$apiURL/api/resources';
  List<String> resources = [];
  Map<String, List<Map<String, String>>> resourceItems = {};

  final Dio _dio = Dio();

  // Fetch resources from the API
  Future<void> fetchResources() async {
    try {
      final response = await _dio.get(apiBaseUrl);

      if (response.statusCode == 200) {

        final data = response.data;

        if (data is Map<String, dynamic>) {
          final Map<String, List<Map<String, String>>> fetchedResourceItems = {};

          data.forEach((type, items) {
            resources.add(type);
            fetchedResourceItems[type] = (items as List).map((item) {
              return {
                'id': List.castFrom(item['id']).join(';'),
                'name': item['name'].toString(),
                'image': (item['image'] as String) ?? '',
              };
            }).toList();
          });
          setState(() {
            resourceItems = fetchedResourceItems;
          });
        } else {
          throw Exception("Invalid response format");
        }
      } else {
        throw Exception("Failed to load resources");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchResources();
  }

  @override
  Widget build(BuildContext context) {

    // Screens with dynamic `resourceItems` passed to `CalendarScreen`
    final List<Widget> _screens = [
      HomeScreen(),
      CalendarScreen(resourceItems: resourceItems),
      NotificationScreen(resourceItems: resourceItems), // Pass resourceItems here
      SettingsScreen(),
    ];


    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Calendar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifications",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
