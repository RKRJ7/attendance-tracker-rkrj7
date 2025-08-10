import 'package:attendance_tracker/models/user.dart';
import 'package:attendance_tracker/pages/admin/admin_home_page.dart';
import 'package:attendance_tracker/pages/user/user_home_page.dart';
import 'package:attendance_tracker/services/database/database_provider.dart';
import 'package:flutter/material.dart';

class AdminOrUser extends StatefulWidget {
  final String uid;
  const AdminOrUser({super.key, required this.uid});

  @override
  State<AdminOrUser> createState() => _AdminOrUserState();
}

class _AdminOrUserState extends State<AdminOrUser> {
  final _db = DatabaseProvider();

  UserProfile? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    isLoading = false;
  }

  Future<void> _fetchUserProfile() async {
    try {
      user = await _db.getUserProfile();
      if (user == null) {
        print("User not found");
      } else {
        print("User profile fetched: ${user!.name}, Role: ${user!.role}");
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading || user == null
        ? Scaffold(
            body: Center(
              child: Text(
                'Loading ...',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
          )
        : user!.role == UserRole.admin
        ? AdminHomePage()
        : UserHomePage(user: user!,);
  }
}
