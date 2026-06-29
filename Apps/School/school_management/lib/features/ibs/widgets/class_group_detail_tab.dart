import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data.dart';
import '../models/class_group.dart';
import '../models/schedule.dart';
import '../models/student.dart';
import '../models/subject.dart';
import '../models/teacher.dart';
import 'material_tab.dart';
import 'schedule_tab.dart';
import 'student_list.dart';

class ClassGroupDetailTab extends StatelessWidget {
  final ClassGroup classGroup;
  final Subject subject;
  final Teacher teacher;
  final List<Student> students;
  final List<Schedule> schedules;
  const ClassGroupDetailTab({
    super.key,
    required this.classGroup,
    required this.subject,
    required this.teacher,
    required this.students,

    required this.schedules,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    classGroup.name,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(icon: Icon(Icons.edit_outlined), onPressed: () {}),
                IconButton(icon: Icon(Icons.delete_outline), onPressed: () {}),
              ],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: subject.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    subject.name,
                    style: TextStyle(
                      color: subject.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  classGroup.schedule!,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(teacher.photoUrl!),
                ),
                SizedBox(width: 8),
                Text(
                  teacher.name!,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 4),
                Text(
                  '(Teacher)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          TabBar(
            labelColor: Color(0xFF6200EE),
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Color(0xFF6200EE),
            tabs: [
              Tab(text: 'Students'),
              Tab(text: 'Schedule'),
              Tab(text: 'Materials'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                StudentList(students: students),
                ScheduleTab(
                  startDate: classGroup.startDate!,
                  endDate: classGroup.endDate!,
                  schedule: 'schedule',
                ),
                MaterialTab(materials: materialsDummy),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
