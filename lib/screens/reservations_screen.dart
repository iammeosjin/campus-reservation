import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ubook/utils/get_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationScreen extends StatefulWidget {
  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

Row _buildAlignedRow(String key, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Key
      SizedBox(
        width: 80, // Fixed width for keys to align them properly
        child: Text(
          key,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      // Value
      Expanded(
        child: Text(
          value,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis, // Handle long values
        ),
      ),
    ],
  );
}

class _ReservationScreenState extends State<ReservationScreen> {
  List<Map<String, dynamic>> reservations = [];
  Map<String, Map<String, String>> resourceDetails = {}; // For resource mapping
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("Authorization token not found");
      }

      final Dio dio = Dio();

      final reservationsResponse = await dio.get(
        '$apiURL/api/reservations',
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'X-PLATFORM': 'mobile'},
        ),
      );

      final resourcesResponse = await dio.get(
        '$apiURL/api/resources',
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'X-TYPE': 'all'},
        ),
      );

      if (reservationsResponse.statusCode == 200 &&
          resourcesResponse.statusCode == 200) {
        final reservationData =
            List<Map<String, dynamic>>.from(reservationsResponse.data);

        reservationData.sort((a, b) {
          final dateA = DateTime.parse(a['dateTimeCreated']);
          final dateB = DateTime.parse(b['dateTimeCreated']);
          return dateB.compareTo(dateA);
        });

        final List<Map<String, dynamic>> resourcesData =
            List<Map<String, dynamic>>.from(resourcesResponse.data);

        final Map<String, Map<String, String>> resourcesMap = {};
        for (final resource in resourcesData) {
          final idList = List<String>.from(resource['id']);
          for (final id in idList) {
            resourcesMap[id] = {
              'name': _capitalizeWords(resource['name'] as String),
              'location': resource['location'] ?? 'N/A',
            };
          }
        }

        setState(() {
          reservations = reservationData;
          resourceDetails = resourcesMap;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _cancelReservation(String reservationId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("Authorization token not found");
      }

      final Dio dio = Dio();
      final response = await dio.patch(
        '$apiURL/api/reservations/$reservationId',
        data: {'status': 'CANCELLED'},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reservation cancelled successfully."),
            backgroundColor: Colors.green,
          ),
        );

        _fetchData();
      } else {
        throw Exception("Failed to cancel reservation");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cancelling reservation: $e")),
      );
    }
  }

  String _capitalizeWords(String input) {
    return input
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date).toLocal();
      return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Invalid Date";
    }
  }

  String _formatTime(String startTime, String endTime) {
    try {
      final String zone = DateTime.now().timeZoneName;

      // Parse with time zone awareness
      final DateTime parsedStart =
          DateTime.parse(startTime).add(Duration(hours: zone == 'GMT' ? 8 : 0));
      final DateTime parsedEnd =
          DateTime.parse(endTime).add(Duration(hours: zone == 'GMT' ? 8 : 0));
      print("parsedStart $parsedStart");
      // Format the time correctly in HH:mm format
      return "${parsedStart.hour.toString().padLeft(2, '0')}:${parsedStart.minute.toString().padLeft(2, '0')} - "
          "${parsedEnd.hour.toString().padLeft(2, '0')}:${parsedEnd.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Invalid Time Range";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reservations"),
        backgroundColor: Colors.blue[900],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: reservations.isEmpty
                  ? const Center(child: Text("No reservations found."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: reservations.length,
                      itemBuilder: (context, index) {
                        final reservation = reservations[index];
                        final status = reservation['status'];
                        final isActionable =
                            status != 'EXPIRED' && status != 'CANCELLED';

                        final resourceId = reservation['resource']?.first;
                        final resource = resourceDetails[resourceId] ??
                            {
                              'name': 'Unknown Resource',
                              'location': 'Unknown Location'
                            };

                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row: Resource Name and Status + Cancel Icon
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        resource['name'] ?? 'Resource Name',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // Handle long names
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      children: [
                                        // Status Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: status == 'CANCELLED'
                                                ? Colors.red[100]
                                                : Colors.green[100],
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              color: status == 'CANCELLED'
                                                  ? Colors.red
                                                  : Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Square Cancel Button
                                        if (isActionable)
                                          Container(
                                            width: 32, // Fixed width for square
                                            height:
                                                32, // Fixed height for square
                                            decoration: BoxDecoration(
                                              color: Colors.red[50],
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border:
                                                  Border.all(color: Colors.red),
                                            ),
                                            child: IconButton(
                                              onPressed: () => _cancelReservation(
                                                  reservation['id'].join(
                                                      ';')), // Cancellation logic
                                              icon: const Icon(
                                                  Icons.free_cancellation,
                                                  color: Colors.red),
                                              iconSize: 20,
                                              padding: const EdgeInsets.all(
                                                  0), // Remove padding
                                              tooltip: 'Cancel Reservation',
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildAlignedRow("Location:",
                                    resource['location'] ?? 'Unknown Location'),
                                const SizedBox(height: 4),
                                _buildAlignedRow("Date:",
                                    _formatDate(reservation['dateStarted'])),
                                const SizedBox(height: 4),
                                _buildAlignedRow(
                                    "Time:",
                                    _formatTime(reservation['dateTimeStarted'],
                                        reservation['dateTimeEnded'])),
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
