import 'package:attendance_tracker/components/my_session_tile.dart';
import 'package:attendance_tracker/models/course.dart';
import 'package:attendance_tracker/models/session.dart';
import 'package:attendance_tracker/pages/admin/csv_gen_page.dart';
import 'package:attendance_tracker/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminCoursePage extends StatefulWidget {
  final CourseModel course;
  const AdminCoursePage({super.key, required this.course});

  @override
  State<AdminCoursePage> createState() => _AdminCoursePageState();
}

class _AdminCoursePageState extends State<AdminCoursePage> {
  late final _dbProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );
  late final _dbListener = Provider.of<DatabaseProvider>(context);

  List<SessionModel> sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  _loadSessions() async {
    await _dbProvider.loadCourseSessions(widget.course.courseId);
    setState(() {
      sessions = _dbProvider.getCourseSessions(widget.course.courseId);
    });
  }

  _createNewSession() async {
    try {
      await _dbProvider.createSession(courseId: widget.course.courseId);
      // _loadSessions(); // Refresh the session list after creating a new session
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to create session: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final thData = Theme.of(context).colorScheme;
    sessions = _dbListener.getCourseSessions(widget.course.courseId);

    return Scaffold(
      backgroundColor: thData.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CsvGenPage(course: widget.course),
            ),
          );
        },
        backgroundColor: thData.primary,
        child: Icon(Icons.download_rounded, color: thData.secondary),
      ),
      appBar: AppBar(
        title: Text(
          widget.course.courseName,
          style: TextStyle(color: thData.primary),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Create New Session',
                        style: TextStyle(color: thData.primary),
                      ),
                      content: Text(
                        'Do you want to start a new session?',
                        style: TextStyle(color: thData.primary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _createNewSession();
                            Navigator.pop(context);
                          },
                          child: const Text('Create'),
                        ),
                      ],
                    ),
                  );
                },
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
                      'Start a new session',
                      style: TextStyle(color: thData.tertiary, fontSize: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total enrolled students: ${widget.course.enrolledStudents.length}',
                style: TextStyle(color: thData.primary, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return MySessionTile(session: session);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
