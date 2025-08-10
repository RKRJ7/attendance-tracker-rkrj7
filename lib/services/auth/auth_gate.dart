import 'package:attendance_tracker/services/auth/admin_or_user.dart';
import 'package:attendance_tracker/services/auth/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return AdminOrUser(uid: snapshot.data!.uid);
        } else {
          return const LoginOrRegister();
        }
      },
    );
  }
}
