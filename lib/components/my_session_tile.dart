import 'package:attendance_tracker/models/session.dart';
import 'package:attendance_tracker/pages/admin/course_session_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MySessionTile extends StatelessWidget {
  final SessionModel session;
  const MySessionTile({super.key, required this.session});

  String _getFormattedDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('d MMMM yyyy h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseSessionPage(session: session),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 15, 10, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
          borderRadius: BorderRadius.circular(12),
        ),
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  _getFormattedDate(session.timestamp),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Present Count: ${session.presentCount}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),

            Icon(
              Icons.event_note_rounded,
              color: Theme.of(context).colorScheme.tertiary,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }
}
