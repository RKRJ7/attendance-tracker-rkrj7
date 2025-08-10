import 'package:attendance_tracker/components/my_dialog.dart';
import 'package:attendance_tracker/components/my_stud_drawer.dart';
import 'package:attendance_tracker/components/user_course_tile.dart';
import 'package:attendance_tracker/models/course.dart';
import 'package:attendance_tracker/models/user.dart';
import 'package:attendance_tracker/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserHomePage extends StatefulWidget {
  final UserProfile user;
  const UserHomePage({super.key, required this.user});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  late final _dbProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );
  late final _dbListener = Provider.of<DatabaseProvider>(context);

  final enrollcont = TextEditingController();

  List<CourseModel> courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    super.dispose();
    enrollcont.dispose();
  }

  _loadCourses() async {
    await _dbProvider.loadStudentCourses(widget.user.uid);
    setState(() {
      courses = _dbProvider.studentCourses;
    });
  }

  @override
  Widget build(BuildContext context) {
    final thData = Theme.of(context).colorScheme;
    courses = _dbListener.studentCourses;
    return Scaffold(
      backgroundColor: thData.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) => MyDialog(
              hint: 'Enter course id to enroll',
              controller: enrollcont,
              yesText: 'Enroll',
              onYes: () async {
                final courseId = enrollcont.text.trim();
                if (courseId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a course ID")),
                  );
                  return;
                }
                try {
                  await _dbProvider.enrollInCourse(courseId);
                } catch (e) {
                  if (!mounted) return; // guard before using context
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error enrolling in course: $e")),
                  );
                }
              },
            ),
          );
        },
        backgroundColor: thData.primary,
        child: Icon(Icons.add, color: thData.secondary),
      ),
      appBar: AppBar(
        title: Text(widget.user.name, style: TextStyle(color: thData.primary)),
      ),

      drawer: const MyStudDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return UserCourseTile(course: course);
            },
          ),
        ),
      ),
    );
  }
}
