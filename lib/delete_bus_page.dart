import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/profile_menu.dart';
import 'package:flutter/material.dart';

class DeleteBusPage extends StatefulWidget {
  const DeleteBusPage({Key? key}) : super(key: key);

  @override
  State<DeleteBusPage> createState() => _DeleteBusPageState();
}

class _DeleteBusPageState extends State<DeleteBusPage> {
  String? selectedBus; // stores document ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delete Bus"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                ProfileMenu.show(context);
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue),
              ),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete, color: Colors.red, size: 60),
              const SizedBox(height: 15),
              const Text(
                "Delete Bus",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Are you sure you want to delete this bus?",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.lightBlueAccent),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('buses')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("No buses available"),
                      );
                    }

                    final buses = snapshot.data!.docs;

                    final validBusIds = buses.map((doc) => doc.id).toList();

                    final safeValue =
                        validBusIds.contains(selectedBus) ? selectedBus : null;

                    return DropdownButton<String>(
                      value: safeValue,
                      hint: const Text("Select Bus Number"),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: buses.map((doc) {
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: SizedBox(
                            height: 30,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(doc['busNo']),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBus = value;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () async {
                  if (selectedBus == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select a bus")),
                    );
                    return;
                  }

                  try {
                    await FirebaseFirestore.instance
                        .collection('buses')
                        .doc(selectedBus)
                        .delete();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Bus deleted successfully")),
                    );

                    setState(() {
                      selectedBus = null;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error deleting bus")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Delete Bus",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Cancel"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
