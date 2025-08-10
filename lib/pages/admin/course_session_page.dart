import 'dart:convert';

import 'package:attendance_tracker/models/session.dart';
import 'package:attendance_tracker/models/user.dart';
import 'package:attendance_tracker/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';

class CourseSessionPage extends StatefulWidget {
  final SessionModel session;
  const CourseSessionPage({super.key, required this.session});

  @override
  State<CourseSessionPage> createState() => _CourseSessionPageState();
}

class _CourseSessionPageState extends State<CourseSessionPage> {
  late final _dbProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );
  late final _dbListener = Provider.of<DatabaseProvider>(context);

  List<UserProfile?> enrolledStudents = [];

  @override
  void initState() {
    super.initState();
    _loadEnrolledStudents();
  }

  _loadEnrolledStudents() async {
    try {
      await _dbProvider.loadEnrolledStudents(widget.session.courseId);
      setState(() {
        enrolledStudents = _dbProvider.getEnrolledStudents(
          widget.session.courseId,
        );
      });
    } catch (e) {
      print("Error loading enrolled students: $e");
    }
  }

  void _onGenerateQRCode() {
    final sessionId = widget.session.sessionId;
    final courseId = widget.session.courseId;
    final time = DateTime.now().millisecondsSinceEpoch;

    final String qrData = jsonEncode({
      'sessionId': sessionId,
      'courseId': courseId,
      'time': time,
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 224, 224, 224),
          title: Text(
            'Here is the QR Code',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'The QR code is only valid for 5 minutes from generation.',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 10),
              PrettyQrView.data(data: qrData),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    enrolledStudents = _dbListener.getEnrolledStudents(widget.session.courseId);
    final thData = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: thData.surface,
      appBar: AppBar(
        title: Text(
          'Course Session',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _onGenerateQRCode,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                height: 65,
                decoration: BoxDecoration(
                  color: thData.primary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: thData.secondary),
                  boxShadow: [
                    BoxShadow(
                      color: thData.inversePrimary,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Generate QR Code of Session',
                    style: TextStyle(color: thData.tertiary, fontSize: 18),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: enrolledStudents.length,
                itemBuilder: (context, index) {
                  final student = enrolledStudents[index];
                  final bool isPresent = widget.session.isStudentPresent(
                    student!.uid,
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      tileColor: thData.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(
                        student.name,
                        style: TextStyle(
                          color: isPresent ? Colors.green : Colors.red,
                          fontSize: 18,
                        ),
                      ),

                      subtitle: Text(
                        'Status: ${isPresent ? 'Present' : 'Absent'}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
