import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/ibs/widgets/schedule_tab.dart';

import '../data.dart';
import '../models/class_group.dart';
import '../models/student.dart';
import '../states/class_group/class_group_provider.dart';
import '../states/student_provider.dart';
import '../states/subject_provider.dart';
import '../states/teacher/teacher_provider.dart';
import '../widgets/material_tab.dart';
import '../widgets/student_list.dart';

class ClassGroupScreen extends ConsumerWidget {
  const ClassGroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classGroupsState = ref.watch(classGroupsProvider);
    final selectedClassGroup = classGroupsState.selectedClassGroup;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Class Groups',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open add class group dialog
        },
        backgroundColor: Color(0xFF6200EE),
        child: Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Your Class Groups',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: classGroupsState.classGroups.length,
              itemBuilder: (context, index) {
                final classGroup = classGroupsState.classGroups[index];
                final subject = ref
                    .watch(subjectsProvider)
                    .firstWhere(
                      (subject) => subject.id == classGroup.subjectId,
                    );
                final teacher = ref
                    .watch(teachersProvider)
                    .firstWhere(
                      (teacher) => teacher.id == classGroup.teacherId,
                    );

                return GestureDetector(
                  onTap: () {
                    ref
                        .read(classGroupsProvider.notifier)
                        .selectClassGroup(classGroup.id);
                  },
                  child: Container(
                    width: 220,
                    margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: subject.color.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color:
                            classGroupsState.selectedClassGroup!.id ==
                                    classGroup.id
                                ? subject.color
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: subject.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  subject.code,
                                  style: TextStyle(
                                    color: subject.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${classGroup.students.length}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            classGroup.name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            teacher.name!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child:
                selectedClassGroup == null
                    ? _buildEmptyState()
                    : _buildClassGroupDetails(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_, size: 72, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Select a class group to view details',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildClassGroupDetails(BuildContext context, WidgetRef ref) {
    final classGroup = ref.watch(classGroupsProvider).selectedClassGroup;
    if (classGroup == null) return SizedBox.shrink();

    final subject = ref
        .read(subjectsProvider.notifier)
        .getSubjectById(classGroup.subjectId);

    final teacher = ref
        .read(teachersProvider.notifier)
        .getTeacherById(classGroup.teacherId);

    final students = ref
        .read(studentsProvider.notifier)
        .getStudentsByClassGroupId(classGroup.id);

    return ClassGroupDetailTab(
      classGroup: classGroup,
      subject: subject,
      teacher: teacher,
      students: students,
    );
  }
}
