import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/student.dart';

final studentNotifierProvider =
    StateNotifierProvider<StudentNotifier, List<Student>>(
        (ref) => StudentNotifier(ref));
final studentFormNotifierProvider =
    StateNotifierProvider<StudentFormNotifier, AsyncValue<void>>(
        (ref) => StudentFormNotifier(ref));

class StudentNotifier extends StateNotifier<List<Student>> {
  Ref ref;
  StudentNotifier(this.ref) : super([]);
  @override
  List<Student> build() => [];

  void addStudent(Student student) {
    state = [...state, student];
  }

  void updateStudent(Student student) {
    state = [
      for (final s in state)
        if (s.nisn == student.nisn) student else s
    ];
  }

  void deleteStudent(String nisn) {
    state = state.where((s) => s.nisn != nisn).toList();
  }
}

class StudentFormNotifier extends StateNotifier<AsyncValue<void>> {
  StudentFormNotifier(this.ref) : super(const AsyncValue.data(null));
  Ref ref;
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> saveStudent(Student student) async {
    state = const AsyncValue.loading();
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      ref.read(studentNotifierProvider.notifier).addStudent(student);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
