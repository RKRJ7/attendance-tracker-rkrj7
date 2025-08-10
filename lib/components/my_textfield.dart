import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obsecure;
  const MyTextfield({
    super.key,
    required this.controller,
    required this.hint,
    required this.obsecure,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obsecure,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        fillColor: Theme.of(context).colorScheme.secondary,
        filled: true,
        hint: Text(
          hint,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.primary),
    );
  }
}
