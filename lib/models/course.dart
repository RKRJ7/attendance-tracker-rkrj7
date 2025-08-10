import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String courseId;
  final String courseName;
  final String adminUid;
  final String adminName;
  final List<String> enrolledStudents;
  final int enrollmentCount;

  CourseModel({
    required this.courseId,
    required this.courseName,
    required this.adminUid,
    required this.adminName,
    this.enrolledStudents = const [],
    this.enrollmentCount = 0,
  });

  factory CourseModel.fromDoc(DocumentSnapshot doc) {
    return CourseModel(
      courseId: doc.id,
      courseName: doc['courseName'],
      adminUid: doc['adminUid'],
      adminName: doc['adminName'],
      enrolledStudents: List<String>.from(doc['enrolledStudents'] ?? []),
      enrollmentCount: doc['enrollmentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'adminUid': adminUid,
      'adminName': adminName,
      'enrolledStudents': enrolledStudents,
      'enrollmentCount': enrollmentCount,
    };
  }
}