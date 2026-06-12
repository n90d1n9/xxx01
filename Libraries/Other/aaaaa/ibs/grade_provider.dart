// lib/features/grades/providers/grade_providers.dart
import 'package:flutter_riverpod/legacy.dart';

import 'grade.dart';

/* final gradeRepositoryProvider = Provider<GradeRepository>((ref) {
  return GradeRepositoryImpl();
}); */

class GradeNotifier extends StateNotifier<AsyncValue<List<Grade>>> {
  final GradeRepository _repository;

  GradeNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchGrades();
  }

  Future<void> fetchGrades({
    Map<String, dynamic>? filters,
    Map<String, dynamic>? pagination,
  }) async {
    try {
      state = const AsyncValue.loading();
      final grades = await _repository.getGrades(
        filters: filters,
        pagination: pagination,
      );
      state = AsyncValue.data(grades);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Grade?> getGradeById(int id) async {
    try {
      return await _repository.getGrade(id: id);
    } catch (e) {
      return null;
    }
  }

  Future<Grade?> createGrade({required Grade grade}) async {
    try {
      final newGrade = await _repository.createGrade(grade: grade);

      // Update the state with the new grade
      state.whenData((grades) {
        state = AsyncValue.data([...grades, newGrade]);
      });

      return newGrade;
    } catch (e) {
      return null;
    }
  }

  Future<Grade?> updateGrade({required int id, required Grade grade}) async {
    try {
      final updatedGrade = await _repository.updateGrade(id: id, grade: grade);

      // Update the grade in the state
      state.whenData((grades) {
        state = AsyncValue.data(
          grades.map((g) => g.id == id ? updatedGrade : g).toList(),
        );
      });

      return updatedGrade;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteGrade({required int id}) async {
    try {
      final success = await _repository.deleteGrade(id: id);

      if (success) {
        // Remove the grade from the state
        state.whenData((grades) {
          state = AsyncValue.data(grades.where((g) => g.id != id).toList());
        });
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  Future<Grade?> calculateFinalGrade({required int gradeId}) async {
    try {
      final updatedGrade = await _repository.calculateFinalGrade(
        gradeId: gradeId,
      );

      // Update the grade in the state
      state.whenData((grades) {
        state = AsyncValue.data(
          grades.map((g) => g.id == gradeId ? updatedGrade : g).toList(),
        );
      });

      return updatedGrade;
    } catch (e) {
      return null;
    }
  }

  Future<List<Grade>> bulkInputGrades({
    required List<Grade> grades,
    required int subjectId,
    required int classroomId,
    required int academicYearId,
    required int semesterId,
  }) async {
    try {
      final savedGrades = await _repository.bulkInputGrades(
        grades: grades,
        subjectId: subjectId,
        classroomId: classroomId,
        academicYearId: academicYearId,
        semesterId: semesterId,
      );

      // Update the state with the new grades
      state.whenData((currentGrades) {
        // Remove any existing grades for the same students/subject/etc
        final filteredGrades = currentGrades.where((grade) {
          return !(grade.subjectId == subjectId &&
              grade.academicYearId == academicYearId &&
              grade.semesterId == semesterId);
        }).toList();

        // Add the new grades
        state = AsyncValue.data([...filteredGrades, ...savedGrades]);
      });

      return savedGrades;
    } catch (e) {
      rethrow;
    }
  }
}

/* final gradeProvider =
    StateNotifierProvider<GradeNotifier, AsyncValue<List<Grade>>>((ref) {
      final repository = ref.watch(gradeRepositoryProvider);
      return GradeNotifier(repository);
    });
 */
// Provider for a single grade
/* final gradeDetailProvider = FutureProvider.family<Grade?, int>((
  ref,
  gradeId,
) async {
  return ref.read(gradeProvider.notifier).getGradeById(gradeId);
}); */

// Provider for classroom students for bulk grade input
final classroomStudentsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((
      ref,
      classroomId,
    ) async {
      // This would typically fetch students from a student repository
      // For now, we'll just return mock data
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate API call

      return [
        {'id': 1, 'name': 'John Doe'},
        {'id': 2, 'name': 'Jane Smith'},
        {'id': 3, 'name': 'Bob Johnson'},
        {'id': 4, 'name': 'Alice Brown'},
        {'id': 5, 'name': 'Michael Davis'},
        {'id': 6, 'name': 'Emma Wilson'},
        {'id': 7, 'name': 'David Lee'},
        {'id': 8, 'name': 'Sophia Martin'},
      ];
    });
