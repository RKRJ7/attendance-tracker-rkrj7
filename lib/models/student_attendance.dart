import 'package:cloud_firestore/cloud_firestore.dart';

class StudentAttendance {
  final String studentId;
  final String courseId;
  final List<String> attendedSessions;
  final int attendanceCount;

  StudentAttendance({
    required this.studentId,
    required this.courseId,
    this.attendedSessions = const [],
    this.attendanceCount = 0,
  });

  factory StudentAttendance.fromDoc(DocumentSnapshot doc) {
    return StudentAttendance(
      studentId: doc['studentId'],
      courseId: doc['courseId'],
      attendedSessions: List<String>.from(doc['attendedSessions'] ?? []),
      attendanceCount: doc['attendanceCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'courseId': courseId,
      'attendedSessions': attendedSessions,
      'attendanceCount': attendanceCount,
    };
  }

  bool isPresent(String sessionId) {
    return attendedSessions.contains(sessionId);
  }
  
}