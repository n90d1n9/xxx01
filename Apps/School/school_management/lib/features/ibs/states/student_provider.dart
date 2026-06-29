import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data.dart';
import '../models/enums.dart';
import '../models/hafidz_progress.dart';
import '../models/student.dart';
import '../models/surah.dart';
import '../models/teacher.dart';

final studentsProvider = StateNotifierProvider<StudentsNotifier, List<Student>>(
  (ref) {
    return StudentsNotifier();
  },
);

class StudentsNotifier extends StateNotifier<List<Student>> {
  StudentsNotifier() : super([]);

  Future<Student> fetchCurrentStudent() async {
    // In a real app, this would fetch from an API or local database
    // For demo purposes, returning mock data
    await Future.delayed(
      const Duration(milliseconds: 800),
    ); // Simulate network delay

    return Student(
      id: 1,
      name: 'Ahmad Faiz',
      registrationNumber: "STD20240315",
      firstName: "Ahmad",
      lastName: "Faiz",
      dateOfBirth: DateTime(2006, 5, 12),
      enrollmentDate: DateTime(2022, 9, 1),
      phoneNumber: "+60123456789",
      email: "ahmad.faiz@example.com",
      address: "123 Jalan Perdana, Kuala Lumpur",
      parentName: "Muhammad Faisal",
      parentContact: "+60123456780",
      healthInformation: "No known allergies",
      isActive: true,
      gender: Gender.male,
      bloodType: BloodType.oPositive,
      educationLevel: EducationLevel.secondary,
    );
  }

  Future<List<Surah>> fetchAllSurahs() async {
    // In a real app, this would fetch from an API or local database
    // For demo purposes, returning partial list of surahs
    await Future.delayed(
      const Duration(milliseconds: 600),
    ); // Simulate network delay

    return surahDummy;
  }

  Future<List<HafizProgress>> fetchHafizProgressesForStudent(
    int studentId,
  ) async {
    // In a real app, this would fetch from an API or local database with filtering
    // For demo purposes, returning mock data
    await Future.delayed(
      const Duration(milliseconds: 700),
    ); // Simulate network delay

    final student = await fetchCurrentStudent();
    final surahs = await fetchAllSurahs();

    // Mock teacher
    final teacher = Teacher(id: 1, firstName: "Muhammad", lastName: "Yusuf");

    // Generate sample progress data
    return hafizProgressDummy;
  }

  Future<HafizProgress> createHafizProgress({
    required int studentId,
    required int surahId,
    required DateTime date,
    required int startVerse,
    required int endVerse,
    required String comments,
    required double qualityScore,
    required MemorizationStatus status,
  }) async {
    // In a real app, this would send data to an API or local database
    // For demo, we'll simulate network delay and return the created object
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Fetch related data to construct the complete object
    final student = await fetchCurrentStudent();
    final surahs = await fetchAllSurahs();
    final surah = surahs.firstWhere((s) => s.id == surahId);

    // Mock teacher (would typically be the logged-in teacher)
    final teacher = Teacher(id: 1, firstName: "Muhammad", lastName: "Yusuf");

    // Generate a new ID (would be handled by the backend in a real app)
    final existingProgresses = await fetchHafizProgressesForStudent(studentId);
    final newId =
        existingProgresses.isNotEmpty
            ? existingProgresses
                    .map((p) => p.id)
                    .reduce((a, b) => a > b ? a : b) +
                1
            : 1;

    // Create and return the new progress entry
    return HafizProgress(
      id: newId,
      date: date,
      startVerse: startVerse,
      endVerse: endVerse,
      comments: comments,
      qualityScore: qualityScore,
      memorizationStatus: status,
      student: student,
      surahId: 1,
      assessor: teacher,
    );
  }

  getStudentsByClassGroupId(int id) {}
}

// Providers
final studentProvider = FutureProvider<Student>((ref) async {
  // In a real app, you would fetch the student from a repository
  return studentsDummy[1]; // Assume this function exists
});

final surahListProvider = FutureProvider<List<Surah>>((ref) async {
  // In a real app, you would fetch all surahs from a repository
  return surahDummy; // Assume this function exists
});

final hafizProgressesProvider = FutureProvider.family<List<HafizProgress>, int>(
  (ref, studentId) async {
    // In a real app, you would fetch progresses from a repository
    return hafizProgressDummy; // Assume this function exists
  },
);

// State notifier for creating new progress entries
class HafizProgressNotifier extends StateNotifier<AsyncValue<HafizProgress?>> {
  HafizProgressNotifier() : super(const AsyncValue.data(null));

  Future<void> saveProgress({
    required int studentId,
    required int surahId,
    required DateTime date,
    required int startVerse,
    required int endVerse,
    required String comments,
    required double qualityScore,
    required MemorizationStatus status,
  }) async {
    state = const AsyncValue.loading();
    try {
      /* final newProgress = await createHafizProgress(
        studentId: studentId,
        surahId: surahId,
        date: date,
        startVerse: startVerse,
        endVerse: endVerse,
        comments: comments,
        qualityScore: qualityScore,
        status: status,
      ); // Assume this function exists

      state = AsyncValue.data(newProgress); */
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final hafizProgressNotifierProvider =
    StateNotifierProvider<HafizProgressNotifier, AsyncValue<HafizProgress?>>((
      ref,
    ) {
      return HafizProgressNotifier();
    });
