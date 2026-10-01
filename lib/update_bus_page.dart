import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/profile_menu.dart';

class UpdateBusPage extends StatefulWidget {
  const UpdateBusPage({super.key});

  @override
  State<UpdateBusPage> createState() => _UpdateBusPageState();
}

class _UpdateBusPageState extends State<UpdateBusPage> {
  String? selectedBusId;

  final busNoController = TextEditingController();
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final departureController = TextEditingController();
  final arrivalController = TextEditingController();

  List<Map<String, TextEditingController>> stops = [];

  @override
  void initState() {
    super.initState();
    addStop();
  }

  void addStop() {
    setState(() {
      stops.add({
        "name": TextEditingController(),
        "departure": TextEditingController(),
      });
    });
  }

  void removeStop(int index) {
    stops[index]["name"]!.dispose();
    stops[index]["departure"]!.dispose();
    setState(() => stops.removeAt(index));
  }

  Future<void> selectTime(TextEditingController controller) async {
    TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  Widget buildField(
    String hint,
    TextEditingController controller, {
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
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
    );
  }

  Future<void> loadBusData(String id) async {
    var doc =
        await FirebaseFirestore.instance.collection('buses').doc(id).get();
    var data = doc.data();
    if (data == null) return;

    busNoController.text = data['busNo'] ?? '';
    fromController.text = data['from'] ?? '';
    toController.text = data['to'] ?? '';
    departureController.text = data['departure'] ?? '';
    arrivalController.text = data['arrival'] ?? '';

    stops.clear();
    if (data['stops'] != null) {
      for (var stop in data['stops']) {
        stops.add({
          "name": TextEditingController(text: stop['name']),
          "departure": TextEditingController(text: stop['departure']),
        });
      }
    } else {
      addStop();
    }
    setState(() {});
  }

  void updateBus() async {
    if (selectedBusId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a bus")),
      );
      return;
    }

    List<Map<String, String>> stopsData = stops.map((s) {
      return {
        "name": s["name"]!.text.trim(),
        "departure": s["departure"]!.text.trim(),
      };
    }).toList();

    await FirebaseFirestore.instance
        .collection('buses')
        .doc(selectedBusId)
        .update({
      "busNo": busNoController.text.trim(),
      "from": fromController.text.trim(),
      "to": toController.text.trim(),
      "departure": departureController.text,
      "arrival": arrivalController.text,
      "stops": stopsData,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bus Updated Successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text("Update Bus"),
        backgroundColor: const Color(0xFF4A90E2),
        actions: [
          GestureDetector(
            onTap: () => ProfileMenu.show(context),
            child: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: CircleAvatar(
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
            children: [
              const Icon(Icons.directions_bus,
                  size: 50, color: Color(0xFF4A90E2)),
              const SizedBox(height: 10),
              const Text("Update Bus Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('buses').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final buses = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    value: selectedBusId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    isExpanded: true,
                    hint: const Text("Select Bus"),
                    items: buses.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: SizedBox(
                          height: 30,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              doc['busNo'],
                              style: const TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBusId = value;
                      });
                      if (value != null) loadBusData(value);
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              buildField("Bus Number", busNoController),
              const SizedBox(height: 10),
              buildField("From", fromController),
              const SizedBox(height: 10),
              buildField("To", toController),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: buildField(
                      "Departure",
                      departureController,
                      readOnly: true,
                      onTap: () => selectTime(departureController),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildField(
                      "Arrival",
                      arrivalController,
                      readOnly: true,
                      onTap: () => selectTime(arrivalController),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text("Stop Name",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text("Departure Time",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: List.generate(stops.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: buildField("Stop Name", stops[index]["name"]!),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: buildField(
                            "Departure",
                            stops[index]["departure"]!,
                            readOnly: true,
                            onTap: () => selectTime(stops[index]["departure"]!),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeStop(index),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: addStop,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text("+ Add Another Stop",
                        style: TextStyle(color: Colors.blue)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateBus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Update Bus",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
