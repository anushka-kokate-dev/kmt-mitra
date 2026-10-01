import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../change_password_page.dart';

class ProfileMenu {
  static void show(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 10, 0),
      items: <PopupMenuEntry>[
        // 👤 EMAIL
        PopupMenuItem(
          enabled: false,
          child: Text(
            user?.email ?? "Admin",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        const PopupMenuDivider(),

        // 🔐 CHANGE PASSWORD (NEW)
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.lock, color: Colors.blue),
              SizedBox(width: 10),
              Text("Change Password"),
            ],
          ),
          onTap: () {
            // ⚠️ IMPORTANT: delay needed inside showMenu
            Future.delayed(Duration.zero, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              );
            });
          },
        ),

        // 🚪 LOGOUT
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text("Logout"),
            ],
          ),
          onTap: () async {
            await FirebaseAuth.instance.signOut();

            // ⚠️ same fix (delay)
            Future.delayed(Duration.zero, () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminLoginPage(),
                ),
                (route) => false,
              );
            });
          },
        ),
      ],
    );
  }
}
