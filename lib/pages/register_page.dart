import 'package:attendance_tracker/components/my_button.dart';
import 'package:attendance_tracker/components/my_textfield.dart';
import 'package:attendance_tracker/services/auth/auth_service.dart';
import 'package:attendance_tracker/services/database/database_service.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? toggle;
  const RegisterPage({super.key, required this.toggle});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final namecont = TextEditingController();
  final emailcont = TextEditingController();
  final passcont = TextEditingController();
  final cnfpasscont = TextEditingController();

  final _auth = AuthService();
  final _db = DatabaseService();

  @override
  void dispose() {
    super.dispose();
    namecont.dispose();
    emailcont.dispose();
    passcont.dispose();
    cnfpasscont.dispose();
  }

  Future<void> _register(bool isAdmin) async {
    final name = namecont.text.trim();
    final email = emailcont.text.trim();
    final password = passcont.text.trim();
    final confirmPassword = cnfpasscont.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill in all fields")));
      return;
    }

    try {
      await _auth.registerEmailPassword(email, password);
      await _db.saveUserInfoInFirebase(
        email: email,
        name: name,
        isAdmin: isAdmin,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Registration failed: $e")));
      }
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
                  'Hi there, Welcome!',
                  style: TextStyle(fontSize: 16, color: thData.primary),
                ),
                const SizedBox(height: 5),
                Text(
                  'Let\'s get you started',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: thData.primary,
                  ),
                ),
                const SizedBox(height: 15),
                MyTextfield(
                  controller: namecont,
                  hint: 'Enter name',
                  obsecure: false,
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                MyTextfield(
                  controller: cnfpasscont,
                  hint: 'Confirm password',
                  obsecure: true,
                ),
                const SizedBox(height: 15),
                Text(
                  'Register as',
                  style: TextStyle(
                    fontSize: 18,
                    color: thData.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.4,
                      child: MyButton(
                        label: 'Student',
                        onTap: () {
                          _register(false);
                        },
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.4,
                      child: MyButton(
                        label: 'Admin',
                        onTap: () {
                          _register(true);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: widget.toggle,
                  child: Text(
                    'Have an account? Login',
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
