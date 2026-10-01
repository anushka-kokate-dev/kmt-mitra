import 'widgets/profile_menu.dart';
import 'package:flutter/material.dart';
import 'add_bus_page.dart';
import 'update_bus_page.dart';
import 'delete_bus_page.dart';
import 'view_bus_page.dart'; // ✅ NEW IMPORT

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              ProfileMenu.show(context);
            },
          )
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
// 🔵 ROW 1
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DashboardCard(
                    title: 'Add Bus',
                    icon: Icons.add,
                    iconBgColor: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddBusPage(),
                        ),
                      );
                    },
                  ),
                  _DashboardCard(
                    title: 'Update Bus',
                    icon: Icons.refresh,
                    iconBgColor: Colors.orange,
                    onTap: () async {
                      final updatedBus = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UpdateBusPage(),
                        ),
                      );

                      if (updatedBus != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Bus updated successfully!"),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 🔵 ROW 2
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DashboardCard(
                    title: 'Delete Bus',
                    icon: Icons.delete,
                    iconBgColor: Colors.red,
                    onTap: () async {
                      final deletedBus = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeleteBusPage(),
                        ),
                      );

                      if (deletedBus != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("Bus $deletedBus deleted successfully!"),
                          ),
                        );
                      }
                    },
                  ),

                  // ✅ NEW VIEW BUSES CARD
                  _DashboardCard(
                    title: 'View Buses',
                    icon: Icons.directions_bus,
                    iconBgColor: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ViewBusesPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconBgColor;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.iconBgColor,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
