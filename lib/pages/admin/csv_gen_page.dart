import 'dart:io';
import 'package:attendance_tracker/models/course.dart';
import 'package:attendance_tracker/models/session.dart';
import 'package:attendance_tracker/models/user.dart';
import 'package:attendance_tracker/services/database/database_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';

class CsvGenPage extends StatefulWidget {
  final CourseModel course;
  const CsvGenPage({super.key, required this.course});

  @override
  State<CsvGenPage> createState() => _CsvGenPageState();
}

class _CsvGenPageState extends State<CsvGenPage> {
  late final _dbProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );

  String _getFormattedDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('d MMMM yyyy h:mm a').format(date);
  }

  _generateCsv() async {
    List<SessionModel> sessions = [];
    List<UserProfile> enrolledStudents = [];
    List<List<String>> rows = [];
    List<String> headers = ['Student', 'Email'];
    try {
      sessions = _dbProvider.getCourseSessions(widget.course.courseId);
      await _dbProvider.loadEnrolledStudents(widget.course.courseId);
      enrolledStudents = _dbProvider.getEnrolledStudents(
        widget.course.courseId,
      );

      for (var session in sessions) {
        headers.add(_getFormattedDate(session.timestamp));
      }
      rows.add(headers);

      for (var student in enrolledStudents) {
        List<String> studRow = [student.name, student.email];
        for (var session in sessions) {
          if (session.presentStudents.contains(student.uid)) {
            studRow.add('Present');
          } else {
            studRow.add('Absent');
          }
        }
        rows.add(studRow);
      }

      String csvData = const ListToCsvConverter().convert(rows);

      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/firestore_export.csv");
      await file.writeAsString(csvData);

      await SharePlus.instance.share(
        ShareParams(
          text: "CSV for ${widget.course.courseName}",
          files: [XFile(file.path)],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to generate CSV: $e")));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _generateCsv();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'CSV Generation',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Please wait while we generate the CSV for you. Download will start soon ...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
      ),
    );
  }
}
