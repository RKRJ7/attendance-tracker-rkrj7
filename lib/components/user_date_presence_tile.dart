import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserDatePresenceTile extends StatelessWidget {
  final Timestamp date;
  final bool isPresent;
  const UserDatePresenceTile({super.key, required this.date, required this.isPresent});
  
  String _getFormattedDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('d MMMM yyyy h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.date_range_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        _getFormattedDate(date),
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      trailing: isPresent? const Icon(Icons.check_circle, color: Colors.green): const Icon(Icons.cancel, color: Colors.red),
    );
  }
}
