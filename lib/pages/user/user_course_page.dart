import 'package:attendance_tracker/components/user_date_presence_tile.dart';
import 'package:attendance_tracker/models/course.dart';
import 'package:attendance_tracker/models/session.dart';
import 'package:attendance_tracker/models/student_attendance.dart';
import 'package:attendance_tracker/services/database/database_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserCoursePage extends StatefulWidget {
  final CourseModel course;
  const UserCoursePage({super.key, required this.course});

  @override
  State<UserCoursePage> createState() => _UserCoursePageState();
}

class _UserCoursePageState extends State<UserCoursePage> {
  late final _dbProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );

  List<SessionModel> sessions = [];
  late Future<StudentAttendance> attendanceF;

  @override
  void initState() {
    super.initState();
    attendanceF = _loadAttendance();
    _loadSessions();
  }

  Future<StudentAttendance> _loadAttendance() async {
    await _dbProvider.loadStudentAttendance(widget.course.courseId);
    return _dbProvider.getStudentAttendance(widget.course.courseId);
  }

  _loadSessions() async {
    await _dbProvider.loadCourseSessions(widget.course.courseId);
    setState(() {
      sessions = _dbProvider.getCourseSessions(widget.course.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final devSize = MediaQuery.of(context).size;
    final thData = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: thData.surface,
      appBar: AppBar(
        title: Text(
          widget.course.courseName,
          style: TextStyle(color: thData.primary),
        ),
      ),
      body: FutureBuilder(
        future: attendanceF,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading attendance',
                style: TextStyle(color: thData.error),
              ),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'No attendance data available',
                style: TextStyle(color: thData.onSurface),
              ),
            );
          }
          final attendance = snapshot.data!;
          final totalSessions = sessions.length;
          final presentCount = attendance.attendanceCount;
          if (totalSessions == 0) {
            return Center(
              child: Text(
                'No sessions available for this course',
                style: TextStyle(color: thData.primary),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: thData.secondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: thData.tertiary),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Sessions: $totalSessions',
                          style: TextStyle(color: thData.primary, fontSize: 20),
                        ),
                        Text(
                          'Present Sessions: $presentCount',
                          style: TextStyle(color: thData.primary, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Attendance percentage:',
                    style: TextStyle(
                      color: thData.inversePrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    height: devSize.height * 0.3,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: thData.secondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: thData.tertiary),
                    ),

                    child: SizedBox(
                      width: 100, // your desired width
                      height: 100, // your desired height
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: Colors.red,
                              value: (totalSessions - presentCount).toDouble(),
                              title:
                                  '${(totalSessions - presentCount) * 100 ~/ totalSessions}%',
                              radius: devSize.width * 0.12,
                            ),
                            PieChartSectionData(
                              color: Colors.green,
                              value: presentCount.toDouble(),
                              title: '${presentCount * 100 ~/ totalSessions}%',
                              radius: devSize.width * 0.12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return UserDatePresenceTile(
                        date: session.timestamp,
                        isPresent: attendance.isPresent(session.sessionId),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
