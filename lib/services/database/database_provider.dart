import 'dart:convert';
import 'package:attendance_tracker/models/course.dart';
import 'package:attendance_tracker/models/session.dart';
import 'package:attendance_tracker/models/student_attendance.dart';
import 'package:attendance_tracker/models/user.dart';
import 'package:attendance_tracker/services/auth/auth_service.dart';
import 'package:attendance_tracker/services/database/database_service.dart';
import 'package:flutter/material.dart';

class DatabaseProvider extends ChangeNotifier {
  final _db = DatabaseService();
  final _auth = AuthService();

  Future<UserProfile?> getUserProfile() async {
    try {
      final user = _auth.getCurrentUser();
      if (user != null) {
        return await _db.getUserProfile(user.uid);
      } else {
        return null; // User not logged in
      }
    } catch (e) {
      print("Error getting user profile: $e");
      throw Exception("Failed to get user profile");
    }
  }

  //COURSES

  List<CourseModel> _adminCourses = [];
  List<CourseModel> get adminCourses => _adminCourses;

  Future<CourseModel> createCourse({
    required String courseName,
    required String adminName,
  }) async {
    try {
      final course = await _db.createCourse(
        courseName: courseName,
        adminName: adminName,
      );

      // Add the new course to the local list
      _adminCourses.add(course);
      notifyListeners();

      return course;
    } catch (e) {
      print("Error in provider creating course: $e");
      rethrow;
    }
  }

  Future<void> loadAdminCourses() async {
    final adminUid = _auth.getCurrentUID();
    try {
      _adminCourses = await _db.getAdminCourses(adminUid);
      notifyListeners();
    } catch (e) {
      print("Error in provider loading admin courses: $e");
      rethrow;
    }
  }

  //List of enrolled student in a course
  Map<String, List<UserProfile>> _courseEnrolledStudentsMap = {};
  List<UserProfile> getEnrolledStudents(String courseId) {
    return _courseEnrolledStudentsMap[courseId] ?? [];
  }

  Future<void> loadEnrolledStudents(String courseId) async {
    try {
      final students = await _db.getEnrolledStudents(courseId);
      List<UserProfile> studentProfiles = [];

      for (var student in students) {
        final userProfile = await _db.getUserProfile(student);
        if (userProfile != null) {
          studentProfiles.add(userProfile);
        }
      }

      _courseEnrolledStudentsMap[courseId] = studentProfiles;
      notifyListeners();
    } catch (e) {
      print("Error in provider loading enrolled students: $e");
      rethrow;
    }
  }

  //SESSIONS
  Map<String, List<SessionModel>> _courseSessionsMap = {};
  List<SessionModel> getCourseSessions(String courseId) {
    return _courseSessionsMap[courseId] ?? [];
  }

  // Create a new session for a course (using subcollection)
  Future<SessionModel> createSession({required String courseId}) async {
    try {
      final session = await _db.createSession(courseId: courseId);

      _courseSessionsMap.update(
        courseId,
        (existing) => [session, ...existing],
        ifAbsent: () => [session],
      );
      notifyListeners();

      return session;
    } catch (e) {
      print("Error in provider creating session: $e");
      rethrow;
    }
  }

  // Load sessions for a course (from subcollection)
  Future<void> loadCourseSessions(String courseId) async {
    try {
      _courseSessionsMap.putIfAbsent(courseId, () => []);
      _courseSessionsMap[courseId] = await _db.getCourseSessions(courseId);
      notifyListeners();
    } catch (e) {
      print("Error in provider loading course sessions: $e");
      rethrow;
    }
  }

  // Get a single session
  Future<SessionModel> getSession(String courseId, String sessionId) async {
    try {
      return await _db.getSession(courseId, sessionId);
    } catch (e) {
      print("Error in provider getting session: $e");
      rethrow;
    }
  }

  //USER Courses

  List<CourseModel> _studentCourses = [];
  List<CourseModel> get studentCourses => _studentCourses;

  // Enroll current user in a course
  Future<void> enrollInCourse(String courseId) async {
    try {
      final user = _auth.getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      await _db.enrollStudentInCourse(courseId: courseId, studentId: user.uid);

      // Refresh the student's course list
      await loadStudentCourses(user.uid);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Load all courses for current student
  Future<void> loadStudentCourses(String studentId) async {
    try {
      _studentCourses = await _db.getStudentCourses(studentId);
      notifyListeners();
    } catch (e) {
      print("Provider error loading student courses: $e");
      rethrow;
    }
  }

  Future<void> markAttendance({required String qrData}) async {
    try {
      final Map<String, dynamic> qrDData = jsonDecode(qrData);
      final String sessionId = qrDData['sessionId'];
      final String courseId = qrDData['courseId'];
      final int time = qrDData['time'];
      final String studentId = _auth.getCurrentUID();

      if (time < DateTime.now().millisecondsSinceEpoch - 300000) {
        throw Exception("QR code expired");
      } else if (_studentCourses.every(
        (course) => course.courseId != courseId,
      )) {
        throw Exception("You are not enrolled in this course");
      } else {
        await _db.markStudentPresent(
          courseId: courseId,
          sessionId: sessionId,
          studentId: studentId,
        );
        loadCourseSessions(courseId);
      }
      notifyListeners();
    } catch (e) {
      print("Provider error marking attendance: $e");
      rethrow;
    }
  }

  //ATTENDANCE

  Map<String, StudentAttendance> _studentAttendanceMap = {};

  StudentAttendance getStudentAttendance(String courseId) {
    return _studentAttendanceMap[courseId]!;
  }

  Future<void> loadStudentAttendance(String courseId) async {
    try {
      final studentId = _auth.getCurrentUID();
      final attendance = await _db.getStudentAttendance(
        courseId: courseId,
        studentId: studentId,
      );

      _studentAttendanceMap[courseId] = attendance;

      notifyListeners();
    } catch (e) {
      print("Error in provider loading student attendance: $e");
      rethrow;
    }
  }
}
