// Providers
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/attendance.dart';

import '../models/student.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => AttendanceRepository(),
);

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
    final attendanceList =
        students.map((student) {
          final attendance = state[student.id];

          if (attendance != null) {
            return attendance;
          } else {
            // Create new attendance with present status as default
            return Attendance(
              id: 'temp_${student.id}_${DateTime.now().millisecondsSinceEpoch}',
              studentId: student.studentId,
              classGroupId: classId,
              date: date,
              status: AttendanceStatus.present,
            );
          }
        }).toList();

    await repository.saveAttendance(attendanceList);
  }
}

final attendanceNotifierProvider = StateNotifierProvider.family<
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

// Repository
class AttendanceRepository {
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
