import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ubook/utils/get_url.dart';
import 'booking_screen.dart';
import 'calendar_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _currentIndex = 0;

  final String apiBaseUrl =
      '$apiURL/api/resources';

  List<String> resources = [];
  Map<String, List<Map<String, String>>> resourceItems = {};

  final Dio _dio = Dio();

  Future<void> fetchResources() async {
    try {
      final response = await _dio.get(apiBaseUrl);
      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          // Clear the existing resources to avoid duplication
          final Map<String, List<Map<String, String>>> fetchedResourceItems =
              {};
          resources.clear();

          data.forEach((type, items) {
            resources.add(type);
            fetchedResourceItems[type] = (items as List).map((item) {
              return {
                'id': List.castFrom(item['id']).join(';'),
                'name': item['name'].toString(),
                'image': (item['image'] ?? '').toString(),
              };
            }).toList();
          });

          setState(() {
            resourceItems = fetchedResourceItems;
            print("resourceItems $resourceItems");
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

  void _onNavTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationScreen(
            resourceItems: resourceItems,
          ),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CalendarScreen(
            resourceItems: resourceItems,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Home",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      body: resources.isEmpty
          ? RefreshIndicator(
              onRefresh: fetchResources,
              child: ListView(
                children: const [
                  Center(
                    heightFactor: 10,
                    child: Text(
                      "No resources available. Pull down to refresh.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchResources, // Pull-to-refresh callback
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    child: Text(
                      "Reserve Your Resource",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: resources.map((resource) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ChoiceChip(
                            label: Text(
                              resource.replaceAll('_', ' '),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _selectedIndex ==
                                        resources.indexOf(resource)
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            selected:
                                _selectedIndex == resources.indexOf(resource),
                            selectedColor: Colors.blue[800],
                            onSelected: (selected) {
                              setState(() {
                                _selectedIndex = resources.indexOf(resource);
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          resourceItems[resources[_selectedIndex]]?.length ?? 0,
                      itemBuilder: (context, index) {
                        final item =
                            resourceItems[resources[_selectedIndex]]![index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: (item['image'] as String).isNotEmpty
                                ? Image.network(
                                    'https://gateway.pinata.cloud/ipfs/${item['image']}',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/image_placeholder.png',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/image_placeholder.png',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                            title: Text(
                              item['name']!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text('Click to book this resource'),
                            trailing: Icon(Icons.arrow_forward_ios,
                                color: Colors.blue[800]),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingScreen(
                                    initialResource: resources[_selectedIndex],
                                    initialItem: item['name'],
                                    initialDate: DateTime.now(),
                                    resourceItems: resourceItems,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
