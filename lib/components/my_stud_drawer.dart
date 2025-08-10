import 'package:attendance_tracker/pages/settings_page.dart';
import 'package:attendance_tracker/pages/user/qr_scanner_page.dart';
import 'package:attendance_tracker/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class MyStudDrawer extends StatelessWidget {
  const MyStudDrawer({super.key});

  Future<void> _logout() async {
    await AuthService().logout();
  }

  @override
  Widget build(BuildContext context) {
    final thData = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: thData.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            DrawerHeader(
              child: Icon(Icons.person, size: 100, color: thData.primary),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.home, color: thData.primary),
              title: Text(
                'Home',
                style: TextStyle(color: thData.inversePrimary),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.qr_code_scanner, color: thData.primary),
              title: Text(
                'Scan QR',
                style: TextStyle(color: thData.inversePrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QrScannerPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: thData.primary),
              title: Text(
                'Settings',
                style: TextStyle(color: thData.inversePrimary),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            const Spacer(),
            ListTile(
              leading: Icon(Icons.logout, color: thData.primary),
              title: Text(
                'Logout',
                style: TextStyle(color: thData.inversePrimary),
              ),
              onTap: () {
                _logout();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
