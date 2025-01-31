import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'booking_screen.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class CalendarScreen extends StatefulWidget {
  final Map<String, List<Map<String, String>>> resourceItems;

  const CalendarScreen({super.key, required this.resourceItems});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Set<DateTime> _unavailableDates = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUnavailableDates();
  }

  // Fetch unavailable dates from API
  Future<void> _fetchUnavailableDates() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("Authorization token not found");
      }

      final Dio dio = Dio();
      final response = await dio.get(
        '${kDebugMode ? 'http://10.0.2.2:3000' : 'https://campus-management-test.deno.dev'}/api/reservations',
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'X-PLATFORM': 'mobile'},
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> reservations = response.data;

        setState(() {
          _unavailableDates.addAll(
            reservations
                .where((reservation) =>
                    reservation['status'] == 'PENDING' ||
                    reservation['status'] == 'APPROVED')
                .map((reservation) {
              return DateTime.parse(reservation['dateStarted']);
            }),
          );
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch reservations.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching unavailable dates: $e")),
      );
    }
  }

  // Confirm the selected date and navigate to BookingScreen
  void confirmDate() {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a valid date."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    DateTime normalizedDay = DateTime.utc(
        _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);

    DateTime now = DateTime.now();
    if (_unavailableDates.contains(normalizedDay!) ||
        normalizedDay.compareTo(DateTime(now.year, now.month, now.day)) < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a valid date."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(
          initialDate: _selectedDay,
          resourceItems: widget.resourceItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Calendar"),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blueGrey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  calendarBuilders:
                      CalendarBuilders(defaultBuilder: (context, day, _) {
                    final normalizedDay =
                        DateTime.utc(day.year, day.month, day.day);
                    if (_unavailableDates.contains(normalizedDay)) {
                      return Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (day.isBefore(DateTime.now())) {
                      return Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return null; // Default rendering
                  }, outsideBuilder : (context, day, _) {
                    final normalizedDay =
                        DateTime.utc(day.year, day.month, day.day);
                    if (_unavailableDates.contains(normalizedDay)) {
                      return Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    return null; // Default rendering
                  }),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: confirmDate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 16),
                  ),
                  child: const Text(
                    "Confirm Date",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
    );
  }
}
