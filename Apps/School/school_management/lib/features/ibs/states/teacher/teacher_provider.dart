import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/teacher.dart';

final selectedTeacherProvider = StateProvider<Teacher?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final activeFilterProvider = StateProvider<bool>((ref) => false);

final teachersProvider = StateNotifierProvider<TeachersNotifier, List<Teacher>>(
  (ref) {
    return TeachersNotifier();
  },
);

class TeachersNotifier extends StateNotifier<List<Teacher>> {
  TeachersNotifier() : super([]);

  void addTeacher(Teacher teacher) {
    state = [...state, teacher];
  }

  void updateTeacher(Teacher teacher) {
    state = [
      for (final t in state)
        if (t.id == teacher.id) teacher else t,
    ];
  }

  void deleteTeacher(int id) {
    state = state.where((t) => t.id != id).toList();
  }

  void toggleTeacherStatus(int id) {
    state = [
      for (final teacher in state)
        if (teacher.id == id)
          Teacher(
            id: teacher.id,
            employeeId: teacher.employeeId,
            firstName: teacher.firstName,
            lastName: teacher.lastName,
            dateOfBirth: teacher.dateOfBirth,
            hireDate: teacher.hireDate,
            phoneNumber: teacher.phoneNumber,
            email: teacher.email,
            address: teacher.address,
            qualification: teacher.qualification,
            expertise: teacher.expertise,
            isActive: teacher.isActive,
            gender: teacher.gender,
            employmentType: teacher.employmentType,
          )
        else
          teacher,
    ];
  }

  List<Teacher> filteredTeachersProvider() {
    /*  final teachers = ref.watch(teachersProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
    final filterActive = ref.watch(activeFilterProvider);

    return teachers.where((teacher) {
      // Filter by active status if enabled
      if (filterActive && !teacher.isActive) return false;

      // Filter by search query
      if (searchQuery.isEmpty) return true;

      return teacher.fullName.toLowerCase().contains(searchQuery) ||
          teacher.employeeId.toLowerCase().contains(searchQuery) ||
          teacher.qualification.toLowerCase().contains(searchQuery) ||
          (teacher.expertise?.toLowerCase().contains(searchQuery) ?? false);
    }).toList(); */
    return [];
  }

  getTeacherById(String? teacherId) {}
}
