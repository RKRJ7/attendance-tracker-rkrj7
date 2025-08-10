import 'package:attendance_tracker/models/course.dart';
import 'package:attendance_tracker/models/session.dart';
import 'package:attendance_tracker/models/student_attendance.dart';
import 'package:attendance_tracker/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  //save info when new user registers
  Future<void> saveUserInfoInFirebase({
    required String email,
    required String name,
    required bool isAdmin,
  }) async {
    try {
      final uid = _auth.currentUser!.uid;

      UserProfile user = UserProfile(
        uid: uid,
        email: email,
        name: name,
        role: isAdmin ? UserRole.admin : UserRole.student,
      );

      final userMap = user.toMap();

      await _db.collection('users').doc(uid).set(userMap);
    } catch (e) {
      print("Error saving user info: $e");
      throw Exception("Failed to save user info");
    }
  }

  //get user profile from Firestore
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromDoc(doc);
      } else {
        return null; // User not found
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      throw Exception("Failed to fetch user profile");
    }
  }

  // Create a new course
  Future<CourseModel> createCourse({
    required String courseName,
    required String adminName,
  }) async {
    try {
      final uid = _auth.currentUser!.uid;

      final courseRef = _db.collection('courses').doc();

      final course = CourseModel(
        courseId: courseRef.id,
        courseName: courseName,
        adminUid: uid,
        adminName: adminName,
        enrolledStudents: [],
        enrollmentCount: 0,
      );

      // Save to Firestore
      await courseRef.set(course.toMap());

      // Add the course to the admin's createdCourses list
      await _db.collection('users').doc(uid).update({
        'createdCourses': FieldValue.arrayUnion([courseRef.id]),
      });
      return course;
    } catch (e) {
      print("Error creating course: $e");
      throw Exception("Failed to create course");
    }
  }

  // Get all courses created by an admin
  Future<List<CourseModel>> getAdminCourses(String adminUid) async {
    try {
      final query = await _db
          .collection('courses')
          .where('adminUid', isEqualTo: adminUid)
          .get();

      return query.docs.map((doc) => CourseModel.fromDoc(doc)).toList();
    } catch (e) {
      print("Error fetching admin courses: $e");
      throw Exception("Failed to fetch admin courses");
    }
  }

  //SESSIONS

  Future<SessionModel> createSession({required String courseId}) async {
    try {
      final uid = _auth.currentUser!.uid;

      // Verify the user is the admin of this course
      final courseDoc = await _db.collection('courses').doc(courseId).get();
      if (!courseDoc.exists || courseDoc['adminUid'] != uid) {
        throw Exception(
          'You are not authorized to create sessions for this course',
        );
      }

      // Create a new session document in the course's sessions subcollection
      final sessionRef = _db
          .collection('courses')
          .doc(courseId)
          .collection('sessions')
          .doc();

      final now = Timestamp.now();

      final session = SessionModel(
        sessionId: sessionRef.id,
        courseId: courseId,
        timestamp: now,
        presentStudents: [],
        presentCount: 0,
      );

      await sessionRef.set(session.toMap());

      return session;
    } catch (e) {
      print("Error creating session: $e");
      throw Exception("Failed to create session: ${e.toString()}");
    }
  }

  // Get all sessions for a course (from subcollection)
  Future<List<SessionModel>> getCourseSessions(String courseId) async {
    try {
      final query = await _db
          .collection('courses')
          .doc(courseId)
          .collection('sessions')
          .orderBy('timestamp', descending: true)
          .get();

      return query.docs.map((doc) => SessionModel.fromDoc(doc)).toList();
    } catch (e) {
      print("Error fetching course sessions: $e");
      throw Exception("Failed to fetch course sessions");
    }
  }

  // Get a single session
  Future<SessionModel> getSession(String courseId, String sessionId) async {
    try {
      final doc = await _db
          .collection('courses')
          .doc(courseId)
          .collection('sessions')
          .doc(sessionId)
          .get();

      if (!doc.exists) throw Exception('Session not found');

      return SessionModel.fromDoc(doc);
    } catch (e) {
      print("Error fetching session: $e");
      throw Exception("Failed to fetch session");
    }
  }

  Future<List<String>> getEnrolledStudents(String courseId) async {
    try {
      final courseDoc = await _db.collection('courses').doc(courseId).get();
      if (!courseDoc.exists) throw Exception('Course not found');

      return List<String>.from(courseDoc['enrolledStudents'] ?? []);
    } catch (e) {
      print("Error fetching enrolled students: $e");
      throw Exception("Failed to fetch enrolled students");
    }
  }

  //User courses

  // Enroll student in a course
  Future<void> enrollStudentInCourse({
    required String courseId,
    required String studentId,
  }) async {
    try {
      await _db.runTransaction((transaction) async {
        // 1. Reference to the course document
        final courseRef = _db.collection('courses').doc(courseId);
        final courseDoc = await transaction.get(courseRef);

        if (!courseDoc.exists) {
          throw Exception('Course does not exist');
        }

        // 2. Check if already enrolled
        final enrolledStudents = List<String>.from(
          courseDoc['enrolledStudents'] ?? [],
        );
        if (enrolledStudents.contains(studentId)) {
          throw Exception('Student already enrolled');
        }

        // 3. Update course enrollment
        transaction.update(courseRef, {
          'enrolledStudents': FieldValue.arrayUnion([studentId]),
          'enrollmentCount': FieldValue.increment(1),
        });

        // 4. Update student's enrolled courses
        final studentRef = _db.collection('users').doc(studentId);
        transaction.update(studentRef, {
          'enrolledCourses': FieldValue.arrayUnion([courseId]),
        });

        // 5. Create initial attendance record
        final attendanceRef = _db
            .collection('courses')
            .doc(courseId)
            .collection('attendance')
            .doc(studentId);

        final studentAttendance = StudentAttendance(
          studentId: studentId,
          courseId: courseId,
          attendedSessions: [],
          attendanceCount: 0,
        );

        transaction.set(attendanceRef, studentAttendance.toMap());
      });
    } catch (e) {
      print("Error enrolling student: $e");
      throw Exception("$e");
    }
  }

  // Get all courses a student is enrolled in
  Future<List<CourseModel>> getStudentCourses(String studentId) async {
    try {
      final userDoc = await _db.collection('users').doc(studentId).get();
      if (!userDoc.exists) return [];

      final enrolledCourses = List<String>.from(
        userDoc['enrolledCourses'] ?? [],
      );
      if (enrolledCourses.isEmpty) return [];

      final query = await _db
          .collection('courses')
          .where(FieldPath.documentId, whereIn: enrolledCourses)
          .get();

      return query.docs.map((doc) => CourseModel.fromDoc(doc)).toList();
    } catch (e) {
      print("Error fetching student courses: $e");
      throw Exception("Failed to fetch student courses");
    }
  }

  //Presence tracking

  Future<void> markStudentPresent({
    required String courseId,
    required String sessionId,
    required String studentId,
  }) async {
    try {
      await _db.runTransaction((transaction) async {
        // 1. Verify session exists and get reference
        final sessionRef = _db
            .collection('courses')
            .doc(courseId)
            .collection('sessions')
            .doc(sessionId);

        final sessionDoc = await transaction.get(sessionRef);
        if (!sessionDoc.exists) {
          throw Exception('Session not found');
        }

        // 2. Check if already marked present
        final presentStudents = List<String>.from(
          sessionDoc['presentStudents'] ?? [],
        );
        if (presentStudents.contains(studentId)) {
          throw Exception('Attendance already marked');
        }

        // 3. Update session attendance
        transaction.update(sessionRef, {
          'presentStudents': FieldValue.arrayUnion([studentId]),
          'presentCount': FieldValue.increment(1),
        });

        // 4. Update student's attendance record
        final attendanceRef = _db
            .collection('courses')
            .doc(courseId)
            .collection('attendance')
            .doc(studentId);

        transaction.update(attendanceRef, {
          'attendedSessions': FieldValue.arrayUnion([sessionId]),
          'attendanceCount': FieldValue.increment(1),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print("Error marking student present: $e");
      throw Exception("Failed to mark attendance: ${e.toString()}");
    }
  }

  Future<StudentAttendance> getStudentAttendance({
    required String courseId,
    required String studentId,
  }) async {
    try {
      final attendanceRef = _db
          .collection('courses')
          .doc(courseId)
          .collection('attendance')
          .doc(studentId);

      final doc = await attendanceRef.get();
      if (!doc.exists) {
        throw Exception('Attendance record not found');
      }

      return StudentAttendance.fromDoc(doc);
    } catch (e) {
      print("Error fetching student attendance: $e");
      throw Exception("Failed to fetch student attendance");
    }
  }
}
