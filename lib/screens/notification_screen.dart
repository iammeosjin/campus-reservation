import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ubook/utils/get_url.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

String _formatDate(String date) {
  try {
    final parsedDate = DateTime.parse(date).toLocal();
    return DateFormat('MMMM d, y, hh:mm a').format(parsedDate);
  } catch (e) {
    return "Invalid Date";
  }
}

class NotificationScreen extends StatefulWidget {
  final Map<String, List<Map<String, String>>> resourceItems;

  const NotificationScreen({super.key, required this.resourceItems});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _currentIndex = 1;

  final Dio _dio = Dio();
  final String apiBaseUrl = '$apiURL/api/notifications';

  List<Map<String, dynamic>> notifications = [];
  bool _isLoading = true; // Track loading state

  // Fetch notifications from the API
  Future<void> fetchNotifications() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("Authorization token not found");
      }

      final response = await _dio.get(
        apiBaseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Add token to the headers
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedNotifications = response.data;
        print(fetchedNotifications);

        // Sort notifications by date (descending order)
        fetchedNotifications.sort((a, b) {
          final dateA = DateTime.parse(a['dateTimeCreated']);
          final dateB = DateTime.parse(b['dateTimeCreated']);
          return dateB.compareTo(dateA);
        });

        setState(() {
          notifications = fetchedNotifications
              .map((notification) => {
                    'title': notification['title'],
                    'description': notification['body'],
                    'image':
                        notification['image'] ?? 'assets/image_placeholder.png',
                    'dateStarted': notification['dateTimeCreated'],
                  })
              .toList();
          _isLoading = false; // Stop loading
        });
      } else {
        throw Exception("Failed to fetch notifications");
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  void _onNavTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CalendarScreen(
            resourceItems: widget.resourceItems,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Notifications"),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchNotifications, // Pull-to-refresh callback
              child: notifications.isEmpty
                  ? const Center(child: Text("No notifications available"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Notification Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    'https://gateway.pinata.cloud/ipfs/${notification['image']}',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/image_placeholder.png',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Notification Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Notification Title
                                      Text(
                                        notification['title']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Notification Description
                                      Text(
                                        notification['description']!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      // Notification Date
                                      Text(
                                        _formatDate(
                                            notification['dateStarted']),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
