import '../../models/teacher.dart';

class TeacherState {
  final List<Teacher> teachers;
  final String selectedTeacherId;
  final Teacher? selectedTeacher;
  TeacherState({
    this.teachers = const [],
    this.selectedTeacherId = '',
    this.selectedTeacher,
  });
  TeacherState copyWith({
    List<Teacher>? teachers,
    String? selectedTeacherId,
    Teacher? selectedTeacher,
  }) {
    return TeacherState(
      teachers: teachers ?? this.teachers,
      selectedTeacherId: selectedTeacherId ?? this.selectedTeacherId,
      selectedTeacher: selectedTeacher ?? this.selectedTeacher,
    );
  }
}
