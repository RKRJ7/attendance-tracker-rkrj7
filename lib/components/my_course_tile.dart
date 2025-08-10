import 'package:attendance_tracker/models/course.dart';
import 'package:attendance_tracker/pages/admin/admin_course_page.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class MyCourseTile extends StatelessWidget {
  final CourseModel course;
  const MyCourseTile({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminCoursePage(course: course),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 15, 10, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
          borderRadius: BorderRadius.circular(12),
        ),
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  course.courseName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Code: ${course.courseId}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    SharePlus.instance.share(
                      ShareParams(
                        text:
                            'Course Code for ${course.courseName}: ${course.courseId}',
                        subject: 'Course Details',
                      ),
                    );
                  },
                  child: Icon(
                    Icons.share,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                Icon(
                  Icons.menu_book_rounded,
                  color: Theme.of(context).colorScheme.tertiary,
                  size: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
