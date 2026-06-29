import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/ibs/data.dart';

import '../../models/class_group.dart';
import 'class_group_state.dart';

final classGroupsProvider =
    StateNotifierProvider<ClassGroupsNotifier, ClassGroupState>((ref) {
      return ClassGroupsNotifier();
    });

// Selected Class Group Provider
/* final selectedClassGroupIdProvider = StateProvider<String?>((ref) => null);

final selectedClassGroupProvider = Provider<ClassGroup?>((ref) {
  final classGroups = ref.watch(classGroupsProvider);
  final selectedId = ref.watch(selectedClassGroupIdProvider);

  if (selectedId == null) return null;

  return classGroups.firstWhere(
    (classGroup) => classGroup.id == selectedId,
    orElse: () => throw Exception('Class group not found'),
  );
}); */

// Notifiers
class ClassGroupsNotifier extends StateNotifier<ClassGroupState> {
  ClassGroupsNotifier()
    : super(
        ClassGroupState(
          classGroups: classGroupsDummy,
          selectedClassGroupId: '',
          selectedClassGroup: null,
          selectedClassGroupName: '',
          selectedClassGroupTeacherId: null,
          selectedClassGroupSubjectId: null,
          selectedClassGroupSchedule: null,
        ),
      );

  void addClassGroup(ClassGroup classGroup) {
    state = state.copyWith(classGroups: [...state.classGroups, classGroup]);
  }

  void removeClassGroup(int id) {
    state = state.copyWith(
      classGroups:
          state.classGroups.where((classGroup) => classGroup.id != id).toList(),
    );
  }

  void updateClassGroup(ClassGroup updatedClassGroup) {
    state = state.copyWith(
      classGroups:
          state.classGroups
              .map(
                (classGroup) =>
                    classGroup.id == updatedClassGroup.id
                        ? updatedClassGroup
                        : classGroup,
              )
              .toList(),
    );
  }

  void selectClassGroup(int id) {}
}
