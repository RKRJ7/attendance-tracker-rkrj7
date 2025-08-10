import 'package:attendance_tracker/components/my_button.dart';
import 'package:attendance_tracker/components/my_textfield.dart';
import 'package:attendance_tracker/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final void Function()? toggle;
  const LoginPage({super.key, required this.toggle});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();
  final emailcont = TextEditingController();
  final passcont = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailcont.dispose();
    passcont.dispose();
  }

  Future<void> _login() async {
    final email = emailcont.text.trim();
    final password = passcont.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill in all fields")));
      return;
    }

    try {
      await _auth.loginEmailPassword(email, password);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final thData = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: thData.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, color: thData.primary, size: 120),
                const SizedBox(height: 10),
                Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 16, color: thData.primary),
                ),
                const SizedBox(height: 5),
                Text(
                  'Login to RKRJ7 attendance tracker',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: thData.primary,
                  ),
                ),
                const SizedBox(height: 15),
                MyTextfield(
                  controller: emailcont,
                  hint: 'Enter email',
                  obsecure: false,
                ),
                const SizedBox(height: 10),
                MyTextfield(
                  controller: passcont,
                  hint: 'Enter password',
                  obsecure: true,
                ),
                const SizedBox(height: 15),
                MyButton(
                  label: 'Login',
                  onTap: () {
                    _login();
                  },
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: widget.toggle,
                  child: Text(
                    'New here? Register now',
                    style: TextStyle(
                      color: thData.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
