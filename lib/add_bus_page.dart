import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/profile_menu.dart';
import 'package:flutter/material.dart';

class AddBusPage extends StatefulWidget {
  const AddBusPage({super.key});

  @override
  State<AddBusPage> createState() => _AddBusPageState();
}

class _AddBusPageState extends State<AddBusPage> {
  final TextEditingController busNoController = TextEditingController();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController departureTimeController = TextEditingController();
  final TextEditingController arrivalTimeController = TextEditingController();

  List<Map<String, TextEditingController>> stops = [];

  void addStop() {
    setState(() {
      stops.add({
        "name": TextEditingController(),
        "departure": TextEditingController(),
      });
    });
  }

  Future<void> selectTime(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  Widget buildTextField(String hint, TextEditingController controller,
      {double height = 50}) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget buildTimeField(TextEditingController controller, String hint,
      {double height = 50}) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () => selectTime(controller),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: const Icon(Icons.access_time, color: Colors.black),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
        ),
      ),
    );
  }

  TimeOfDay? parseTime(String timeText) {
    try {
      final parts = timeText.split(RegExp(r'[: ]'));
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      if (parts[2].toLowerCase() == 'pm' && hour != 12) hour += 12;
      if (parts[2].toLowerCase() == 'am' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  bool isTimeBefore(TimeOfDay start, TimeOfDay end) {
    return start.hour < end.hour ||
        (start.hour == end.hour && start.minute < end.minute);
  }

  void saveBus() async {
    if (busNoController.text.trim().isEmpty ||
        fromController.text.trim().isEmpty ||
        toController.text.trim().isEmpty ||
        departureTimeController.text.trim().isEmpty ||
        arrivalTimeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all main bus details")),
      );
      return;
    }

    final depTime = parseTime(departureTimeController.text);
    final arrTime = parseTime(arrivalTimeController.text);
    if (depTime == null || arrTime == null || !isTimeBefore(depTime, arrTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Arrival time must be after departure time")),
      );
      return;
    }

    // Validate stops only if any stops exist
    for (int i = 0; i < stops.length; i++) {
      final name = stops[i]["name"]!.text.trim();
      final timeText = stops[i]["departure"]!.text.trim();
      if (name.isEmpty || timeText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill stop ${i + 1} details")),
        );
        return;
      }
      final stopTime = parseTime(timeText);
      if (stopTime == null ||
          !isTimeBefore(depTime, stopTime) ||
          !isTimeBefore(stopTime, arrTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Stop ${i + 1} time must be between departure and arrival")),
        );
        return;
      }
    }

    List<Map<String, String>> stopsData = stops.map((stop) {
      return {
        "name": stop["name"]!.text.trim(),
        "departure": stop["departure"]!.text
      };
    }).toList();

    try {
      await FirebaseFirestore.instance.collection('buses').add({
        "busNo": busNoController.text.trim(),
        "from": fromController.text.trim(),
        "to": toController.text.trim(),
        "departure": departureTimeController.text,
        "arrival": arrivalTimeController.text,
        "stops": stopsData,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bus Saved Successfully")),
      );

      // Clear all controllers
      busNoController.clear();
      fromController.clear();
      toController.clear();
      departureTimeController.clear();
      arrivalTimeController.clear();
      for (var stop in stops) {
        stop["name"]!.clear();
        stop["departure"]!.clear();
      }

      setState(() {
        stops = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error saving bus")),
      );
    }
  }

  @override
  void dispose() {
    busNoController.dispose();
    fromController.dispose();
    toController.dispose();
    departureTimeController.dispose();
    arrivalTimeController.dispose();
    for (var stop in stops) {
      stop["name"]!.dispose();
      stop["departure"]!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double stopFieldHeight = 50;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text("Add Bus Details"),
        backgroundColor: const Color(0xFF4A90E2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => ProfileMenu.show(context),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF4A90E2)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.directions_bus,
                  size: 50, color: Color(0xFF4A90E2)),
              const SizedBox(height: 10),
              const Text("Add Bus Details",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text("Enter From, To, and all stops with timings",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              buildTextField("Bus Number", busNoController),
              const SizedBox(height: 10),
              buildTextField("From", fromController),
              const SizedBox(height: 10),
              buildTextField("To", toController),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: buildTimeField(
                          departureTimeController, "Departure Time")),
                  const SizedBox(width: 12),
                  Expanded(
                      child: buildTimeField(
                          arrivalTimeController, "Arrival Time")),
                ],
              ),
              if (stops.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFF357ABD)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                          child: Center(
                              child: Text("Stop Name",
                                  style: TextStyle(color: Colors.white)))),
                      Expanded(
                          child: Center(
                              child: Text("Departure Time",
                                  style: TextStyle(color: Colors.white)))),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: List.generate(stops.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.blue,
                            child: Text("${index + 1}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 5,
                            child: buildTextField(
                                "Enter stop name", stops[index]["name"]!,
                                height: stopFieldHeight),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 5,
                            child: buildTimeField(
                                stops[index]["departure"]!, "Departure",
                                height: stopFieldHeight),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
              const SizedBox(height: 10),
              GestureDetector(
                onTap: addStop,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                      child: Text("+ Add Another Stop",
                          style: TextStyle(color: Colors.blue))),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveBus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Add Bus",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
