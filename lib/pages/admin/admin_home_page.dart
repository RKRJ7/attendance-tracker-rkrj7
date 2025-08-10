import 'package:attendance_tracker/components/my_admin_drawer.dart';
import 'package:attendance_tracker/components/my_course_tile.dart';
import 'package:attendance_tracker/components/my_dialog.dart';
import 'package:attendance_tracker/models/course.dart';
import 'package:attendance_tracker/models/user.dart';
import 'package:attendance_tracker/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late final _dbProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );
  late final _dbListener = Provider.of<DatabaseProvider>(context);

  UserProfile? user;
  List<CourseModel> courses = [];
  final createCourseCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    super.dispose();
    createCourseCont.dispose();
  }

  _loadCourses() async {
    final x = await _dbProvider.getUserProfile();
    await _dbProvider.loadAdminCourses();
    setState(() {
      courses = _dbProvider.adminCourses;
      user = x;
    });
  }

  _createCourse() async {
    final courseName = createCourseCont.text.trim();
    if (courseName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a course name")));
      return;
    }
    try {
      if (user != null) {
        await _dbProvider.createCourse(
          courseName: courseName,
          adminName: user!.name,
        );
        createCourseCont.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error creating course: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final thData = Theme.of(context).colorScheme;
    courses = _dbListener.adminCourses;
    return Scaffold(
      backgroundColor: thData.surface,
      appBar: AppBar(
        title: Text(
          user == null ? 'Admin Home' : user!.name,
          style: TextStyle(color: thData.primary),
        ),
      ),
      drawer: const MyAdminDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => MyDialog(
              hint: 'Enter course name',
              controller: createCourseCont,
              yesText: 'Create',
              onYes: () {
                _createCourse();
              },
            ),
          );
        },
        backgroundColor: thData.primary,
        child: Icon(Icons.add, color: thData.secondary),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return MyCourseTile(course: course);
          },
        ),
      ),
    );
  }
}
