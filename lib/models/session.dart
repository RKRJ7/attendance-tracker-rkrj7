import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String sessionId;
  final String courseId;
  final Timestamp timestamp;
  final List<String> presentStudents;
  final int presentCount;

  SessionModel({
    required this.sessionId,
    required this.courseId,
    required this.timestamp,
    this.presentStudents = const [],
    this.presentCount = 0,
  });

  factory SessionModel.fromDoc(DocumentSnapshot doc) {
    return SessionModel(
      sessionId: doc.id,
      courseId: doc['courseId'],
      timestamp: doc['timestamp'],
      presentStudents: List<String>.from(doc['presentStudents'] ?? []),
      presentCount: doc['presentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'courseId': courseId,
      'timestamp': timestamp,
      'presentStudents': presentStudents,
      'presentCount': presentCount,
    };
  }

  bool isStudentPresent(String studentId) {
  return presentStudents.contains(studentId);
}


}
