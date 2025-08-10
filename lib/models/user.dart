import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, student }

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final List<String> enrolledCourses;
  final List<String> createdCourses;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.enrolledCourses = const [],
    this.createdCourses = const [],
  });

  String _roleToString(UserRole role) {
    return role.name;
  }

  // UserRole _stringToRole(String roleStr) {
  //   return UserRole.values.firstWhere((element) => roleStr == element.name);
  // }

  factory UserProfile.fromDoc(DocumentSnapshot doc) {
    return UserProfile(
      uid: doc['uid'],
      email: doc['email'],
      name: doc['name'],
      role: UserRole.values.firstWhere(
        (e) => e.name == doc['role'],
        orElse: () => UserRole.student,
      ),
      enrolledCourses: List<String>.from(doc['enrolledCourses']??[]),
      createdCourses: List<String>.from(doc['createdCourses']??[]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': _roleToString(role),
      'enrolledCourses': enrolledCourses,
      'createdCourses': createdCourses,
    };
  }

  bool isEnrolledIn(String courseId) {
  return enrolledCourses.contains(courseId);
}
}
