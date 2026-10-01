import 'ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bus_details_page.dart';
import 'main.dart'; // for AdminLoginPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? fromLocation;
  String? toLocation;

  // 🔥 ADD THIS (LOAD AD WHEN PAGE STARTS)
  @override
  void initState() {
    super.initState();
    AdHelper.loadAd(); // ✅ LOAD INTERSTITIAL AD
  }

  // 🔥 ONLY MAIN STOPS (FIXED)
  Stream<List<String>> getStops() {
    return FirebaseFirestore.instance
        .collection('buses')
        .snapshots()
        .map((snapshot) {
      final Set<String> stopsSet = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data['from'] != null) stopsSet.add(data['from']);
        if (data['to'] != null) stopsSet.add(data['to']);
      }

      final stopsList = stopsSet.toList();
      stopsList.sort();
      return stopsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),

      // 🔵 AppBar
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.notifications),
          ),
        ],
      ),

      // 📂 Drawer
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                ),
              ),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text("Admin Login"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminLoginPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const Text(
              "Find Your Local Bus Easily",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),

            const SizedBox(height: 25),

            // 🔥 STREAM BUILDER
            StreamBuilder<List<String>>(
              stream: getStops(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final stops = snapshot.data!;

                return Column(
                  children: [
                    _buildDropdown("From", fromLocation, stops, (value) {
                      setState(() {
                        fromLocation = value;
                        if (value == toLocation) toLocation = null;
                      });
                    }),
                    const SizedBox(height: 15),
                    _buildDropdown("To", toLocation, stops, (value) {
                      setState(() {
                        toLocation = value;
                        if (value == fromLocation) fromLocation = null;
                      });
                    }),
                  ],
                );
              },
            ),

            const SizedBox(height: 25),

            // 🔍 SEARCH BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (fromLocation == null || toLocation == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select both locations"),
                      ),
                    );
                    return;
                  }

                  if (fromLocation == toLocation) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("From and To cannot be same"),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BusDetailsPage(
                        from: fromLocation!,
                        to: toLocation!,
                      ),
                    ),
                  );
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Search Bus",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  "assets/images/bus.jpeg",
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔽 SAFE DROPDOWN
  Widget _buildDropdown(
    String hint,
    String? selectedValue,
    List<String> stops,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: stops.contains(selectedValue) ? selectedValue : null,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.directions_bus,
            color: Color(0xFF4A90E2),
          ),
          hintText: hint,
        ),
        items: stops
            .where(
              (stop) => stop != (hint == "From" ? toLocation : fromLocation),
            )
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
