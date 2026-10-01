import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ad_helper.dart'; // 🔥 ADD THIS

class InnerRoutePage extends StatefulWidget {
  final String busId;

  const InnerRoutePage({super.key, required this.busId});

  @override
  State<InnerRoutePage> createState() => _InnerRoutePageState();
}

class _InnerRoutePageState extends State<InnerRoutePage> {
  // 🔥 SHOW AD WHEN PAGE OPENS
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      AdHelper.showAd(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text("Bus Details"),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
            ),
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('buses')
            .doc(widget.busId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final busNo = data['busNo'] ?? '';
          final departure = data['departure'] ?? '';
          final arrival = data['arrival'] ?? '';
          final stops = data['stops'] ?? [];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🚌 Bus Number
                Row(
                  children: [
                    const Icon(Icons.directions_bus, color: Color(0xFF4A90E2)),
                    const SizedBox(width: 8),
                    Text(
                      "Bus No: $busNo",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ⏱️ Time
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        (arrival == null || arrival.toString().trim().isEmpty)
                            ? departure
                            : "$departure → $arrival",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Inner Route Times",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                // 📍 Stops List
                Expanded(
                  child: stops.isEmpty
                      ? const Center(child: Text("No stops available"))
                      : ListView.builder(
                          itemCount: stops.length,
                          itemBuilder: (context, index) {
                            final stop = stops[index];

                            final dep = stop['departure'] ?? '';
                            final arr = stop['arrival'];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Color(0xFF4A90E2),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        stop['name'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    (arr == null ||
                                            arr.toString().trim().isEmpty)
                                        ? dep
                                        : "$dep → $arr",
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
