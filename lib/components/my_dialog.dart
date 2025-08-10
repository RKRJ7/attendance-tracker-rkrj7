import 'package:flutter/material.dart';

class MyDialog extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final String yesText;
  final void Function()? onYes;
  const MyDialog({
    super.key,
    required this.hint,
    required this.controller,
    required this.yesText,
    required this.onYes,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          counterStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          hint: Text(
            hint,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
        maxLength: 30,
        maxLines: 1,
      ),
      actions: [
        //cancel
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            controller.clear();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onYes!();
            controller.clear();
          },
          child: Text(yesText),
        ),
      ],
    );
  }
}
