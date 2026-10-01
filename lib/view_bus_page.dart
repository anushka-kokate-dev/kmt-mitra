import 'ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'inner_route_page.dart';

class ViewBusesPage extends StatefulWidget {
  const ViewBusesPage({super.key});

  @override
  State<ViewBusesPage> createState() => _ViewBusesPageState();
}

class _ViewBusesPageState extends State<ViewBusesPage> {
  final TextEditingController fromSearchController = TextEditingController();
  final TextEditingController toSearchController = TextEditingController();

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
  void dispose() {
    fromSearchController.dispose();
    toSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text("All Buses"),
        centerTitle: true,
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
          children: [
            // 🔍 SEARCH
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: fromSearchController,
                    decoration: InputDecoration(
                      hintText: "From",
                      prefixIcon:
                          const Icon(Icons.location_on, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: toSearchController,
                    decoration: InputDecoration(
                      hintText: "To",
                      prefixIcon:
                          const Icon(Icons.location_on, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 🔢 TOTAL COUNT
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('buses').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final buses = snapshot.data!.docs;

                final filtered = buses.where((bus) {
                  final data = bus.data() as Map<String, dynamic>;

                  if (!data.containsKey('from') || !data.containsKey('to')) {
                    return false;
                  }

                  final fromText = data['from'].toLowerCase();
                  final toText = data['to'].toLowerCase();

                  final fromFilter = fromSearchController.text.toLowerCase();
                  final toFilter = toSearchController.text.toLowerCase();

                  return (fromFilter.isEmpty ||
                          fromText.contains(fromFilter)) &&
                      (toFilter.isEmpty || toText.contains(toFilter));
                }).toList();

                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "🚌 Total Buses: ${filtered.length}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // 📋 LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('buses')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final buses = snapshot.data!.docs;

                  final filtered = buses.where((bus) {
                    final data = bus.data() as Map<String, dynamic>;

                    if (!data.containsKey('busNo') ||
                        !data.containsKey('from') ||
                        !data.containsKey('to') ||
                        !data.containsKey('departure') ||
                        !data.containsKey('arrival')) {
                      return false;
                    }

                    final fromText = data['from'].toLowerCase();
                    final toText = data['to'].toLowerCase();

                    final fromFilter = fromSearchController.text.toLowerCase();
                    final toFilter = toSearchController.text.toLowerCase();

                    return (fromFilter.isEmpty ||
                            fromText.contains(fromFilter)) &&
                        (toFilter.isEmpty || toText.contains(toFilter));
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text("No buses available"));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final bus = filtered[index];
                      final data = bus.data() as Map<String, dynamic>;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔵 NUMBER BADGE
                          Container(
                            margin: const EdgeInsets.only(top: 20, right: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF357ABD),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // 🚌 CARD
                          Expanded(
                            child: BusCard(
                              busNo: data['busNo'],
                              from: data['from'],
                              to: data['to'],
                              time: "${data['departure']} → ${data['arrival']}",
                              duration: calculateDuration(
                                  data['departure'], data['arrival']),
                              busId: bus.id,
                            ),
                          ),
                        ],
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

// 🚌 BUS CARD
class BusCard extends StatelessWidget {
  final String busNo;
  final String from;
  final String to;
  final String time;
  final String duration;
  final String busId;

  const BusCard({
    super.key,
    required this.busNo,
    required this.from,
    required this.to,
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
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text("$from → $to")),
            ],
          ),
          const SizedBox(height: 8),
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
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
              ),
              onPressed: () {
                AdHelper.showAd(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InnerRoutePage(busId: busId),
                    ),
                  );
                });
              },
              child: const Text("View"),
            ),
          ),
        ],
      ),
    );
  }
}
