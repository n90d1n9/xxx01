// attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class Student {
  final String id;
  final String name;
  final String profileImage;
  final String rollNumber;

  Student({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.rollNumber,
  });
}

class ClassGroup {
  final String id;
  final String name;
  final String subject;
  final List<Student> students;

  ClassGroup({
    required this.id,
    required this.name,
    required this.subject,
    required this.students,
  });
}

class Attendance {
  final String id;
  final String studentId;
  final String classGroupId;
  final DateTime date;
  final AttendanceStatus status;

  Attendance({
    required this.id,
    required this.studentId,
    required this.classGroupId,
    required this.date,
    required this.status,
  });
}

enum AttendanceStatus { present, absent, late }

// Repository
class AttendanceRepository {
  Future<List<ClassGroup>> getClassGroups() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    return [
      ClassGroup(
        id: '1',
        name: 'Class A',
        subject: 'Mathematics',
        students: [
          Student(
            id: '1',
            name: 'Alice Johnson',
            profileImage: 'assets/profile1.png',
            rollNumber: 'A001',
          ),
          Student(
            id: '2',
            name: 'Bob Smith',
            profileImage: 'assets/profile2.png',
            rollNumber: 'A002',
          ),
          Student(
            id: '3',
            name: 'Charlie Brown',
            profileImage: 'assets/profile3.png',
            rollNumber: 'A003',
          ),
          Student(
            id: '4',
            name: 'David Miller',
            profileImage: 'assets/profile4.png',
            rollNumber: 'A004',
          ),
          Student(
            id: '5',
            name: 'Emma Wilson',
            profileImage: 'assets/profile5.png',
            rollNumber: 'A005',
          ),
        ],
      ),
      ClassGroup(
        id: '2',
        name: 'Class B',
        subject: 'Science',
        students: [
          Student(
            id: '6',
            name: 'Frank Thomas',
            profileImage: 'assets/profile6.png',
            rollNumber: 'B001',
          ),
          Student(
            id: '7',
            name: 'Grace Lee',
            profileImage: 'assets/profile7.png',
            rollNumber: 'B002',
          ),
          Student(
            id: '8',
            name: 'Henry Zhang',
            profileImage: 'assets/profile8.png',
            rollNumber: 'B003',
          ),
        ],
      ),
    ];
  }

  Future<Map<String, Attendance>> getAttendanceForClass(
    String classId,
    DateTime date,
  ) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would fetch from an API
    final Map<String, Attendance> attendanceMap = {};

    if (classId == '1') {
      attendanceMap['1'] = Attendance(
        id: 'a1',
        studentId: '1',
        classGroupId: '1',
        date: date,
        status: AttendanceStatus.present,
      );
      attendanceMap['2'] = Attendance(
        id: 'a2',
        studentId: '2',
        classGroupId: '1',
        date: date,
        status: AttendanceStatus.absent,
      );
      // Others would be uninitialized
    }

    return attendanceMap;
  }

  Future<void> saveAttendance(List<Attendance> attendanceList) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would save to an API
    print('Saved ${attendanceList.length} attendance records');
  }
}

// Providers
final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => AttendanceRepository(),
);

final classGroupsProvider = FutureProvider<List<ClassGroup>>((ref) async {
  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.getClassGroups();
});

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final selectedClassProvider = StateProvider<String?>((ref) => null);

final attendanceProvider =
    FutureProvider.family<Map<String, Attendance>, String>((
      ref,
      classId,
    ) async {
      final repository = ref.watch(attendanceRepositoryProvider);
      final date = ref.watch(selectedDateProvider);
      return repository.getAttendanceForClass(classId, date);
    });

// Notifier for managing attendance changes
class AttendanceNotifier extends StateNotifier<Map<String, Attendance>> {
  final AttendanceRepository repository;
  final String classId;
  final DateTime date;

  AttendanceNotifier(this.repository, this.classId, this.date) : super({});

  Future<void> initialize() async {
    state = await repository.getAttendanceForClass(classId, date);
  }

  void markAttendance(String studentId, AttendanceStatus status) {
    final attendance = state[studentId];

    if (attendance != null) {
      // Update existing attendance
      state = {
        ...state,
        studentId: Attendance(
          id: attendance.id,
          studentId: studentId,
          classGroupId: classId,
          date: date,
          status: status,
        ),
      };
    } else {
      // Create new attendance
      state = {
        ...state,
        studentId: Attendance(
          id: 'temp_${studentId}_${DateTime.now().millisecondsSinceEpoch}',
          studentId: studentId,
          classGroupId: classId,
          date: date,
          status: status,
        ),
      };
    }
  }

  Future<void> saveAll(List<Student> students) async {
    final attendanceList = students.map((student) {
      final attendance = state[student.id];

      if (attendance != null) {
        return attendance;
      } else {
        // Create new attendance with present status as default
        return Attendance(
          id: 'temp_${student.id}_${DateTime.now().millisecondsSinceEpoch}',
          studentId: student.id,
          classGroupId: classId,
          date: date,
          status: AttendanceStatus.present,
        );
      }
    }).toList();

    await repository.saveAttendance(attendanceList);
  }
}

final attendanceNotifierProvider =
    StateNotifierProvider.family<
      AttendanceNotifier,
      Map<String, Attendance>,
      String
    >((ref, classId) {
      final repository = ref.watch(attendanceRepositoryProvider);
      final date = ref.watch(selectedDateProvider);

      final notifier = AttendanceNotifier(repository, classId, date);
      notifier.initialize();

      return notifier;
    });

// Screens
class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classGroupsAsync = ref.watch(classGroupsProvider);
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
          _buildClassSelector(context, ref, classGroupsAsync),
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
      floatingActionButton: selectedClass != null
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
    AsyncValue<List<ClassGroup>> classGroupsAsync,
  ) {
    final selectedClass = ref.watch(selectedClassProvider);

    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: classGroupsAsync.when(
        data: (classGroups) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: classGroups.map((classGroup) {
              final isSelected = selectedClass == classGroup.id;

              return GestureDetector(
                onTap: () {
                  ref.read(selectedClassProvider.notifier).state =
                      classGroup.id;
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
                        classGroup.subject,
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading classes: $error')),
      ),
    );
  }

  Widget _buildAttendanceList(
    BuildContext context,
    WidgetRef ref,
    String classId,
  ) {
    final classGroupsAsync = ref.watch(classGroupsProvider);
    final attendanceState = ref.watch(attendanceNotifierProvider(classId));

    return classGroupsAsync.when(
      data: (classGroups) {
        final classGroup = classGroups.firstWhere(
          (group) => group.id == classId,
        );
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
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading students: $error')),
    );
  }

  Widget _buildAttendanceSummary(
    BuildContext context,
    Map<String, Attendance> attendanceState,
    List<Student> students,
    AttendanceStatus status,
    Color color,
  ) {
    final count = attendanceState.values
        .where((a) => a.status == status)
        .length;
    final total = students.length;
    final percentage = total > 0
        ? (count / total * 100).toStringAsFixed(0)
        : '0';

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
            .markAttendance(student.id, status);
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
    final classGroupsAsync = ref.watch(classGroupsProvider);

    if (classGroupsAsync is AsyncData) {
      final classGroups = classGroupsAsync.value;
      final classGroup = classGroups!.firstWhere(
        (group) => group.id == classId,
      );

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
    }
  }
}

// Main entry point for the Attendance feature
class AttendanceApp extends ConsumerWidget {
  const AttendanceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Student Attendance',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const AttendanceScreen(),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: AttendanceApp()));
}
