import '../../models/class_group.dart';

class ClassGroupState {
  final List<ClassGroup> classGroups;
  final String selectedClassGroupId;
  final ClassGroup? selectedClassGroup;
  final String selectedClassGroupName;
  final String? selectedClassGroupTeacherId;
  final String? selectedClassGroupSubjectId;
  final String? selectedClassGroupSchedule;

  ClassGroupState({
    this.classGroups = const [],
    this.selectedClassGroupId = '',
    this.selectedClassGroup,
    this.selectedClassGroupName = '',
    this.selectedClassGroupTeacherId,
    this.selectedClassGroupSubjectId,
    this.selectedClassGroupSchedule,
  });

  ClassGroupState copyWith({
    List<ClassGroup>? classGroups,
    String? selectedClassGroupId,
    ClassGroup? selectedClassGroup,
    String? selectedClassGroupName,
    String? selectedClassGroupTeacherId,
    String? selectedClassGroupSubjectId,
    String? selectedClassGroupSchedule,
  }) {
    return ClassGroupState(
      classGroups: classGroups ?? this.classGroups,
      selectedClassGroupId: selectedClassGroupId ?? this.selectedClassGroupId,
      selectedClassGroup: selectedClassGroup ?? this.selectedClassGroup,
      selectedClassGroupName:
          selectedClassGroupName ?? this.selectedClassGroupName,
      selectedClassGroupTeacherId:
          selectedClassGroupTeacherId ?? this.selectedClassGroupTeacherId,
      selectedClassGroupSubjectId:
          selectedClassGroupSubjectId ?? this.selectedClassGroupSubjectId,
      selectedClassGroupSchedule:
          selectedClassGroupSchedule ?? this.selectedClassGroupSchedule,
    );
  }
}
