import 'package:flutter/material.dart';
import 'package:ubook/utils/get_url.dart';
import 'package:table_calendar/table_calendar.dart';
import 'booking_confirmation_screen.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingScreen extends StatefulWidget {
  final String? initialResource;
  final String? initialItem;
  final DateTime? initialDate;
  final Map<String, List<Map<String, String>>> resourceItems;

  const BookingScreen({
    super.key,
    this.initialResource,
    this.initialItem,
    this.initialDate,
    required this.resourceItems,
  });

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? selectedResource;
  String? selectedItem;
  DateTime? selectedDate;
  final Set<DateTime> _unavailableDates = {};
  bool isLoading = true;
  bool isCalendarVisible = false;

  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;

  @override
  void initState() {
    super.initState();

    selectedResource = widget.initialResource ?? widget.resourceItems.keys.first;
    selectedItem = widget.initialItem ??
        (selectedResource != null
            ? widget.resourceItems[selectedResource]?.first['name']
            : null);
    selectedDate = widget.initialDate ?? DateTime.now();

    if (selectedDate != null) {
      dateController.text = "${selectedDate!.toLocal()}".split(' ')[0];
    }

    _fetchUnavailableDates();
  }

  // Fetch unavailable dates
  Future<void> _fetchUnavailableDates() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("Authorization token not found");
      }

      final Dio dio = Dio();
      final response = await dio.get(
        '$apiURL/api/reservations',
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'X-PLATFORM': 'mobile'},
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> reservations = response.data;

        setState(() {
          _unavailableDates.addAll(
            reservations.where((reservation) =>
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
        SnackBar(
            content: Text("Error fetching unavailable dates: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final DateTime now = DateTime.now();
    int hour = now.timeZoneName == "GMT" ? now.hour + 8  : now.hour;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (selectedStartTime ??  TimeOfDay(hour: hour, minute: 0))
          : (selectedEndTime ??  TimeOfDay(hour: hour + 1, minute: 0)),
    );

    if (picked != null) {
      setState(() {
        final adjustedTime = TimeOfDay(hour: picked.hour, minute: 0);

        if (isStartTime) {
          selectedStartTime = adjustedTime;
          startTimeController.text =
          "${adjustedTime.hour.toString().padLeft(2, '0')}:00";
        } else {
          if (selectedStartTime == null || adjustedTime.hour > selectedStartTime!.hour) {
            selectedEndTime = adjustedTime;
            endTimeController.text =
            "${adjustedTime.hour.toString().padLeft(2, '0')}:00";
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("End time must be after start time"),
                  backgroundColor: Colors.red),
            );
          }
        }
      });
    }
  }

  void confirmBooking() {
    if (selectedResource == null ||
        selectedItem == null ||
        selectedDate == null ||
        selectedStartTime == null ||
        selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill in all fields."),
            backgroundColor: Colors.red),
      );
      return;
    }

    final resourceList = widget.resourceItems[selectedResource];
    if (resourceList == null || resourceList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Invalid resource selection."),
            backgroundColor: Colors.red),
      );
      return;
    }

    final selectedResourceItem = resourceList.firstWhere(
          (item) => item['name'] == selectedItem,
    );

    if (selectedResourceItem == null || selectedResourceItem['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Invalid item selection."),
            backgroundColor: Colors.red),
      );
      return;
    }

    DateTime normalizedDay = DateTime.utc(
        selectedDate!.year, selectedDate!.month, selectedDate!.day);

    DateTime now = DateTime.now();
    // if (_unavailableDates.contains(normalizedDay!) ||
    //     normalizedDay.compareTo(DateTime(now.year, now.month, now.day)) < 0) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("Please select a valid date."),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    final resourceId = selectedResourceItem['id'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmationScreen(
          resource: selectedResource!,
          item: selectedItem!,
          date: dateController.text,
          dateTimeStarted: startTimeController.text,
          dateTimeEnded: endTimeController.text,
          image: selectedResourceItem['image'] ?? '',
          resourceId: resourceId!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book a Resource"),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField(
              value: selectedResource,
              items: widget.resourceItems.keys.map((resource) {
                return DropdownMenuItem(
                    value: resource, child: Text(resource));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedResource = value as String?;
                  selectedItem = widget.resourceItems[selectedResource]?.first['name'];
                });
              },
              decoration:
              const InputDecoration(labelText: "Select Resource"),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField(
              value: selectedItem,
              items: widget.resourceItems[selectedResource]!
                  .map((item) {
                return DropdownMenuItem(
                  value: item['name'],
                  child: Text(item['name']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedItem = value as String?;
                });
              },
              decoration: const InputDecoration(labelText: "Select Item"),
            ),
            const SizedBox(height: 20),

            TextField(controller: dateController, readOnly: true, onTap: () {
              setState(() {
                isCalendarVisible = !isCalendarVisible;
              });
            }, decoration: const InputDecoration(labelText: "Select Date", suffixIcon: Icon(Icons.calendar_today))),
            if (isCalendarVisible)
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: selectedDate ?? DateTime.now(),
                selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                onDaySelected: (selectedDay, _) {
                  setState(() {
                    selectedDate = selectedDay;
                    dateController.text =
                    "${selectedDay.toLocal()}".split(' ')[0];
                    isCalendarVisible = false;
                  });
                },
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

            TextField(controller: startTimeController, readOnly: true, onTap: () => _selectTime(true), decoration: const InputDecoration(labelText: "Time Started", suffixIcon: Icon(Icons.access_time))),
            const SizedBox(height: 20),
            TextField(controller: endTimeController, readOnly: true, onTap: () => _selectTime(false), decoration: const InputDecoration(labelText: "Time Ended", suffixIcon: Icon(Icons.access_time))),
            const SizedBox(height: 20),

            ElevatedButton(onPressed: confirmBooking, child: const Text("Confirm Booking")),
          ],
        ),
      ),
    );
  }
}
