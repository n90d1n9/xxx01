import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/attendance.dart';
import '../models/class_group.dart';
import '../models/student.dart';
import '../states/attendance_provider.dart';
import '../states/class_group/class_group_provider.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classGroupsState = ref.watch(classGroupsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedClass = ref.watch(selectedClassProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Attendance'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to attendance history
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(context, ref),
          _buildClassSelector(
            context,
            ref,
            classGroupsState.classGroups,
            classGroupsState,
          ),
          const SizedBox(height: 16),
          if (selectedClass != null)
            Expanded(child: _buildAttendanceList(context, ref, selectedClass))
          else
            const Expanded(
              child: Center(
                child: Text(
                  'Select a class to take attendance',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton:
          selectedClass != null
              ? FloatingActionButton.extended(
                onPressed: () => _saveAttendance(context, ref, selectedClass),
                label: const Text('Save'),
                icon: const Icon(Icons.save),
                backgroundColor: Colors.indigo,
              )
              : null,
    );
  }

  Widget _buildDateSelector(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(selectedDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Attendance for today',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                ref.read(selectedDateProvider.notifier).state = date;
                // Reset selected class when date changes
                ref.read(selectedClassProvider.notifier).state = null;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelector(
    BuildContext context,
    WidgetRef ref,
    List<ClassGroup> classGroups,
    classGroupsState,
  ) {
    final selectedClass = ref.watch(selectedClassProvider);

    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: /* classGroupsAsync.when(
        data:
            (classGroups) =>  */ SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              classGroups.map((classGroup) {
                final isSelected = selectedClass == classGroup.id;

                return GestureDetector(
                  onTap: () {
                    ref.read(selectedClassProvider.notifier).state =
                        '${classGroup.id}';
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.indigo : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          classGroup.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${classGroup.subjectId}',
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${classGroup.students.length} students',
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
      /* (classGroupsState.isLoading) const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) =>
                Center(child: Text('Error loading classes: $error')), */
      //  ),
    );
  }

  Widget _buildAttendanceList(
    BuildContext context,
    WidgetRef ref,
    String classId,
  ) {
    final classGroups = ref.watch(classGroupsProvider).classGroups;
    final attendanceState = ref.watch(attendanceNotifierProvider(classId));

    /*return classGroupsAsync.when(
      data: (classGroups) {*/
    final classGroup = classGroups.firstWhere((group) => group.id == classId);
    final students = classGroup.students;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Students (${students.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildAttendanceSummary(
                    context,
                    attendanceState,
                    students,
                    AttendanceStatus.present,
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildAttendanceSummary(
                    context,
                    attendanceState,
                    students,
                    AttendanceStatus.absent,
                    Colors.red,
                  ),
                  const SizedBox(width: 8),
                  _buildAttendanceSummary(
                    context,
                    attendanceState,
                    students,
                    AttendanceStatus.late,
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final attendance = attendanceState[student.id];
              final status = attendance?.status ?? AttendanceStatus.present;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.indigo.shade100,
                        child: Text(
                          student.name.substring(0, 1),
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Roll: ${student.rollNumber}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildAttendanceToggle(
                        context,
                        ref,
                        student,
                        classId,
                        status,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /* loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) =>
              Center(child: Text('Error loading students: $error')),
    ); */
}

Widget _buildAttendanceSummary(
  BuildContext context,
  Map<String, Attendance> attendanceState,
  List<Student> students,
  AttendanceStatus status,
  Color color,
) {
  final count = attendanceState.values.where((a) => a.status == status).length;
  final total = students.length;
  final percentage = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$percentage%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

Widget _buildAttendanceToggle(
  BuildContext context,
  WidgetRef ref,
  Student student,
  String classId,
  AttendanceStatus currentStatus,
) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusButton(
          context,
          ref,
          student,
          classId,
          AttendanceStatus.present,
          currentStatus,
          Icons.check_circle_outline,
          Colors.green,
        ),
        _buildStatusButton(
          context,
          ref,
          student,
          classId,
          AttendanceStatus.absent,
          currentStatus,
          Icons.cancel_outlined,
          Colors.red,
        ),
        _buildStatusButton(
          context,
          ref,
          student,
          classId,
          AttendanceStatus.late,
          currentStatus,
          Icons.access_time,
          Colors.orange,
        ),
      ],
    ),
  );
}

Widget _buildStatusButton(
  BuildContext context,
  WidgetRef ref,
  Student student,
  String classId,
  AttendanceStatus status,
  AttendanceStatus currentStatus,
  IconData icon,
  Color color,
) {
  final isSelected = currentStatus == status;

  return InkWell(
    onTap: () {
      ref
          .read(attendanceNotifierProvider(classId).notifier)
          .markAttendance(student.studentId, status);
    },
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, size: 20, color: isSelected ? color : Colors.grey),
    ),
  );
}

void _saveAttendance(
  BuildContext context,
  WidgetRef ref,
  String classId,
) async {
  final classGroups = ref.watch(classGroupsProvider).classGroups;

  // if (classGroupsAsync is AsyncData) {
  // final classGroups = classGroupsAsync.value;
  final classGroup = classGroups.firstWhere((group) => group.id == classId);

  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    await ref
        .read(attendanceNotifierProvider(classId).notifier)
        .saveAll(classGroup.students);

    // Close loading dialog
    Navigator.pop(context);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    // Close loading dialog
    Navigator.pop(context);

    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error saving attendance: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
  //   }
  // }
}
