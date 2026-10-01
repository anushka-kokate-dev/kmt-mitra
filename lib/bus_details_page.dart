import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'inner_route_page.dart';

class BusDetailsPage extends StatelessWidget {
  final String from;
  final String to;

  const BusDetailsPage({
    super.key,
    required this.from,
    required this.to,
  });

  DateTime _parseTime(String time) {
    final parts = time.split(' ');
    final hm = parts[0].split(':');

    int hour = int.parse(hm[0]);
    int minute = int.parse(hm[1]);

    if (parts[1] == "PM" && hour != 12) hour += 12;
    if (parts[1] == "AM" && hour == 12) hour = 0;

    return DateTime(2024, 1, 1, hour, minute);
  }

  String calculateDuration(String departure, String arrival) {
    try {
      DateTime dep = _parseTime(departure);
      DateTime arr = _parseTime(arrival);

      final diff = arr.difference(dep);

      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;

      if (hours == 0) return "$minutes min";
      return "$hours hr ${minutes} min";
    } catch (e) {
      return "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text("Bus Details"),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bus Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Showing buses from\n$from → $to",
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('buses')
                    .where('from', isEqualTo: from)
                    .where('to', isEqualTo: to)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final buses = snapshot.data!.docs;

                  if (buses.isEmpty) {
                    return const Center(
                      child: Text("No buses available"),
                    );
                  }

                  return ListView.builder(
                    itemCount: buses.length,
                    itemBuilder: (context, index) {
                      final bus = buses[index];
                      final data = bus.data() as Map<String, dynamic>;

                      final departure = data['departure'] ?? '';
                      final arrival = data['arrival'] ?? '';

                      return BusCard(
                        busNo: data['busNo'] ?? '',
                        time: "$departure → $arrival",
                        duration: calculateDuration(departure, arrival),
                        busId: bus.id,
                      );
                    },
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

class BusCard extends StatelessWidget {
  final String busNo;
  final String time;
  final String duration;
  final String busId;

  const BusCard({
    super.key,
    required this.busNo,
    required this.time,
    required this.duration,
    required this.busId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_bus, color: Color(0xFF4A90E2)),
              const SizedBox(width: 8),
              Text(
                "Bus No: $busNo",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.orange),
              const SizedBox(width: 8),
              Text(time),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            "Duration: $duration",
            style: const TextStyle(color: Colors.black54),
          ),
          const Divider(height: 20),

          // 🔥 ONLY CHANGE DONE HERE
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InnerRoutePage(busId: busId),
                  ),
                );
              },
              child: const Text("View"),
            ),
          ),
        ],
      ),
    );
  }
}
