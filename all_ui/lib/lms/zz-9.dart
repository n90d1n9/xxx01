// pubspec.yaml dependencies:
// flutter_riverpod: ^2.4.0
// firebase_core: ^2.24.0
// firebase_auth: ^4.15.0
// cloud_firestore: ^4.13.0
// firebase_storage: ^11.5.0
// video_player: ^2.8.0
// file_picker: ^6.1.0
// intl: ^0.18.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

// ==================== BIMBEL-SPECIFIC MODELS ====================

enum ExamType {
  snbt, // Seleksi Nasional Berdasarkan Tes (UTBK)
  snbp, // Seleksi Nasional Berdasarkan Prestasi (SNMPTN)
  simak, // UI entrance exam
  um, // UM (Ujian Mandiri)
  sbmptn, // Legacy
  utbk, // Legacy
}

enum SubjectCategory {
  // TPS (Tes Potensi Skolastik)
  penalaranMatematika,
  literasiBahasaIndonesia,
  literasiBahasaInggris,
  penalaran,

  // TKA (Tes Kompetensi Akademik) - Saintek
  matematikaSaintek,
  fisika,
  kimia,
  biologi,

  // TKA - Soshum
  geografiSejarah,
  sosiologi,
  ekonomi,

  // Sekolah
  matematikaSMA,
  bahasaIndonesia,
  bahasaInggris,
  ipa,
  ips,
}

enum StudyLevel {
  sma10, // Kelas 10
  sma11, // Kelas 11
  sma12, // Kelas 12
  alumni, // Alumni/Gap Year
  university, // Universitas
}

class TryOutSession {
  final String id;
  final String title;
  final ExamType examType;
  final DateTime scheduledDate;
  final Duration duration;
  final List<SubjectCategory> subjects;
  final int totalQuestions;
  final bool isSimulation;
  final String? proctorId;
  final List<String> enrolledStudents;
  final TryOutStatus status;

  TryOutSession({
    required this.id,
    required this.title,
    required this.examType,
    required this.scheduledDate,
    required this.duration,
    required this.subjects,
    required this.totalQuestions,
    this.isSimulation = false,
    this.proctorId,
    required this.enrolledStudents,
    required this.status,
  });

  factory TryOutSession.fromMap(Map<String, dynamic> data) {
    return TryOutSession(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      examType: ExamType.values.firstWhere((e) => e.name == data['examType']),
      scheduledDate: DateTime.parse(data['scheduledDate']),
      duration: Duration(minutes: data['durationMinutes'] ?? 180),
      subjects:
          (data['subjects'] as List<dynamic>)
              .map((s) => SubjectCategory.values.firstWhere((e) => e.name == s))
              .toList(),
      totalQuestions: data['totalQuestions'] ?? 0,
      isSimulation: data['isSimulation'] ?? false,
      proctorId: data['proctorId'],
      enrolledStudents: List<String>.from(data['enrolledStudents'] ?? []),
      status: TryOutStatus.values.firstWhere((e) => e.name == data['status']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'examType': examType.name,
      'scheduledDate': scheduledDate.toIso8601String(),
      'durationMinutes': duration.inMinutes,
      'subjects': subjects.map((s) => s.name).toList(),
      'totalQuestions': totalQuestions,
      'isSimulation': isSimulation,
      'proctorId': proctorId,
      'enrolledStudents': enrolledStudents,
      'status': status.name,
    };
  }
}

enum TryOutStatus { upcoming, ongoing, completed, graded }

class TryOutResult {
  final String id;
  final String studentId;
  final String tryOutId;
  final Map<SubjectCategory, SubjectScore> scores;
  final DateTime completedAt;
  final int totalScore;
  final int maxScore;
  final double percentage;
  final int ranking;
  final int totalParticipants;
  final Map<String, dynamic>? analytics;

  TryOutResult({
    required this.id,
    required this.studentId,
    required this.tryOutId,
    required this.scores,
    required this.completedAt,
    required this.totalScore,
    required this.maxScore,
    required this.percentage,
    required this.ranking,
    required this.totalParticipants,
    this.analytics,
  });
}

class SubjectScore {
  final SubjectCategory subject;
  final int score;
  final int maxScore;
  final int correct;
  final int wrong;
  final int blank;
  final double percentage;

  SubjectScore({
    required this.subject,
    required this.score,
    required this.maxScore,
    required this.correct,
    required this.wrong,
    required this.blank,
    required this.percentage,
  });
}

class StudyMaterial {
  final String id;
  final String title;
  final SubjectCategory subject;
  final StudyLevel level;
  final String? chapter;
  final MaterialType type;
  final String? contentUrl;
  final String? videoUrl;
  final List<String>? downloadUrls;
  final DateTime publishedAt;
  final int viewCount;

  StudyMaterial({
    required this.id,
    required this.title,
    required this.subject,
    required this.level,
    this.chapter,
    required this.type,
    this.contentUrl,
    this.videoUrl,
    this.downloadUrls,
    required this.publishedAt,
    this.viewCount = 0,
  });
}

enum MaterialType { video, pdf, soalLatihan, rangkuman, mindMap, flashcard }

class BimbelPackage {
  final String id;
  final String name;
  final String description;
  final PackageType type;
  final StudyLevel targetLevel;
  final List<ExamType> targetExams;
  final int durationMonths;
  final double price;
  final List<String> features;
  final int tryOutIncluded;
  final bool hasLiveClass;
  final bool hasMentor;
  final int maxStudents;

  BimbelPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.targetLevel,
    required this.targetExams,
    required this.durationMonths,
    required this.price,
    required this.features,
    required this.tryOutIncluded,
    required this.hasLiveClass,
    required this.hasMentor,
    required this.maxStudents,
  });
}

enum PackageType { reguler, intensif, supercamp, privateClass }

class StudentProgress {
  final String studentId;
  final StudyLevel level;
  final Map<SubjectCategory, SubjectProgress> subjectProgress;
  final List<String> completedMaterials;
  final List<String> completedTryOuts;
  final double averageScore;
  final int studyStreak;
  final DateTime lastStudyDate;

  StudentProgress({
    required this.studentId,
    required this.level,
    required this.subjectProgress,
    required this.completedMaterials,
    required this.completedTryOuts,
    required this.averageScore,
    required this.studyStreak,
    required this.lastStudyDate,
  });
}

class SubjectProgress {
  final SubjectCategory subject;
  final int completedTopics;
  final int totalTopics;
  final double averageScore;
  final List<String> weakTopics;
  final List<String> strongTopics;

  SubjectProgress({
    required this.subject,
    required this.completedTopics,
    required this.totalTopics,
    required this.averageScore,
    required this.weakTopics,
    required this.strongTopics,
  });
}

class LiveClass {
  final String id;
  final String title;
  final SubjectCategory subject;
  final String instructorId;
  final String instructorName;
  final DateTime scheduledAt;
  final Duration duration;
  final String? meetingUrl;
  final String? recordingUrl;
  final int maxParticipants;
  final List<String> enrolledStudents;
  final ClassStatus status;

  LiveClass({
    required this.id,
    required this.title,
    required this.subject,
    required this.instructorId,
    required this.instructorName,
    required this.scheduledAt,
    required this.duration,
    this.meetingUrl,
    this.recordingUrl,
    required this.maxParticipants,
    required this.enrolledStudents,
    required this.status,
  });
}

enum ClassStatus { scheduled, live, completed, cancelled }

// ==================== MOCK DATA FOR BIMBEL ====================

final _mockTryOuts = [
  TryOutSession(
    id: 'to1',
    title: 'Try Out SNBT 2025 - Batch 1',
    examType: ExamType.snbt,
    scheduledDate: DateTime.now().add(const Duration(days: 3)),
    duration: const Duration(minutes: 195),
    subjects: [
      SubjectCategory.penalaranMatematika,
      SubjectCategory.literasiBahasaIndonesia,
      SubjectCategory.literasiBahasaInggris,
      SubjectCategory.matematikaSaintek,
      SubjectCategory.fisika,
      SubjectCategory.kimia,
      SubjectCategory.biologi,
    ],
    totalQuestions: 185,
    isSimulation: true,
    enrolledStudents: ['user1', 'user2'],
    status: TryOutStatus.upcoming,
  ),
  TryOutSession(
    id: 'to2',
    title: 'Try Out SIMAK UI - Matematika IPA',
    examType: ExamType.simak,
    scheduledDate: DateTime.now().add(const Duration(days: 7)),
    duration: const Duration(minutes: 120),
    subjects: [
      SubjectCategory.matematikaSaintek,
      SubjectCategory.fisika,
      SubjectCategory.kimia,
    ],
    totalQuestions: 75,
    enrolledStudents: ['user1'],
    status: TryOutStatus.upcoming,
  ),
];

final _mockBimbelPackages = [
  BimbelPackage(
    id: 'pkg1',
    name: 'Paket SNBT Intensif',
    description:
        'Persiapan lengkap SNBT dengan Try Out unlimited dan pembahasan intensif',
    type: PackageType.intensif,
    targetLevel: StudyLevel.sma12,
    targetExams: [ExamType.snbt, ExamType.snbp],
    durationMonths: 6,
    price: 2500000,
    features: [
      'Try Out SNBT Unlimited',
      'Pembahasan Video 200+ jam',
      'Bimbingan Mentor Pribadi',
      'Kelas Live 3x/minggu',
      'Analisis Prediksi PTN',
      'Modul Cetak Premium',
    ],
    tryOutIncluded: 999,
    hasLiveClass: true,
    hasMentor: true,
    maxStudents: 30,
  ),
  BimbelPackage(
    id: 'pkg2',
    name: 'Paket SIMAK UI Supercamp',
    description:
        'Program intensif khusus persiapan SIMAK UI dengan metode drill soal',
    type: PackageType.supercamp,
    targetLevel: StudyLevel.sma12,
    targetExams: [ExamType.simak],
    durationMonths: 3,
    price: 3500000,
    features: [
      'Try Out SIMAK UI 20x',
      'Kelas Live Harian',
      'Drill Soal 1000+ soal',
      'Prediksi Soal UI',
      'Konsultasi SIMAK 24/7',
      'Camp Offline 1 minggu',
    ],
    tryOutIncluded: 20,
    hasLiveClass: true,
    hasMentor: true,
    maxStudents: 15,
  ),
  BimbelPackage(
    id: 'pkg3',
    name: 'Paket Reguler SMA',
    description: 'Pembelajaran reguler untuk siswa SMA kelas 10-12',
    type: PackageType.reguler,
    targetLevel: StudyLevel.sma11,
    targetExams: [],
    durationMonths: 12,
    price: 1500000,
    features: [
      'Materi Lengkap SMA',
      'Try Out Berkala',
      'Video Pembelajaran',
      'Tanya Jawab Tutor',
      'Laporan Belajar Bulanan',
    ],
    tryOutIncluded: 12,
    hasLiveClass: true,
    hasMentor: false,
    maxStudents: 50,
  ),
];

final _mockStudyMaterials = [
  StudyMaterial(
    id: 'mat1',
    title: 'Penalaran Matematika - Logika dan Himpunan',
    subject: SubjectCategory.penalaranMatematika,
    level: StudyLevel.sma12,
    chapter: 'Bab 1',
    type: MaterialType.video,
    videoUrl: 'https://example.com/video.mp4',
    publishedAt: DateTime.now().subtract(const Duration(days: 5)),
    viewCount: 234,
  ),
  StudyMaterial(
    id: 'mat2',
    title: 'Bank Soal Fisika - Mekanika',
    subject: SubjectCategory.fisika,
    level: StudyLevel.sma12,
    chapter: 'Bab 2',
    type: MaterialType.soalLatihan,
    contentUrl: 'https://example.com/soal.pdf',
    publishedAt: DateTime.now().subtract(const Duration(days: 3)),
    viewCount: 189,
  ),
  StudyMaterial(
    id: 'mat3',
    title: 'Rangkuman Lengkap Kimia Organik',
    subject: SubjectCategory.kimia,
    level: StudyLevel.sma12,
    type: MaterialType.rangkuman,
    downloadUrls: ['https://example.com/rangkuman.pdf'],
    publishedAt: DateTime.now().subtract(const Duration(days: 1)),
    viewCount: 156,
  ),
];

final _mockLiveClasses = [
  LiveClass(
    id: 'lc1',
    title: 'Strategi Mengerjakan TPS SNBT',
    subject: SubjectCategory.penalaran,
    instructorId: 'inst1',
    instructorName: 'Pak Budi Santoso, M.Pd',
    scheduledAt: DateTime.now().add(const Duration(hours: 2)),
    duration: const Duration(hours: 2),
    meetingUrl: 'https://zoom.us/j/12345',
    maxParticipants: 100,
    enrolledStudents: ['user1', 'user2'],
    status: ClassStatus.scheduled,
  ),
  LiveClass(
    id: 'lc2',
    title: 'Pembahasan Soal Matematika Saintek',
    subject: SubjectCategory.matematikaSaintek,
    instructorId: 'inst2',
    instructorName: 'Bu Ani Wijaya, S.Si',
    scheduledAt: DateTime.now().add(const Duration(days: 1)),
    duration: const Duration(hours: 1, minutes: 30),
    maxParticipants: 50,
    enrolledStudents: ['user1'],
    status: ClassStatus.scheduled,
  ),
];

// ==================== PROVIDERS ====================

final tryOutsProvider = StreamProvider<List<TryOutSession>>((ref) async* {
  await Future.delayed(const Duration(milliseconds: 500));
  yield _mockTryOuts;

  await for (final _ in Stream.periodic(const Duration(seconds: 10))) {
    yield _mockTryOuts;
  }
});

final bimbelPackagesProvider = Provider<List<BimbelPackage>>((ref) {
  return _mockBimbelPackages;
});

final studyMaterialsProvider =
    StreamProvider.family<List<StudyMaterial>, SubjectCategory?>((
      ref,
      subject,
    ) async* {
      await Future.delayed(const Duration(milliseconds: 300));

      if (subject == null) {
        yield _mockStudyMaterials;
      } else {
        yield _mockStudyMaterials.where((m) => m.subject == subject).toList();
      }
    });

final liveClassesProvider = StreamProvider<List<LiveClass>>((ref) async* {
  await Future.delayed(const Duration(milliseconds: 400));
  yield _mockLiveClasses;
});

final studentProgressProvider = Provider<StudentProgress>((ref) {
  return StudentProgress(
    studentId: 'user1',
    level: StudyLevel.sma12,
    subjectProgress: {
      SubjectCategory.penalaranMatematika: SubjectProgress(
        subject: SubjectCategory.penalaranMatematika,
        completedTopics: 8,
        totalTopics: 12,
        averageScore: 75.5,
        weakTopics: ['Peluang', 'Statistika'],
        strongTopics: ['Logika', 'Aljabar'],
      ),
      SubjectCategory.fisika: SubjectProgress(
        subject: SubjectCategory.fisika,
        completedTopics: 10,
        totalTopics: 15,
        averageScore: 82.3,
        weakTopics: ['Gelombang'],
        strongTopics: ['Mekanika', 'Termodinamika'],
      ),
    },
    completedMaterials: ['mat1', 'mat2'],
    completedTryOuts: ['to1'],
    averageScore: 78.9,
    studyStreak: 7,
    lastStudyDate: DateTime.now(),
  );
});

// ==================== BIMBEL SCREENS ====================

class BimbelDashboardScreen extends ConsumerWidget {
  const BimbelDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tryOutsAsync = ref.watch(tryOutsProvider);
    final progress = ref.watch(studentProgressProvider);
    final liveClassesAsync = ref.watch(liveClassesProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(context),
              const SizedBox(height: 24),
              _buildProgressCard(context, progress),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildUpcomingTryOuts(context, tryOutsAsync),
              const SizedBox(height: 24),
              _buildLiveClasses(context, liveClassesAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Datang! 🎓',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Semangat belajar untuk SNBT 2025!',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '7 Hari Beruntun',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              size: 40,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, StudentProgress progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Belajar',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${progress.averageScore.toStringAsFixed(1)}/100',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...progress.subjectProgress.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getSubjectName(entry.key),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${entry.value.completedTopics}/${entry.value.totalTopics} topik',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value:
                          entry.value.completedTopics / entry.value.totalTopics,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(
                        _getProgressColor(entry.value.averageScore),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildActionCard(
          context,
          'Try Out',
          Icons.quiz,
          const Color(0xFF6366F1),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TryOutListScreen()),
          ),
        ),
        _buildActionCard(
          context,
          'Materi',
          Icons.book,
          const Color(0xFF10B981),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StudyMaterialsScreen()),
          ),
        ),
        _buildActionCard(
          context,
          'Live Class',
          Icons.video_call,
          const Color(0xFFEC4899),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LiveClassListScreen()),
          ),
        ),
        _buildActionCard(
          context,
          'Paket',
          Icons.card_giftcard,
          const Color(0xFFF59E0B),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PackageListScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTryOuts(
    BuildContext context,
    AsyncValue<List<TryOutSession>> tryOutsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Try Out Mendatang',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: () {}, child: const Text('Lihat Semua')),
          ],
        ),
        const SizedBox(height: 12),
        tryOutsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Error: $err'),
          data: (tryOuts) {
            return Column(
              children:
                  tryOuts.take(2).map((to) => TryOutCard(tryOut: to)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLiveClasses(
    BuildContext context,
    AsyncValue<List<LiveClass>> classesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kelas Live Hari Ini',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        classesAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (err, _) => Text('Error: $err'),
          data: (classes) {
            return Column(
              children:
                  classes.map((lc) => LiveClassCard(liveClass: lc)).toList(),
            );
          },
        ),
      ],
    );
  }

  String _getSubjectName(SubjectCategory category) {
    switch (category) {
      case SubjectCategory.penalaranMatematika:
        return 'Penalaran Matematika';
      case SubjectCategory.literasiBahasaIndonesia:
        return 'Literasi B. Indonesia';
      case SubjectCategory.matematikaSaintek:
        return 'Matematika Saintek';
      case SubjectCategory.fisika:
        return 'Fisika';
      case SubjectCategory.kimia:
        return 'Kimia';
      case SubjectCategory.biologi:
        return 'Biologi';
      default:
        return category.name;
    }
  }

  Color _getProgressColor(double score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

class TryOutCard extends StatelessWidget {
  final TryOutSession tryOut;

  const TryOutCard({super.key, required this.tryOut});

  @override
  Widget build(BuildContext context) {
    final daysUntil = tryOut.scheduledDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getExamColor(tryOut.examType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tryOut.examType.name.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: _getExamColor(tryOut.examType),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '$daysUntil hari lagi',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tryOut.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                _formatDate(tryOut.scheduledDate),
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(width: 16),
              Icon(Icons.timer, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                '${tryOut.duration.inMinutes} menit',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.people, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                '${tryOut.enrolledStudents.length} siswa terdaftar',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Ikut Try Out'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getExamColor(ExamType type) {
    switch (type) {
      case ExamType.snbt:
        return const Color(0xFF6366F1);
      case ExamType.simak:
        return const Color(0xFFEC4899);
      case ExamType.um:
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _formatDate(DateTime date) {
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class LiveClassCard extends StatelessWidget {
  final LiveClass liveClass;

  const LiveClassCard({super.key, required this.liveClass});

  @override
  Widget build(BuildContext context) {
    final isNow =
        liveClass.scheduledAt.isBefore(DateTime.now()) &&
        liveClass.status == ClassStatus.live;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isNow ? Colors.red : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.video_call,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isNow) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'LIVE SEKARANG',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  liveClass.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  liveClass.instructorName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Text(
                  _formatTime(liveClass.scheduledAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} WIB';
  }
}

// ==================== TRY OUT LIST SCREEN ====================

class TryOutListScreen extends ConsumerWidget {
  const TryOutListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tryOutsAsync = ref.watch(tryOutsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Try Out')),
      body: SafeArea(
        child: tryOutsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (tryOuts) {
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: tryOuts.length,
              itemBuilder: (context, index) {
                return TryOutCard(tryOut: tryOuts[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

// ==================== STUDY MATERIALS SCREEN ====================

class StudyMaterialsScreen extends ConsumerStatefulWidget {
  const StudyMaterialsScreen({super.key});

  @override
  ConsumerState<StudyMaterialsScreen> createState() =>
      _StudyMaterialsScreenState();
}

class _StudyMaterialsScreenState extends ConsumerState<StudyMaterialsScreen> {
  SubjectCategory? _selectedSubject;

  @override
  Widget build(BuildContext context) {
    final materialsAsync = ref.watch(studyMaterialsProvider(_selectedSubject));

    return Scaffold(
      appBar: AppBar(title: const Text('Materi Belajar')),
      body: Column(
        children: [
          _buildSubjectFilter(),
          Expanded(
            child: materialsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (materials) {
                return GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    return MaterialCard(material: materials[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectFilter() {
    final subjects = [
      null,
      SubjectCategory.penalaranMatematika,
      SubjectCategory.fisika,
      SubjectCategory.kimia,
      SubjectCategory.biologi,
      SubjectCategory.literasiBahasaIndonesia,
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final isSelected = subject == _selectedSubject;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(subject == null ? 'Semua' : _getSubjectName(subject)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedSubject = subject);
              },
            ),
          );
        },
      ),
    );
  }

  String _getSubjectName(SubjectCategory category) {
    switch (category) {
      case SubjectCategory.penalaranMatematika:
        return 'Matematika';
      case SubjectCategory.fisika:
        return 'Fisika';
      case SubjectCategory.kimia:
        return 'Kimia';
      case SubjectCategory.biologi:
        return 'Biologi';
      case SubjectCategory.literasiBahasaIndonesia:
        return 'B. Indonesia';
      default:
        return category.name;
    }
  }
}

class MaterialCard extends StatelessWidget {
  final StudyMaterial material;

  const MaterialCard({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getMaterialColor(material.type),
                  _getMaterialColor(material.type).withOpacity(0.7),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                _getMaterialIcon(material.type),
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      material.type.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    material.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${material.viewCount} views',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMaterialColor(MaterialType type) {
    switch (type) {
      case MaterialType.video:
        return const Color(0xFF6366F1);
      case MaterialType.pdf:
        return const Color(0xFFEF4444);
      case MaterialType.soalLatihan:
        return const Color(0xFF10B981);
      case MaterialType.rangkuman:
        return const Color(0xFFF59E0B);
      case MaterialType.mindMap:
        return const Color(0xFFEC4899);
      case MaterialType.flashcard:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData _getMaterialIcon(MaterialType type) {
    switch (type) {
      case MaterialType.video:
        return Icons.play_circle_outline;
      case MaterialType.pdf:
        return Icons.picture_as_pdf;
      case MaterialType.soalLatihan:
        return Icons.assignment;
      case MaterialType.rangkuman:
        return Icons.description;
      case MaterialType.mindMap:
        return Icons.account_tree;
      case MaterialType.flashcard:
        return Icons.style;
    }
  }
}

// ==================== LIVE CLASS LIST SCREEN ====================

class LiveClassListScreen extends ConsumerWidget {
  const LiveClassListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(liveClassesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelas Live')),
      body: classesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (classes) {
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              return LiveClassCard(liveClass: classes[index]);
            },
          );
        },
      ),
    );
  }
}

// ==================== PACKAGE LIST SCREEN ====================

class PackageListScreen extends ConsumerWidget {
  const PackageListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packages = ref.watch(bimbelPackagesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paket Bimbel')),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          return PackageCard(package: packages[index]);
        },
      ),
    );
  }
}

class PackageCard extends StatelessWidget {
  final BimbelPackage package;

  const PackageCard({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getPackageColor(package.type),
                  _getPackageColor(package.type).withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    package.type.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  package.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  package.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Rp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatPrice(package.price),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      ' /bulan',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...package.features.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _getPackageColor(package.type),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getPackageColor(package.type),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Daftar Sekarang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPackageColor(PackageType type) {
    switch (type) {
      case PackageType.reguler:
        return const Color(0xFF10B981);
      case PackageType.intensif:
        return const Color(0xFF6366F1);
      case PackageType.supercamp:
        return const Color(0xFFEC4899);
      case PackageType.privateClass:
        return const Color(0xFF8B5CF6);
    }
  }

  String _formatPrice(double price) {
    return (price / 1000).toStringAsFixed(0) + 'rb';
  }
}

// ==================== TRY OUT RESULT SCREEN ====================

class TryOutResultScreen extends StatelessWidget {
  final TryOutResult result;

  const TryOutResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Try Out')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreCard(context),
            const SizedBox(height: 24),
            _buildRankingCard(context),
            const SizedBox(height: 24),
            _buildSubjectBreakdown(context),
            const SizedBox(height: 24),
            _buildRecommendations(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
          const SizedBox(height: 16),
          const Text(
            'Total Nilai',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${result.totalScore}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'dari ${result.maxScore} poin',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Persentase: ${result.percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3CD),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Color(0xFFF59E0B),
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Peringkat Kamu',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '#${result.ranking}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'dari ${result.totalParticipants} peserta',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectBreakdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Per Mata Pelajaran',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...result.scores.entries.map((entry) {
            return _buildSubjectRow(entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildSubjectRow(SubjectScore score) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getSubjectName(score.subject),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Text(
                '${score.score}/${score.maxScore}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatChip('✓ ${score.correct}', Colors.green),
              const SizedBox(width: 8),
              _buildStatChip('✗ ${score.wrong}', Colors.red),
              const SizedBox(width: 8),
              _buildStatChip('○ ${score.blank}', Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: score.percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(
                _getScoreColor(score.percentage),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue[700]),
              const SizedBox(width: 12),
              const Text(
                'Rekomendasi Belajar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecommendationItem(
            'Tingkatkan pemahaman di Fisika - Gelombang',
          ),
          _buildRecommendationItem('Perbanyak latihan soal Matematika'),
          _buildRecommendationItem('Review materi Kimia Organik'),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  String _getSubjectName(SubjectCategory category) {
    switch (category) {
      case SubjectCategory.penalaranMatematika:
        return 'Penalaran Matematika';
      case SubjectCategory.fisika:
        return 'Fisika';
      case SubjectCategory.kimia:
        return 'Kimia';
      case SubjectCategory.biologi:
        return 'Biologi';
      default:
        return category.name;
    }
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 75) return const Color(0xFF10B981);
    if (percentage >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
} // pubspec.yaml dependencies:
// flutter_riverpod: ^2.4.0
// firebase_core: ^2.24.0
// firebase_auth: ^4.15.0
// cloud_firestore: ^4.13.0
// firebase_storage: ^11.5.0
// video_player: ^2.8.0
// chewie: ^1.7.0
// file_picker: ^6.1.0
// image_picker: ^1.0.5
// stripe_payment: ^1.1.0
// dio: ^5.4.0
// graphql_flutter: ^5.1.2

// ==================== MODELS ====================

class User {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final UserRole role;
  final DateTime joinedDate;
  final String? photoUrl;
  final bool isEmailVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.role,
    required this.joinedDate,
    this.photoUrl,
    this.isEmailVerified = false,
  });

  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      avatar: data['avatar'] ?? '👤',
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.student,
      ),
      joinedDate: DateTime.parse(data['joinedDate']),
      photoUrl: data['photoUrl'],
      isEmailVerified: data['isEmailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'avatar': avatar,
      'role': role.name,
      'joinedDate': joinedDate.toIso8601String(),
      'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
    };
  }
}

enum UserRole { student, instructor, admin }

class CourseSchema {
  final String id;
  final String title;
  final String description;
  final String instructorId;
  final String thumbnail;
  final String? thumbnailUrl;
  final String category;
  final DifficultyLevel difficulty;
  final List<String> tags;
  final List<ModuleSchema> modules;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final CourseStatus status;
  final int enrolledCount;
  final double rating;
  final double price;
  final List<String> materialsUrls;

  CourseSchema({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorId,
    required this.thumbnail,
    this.thumbnailUrl,
    required this.category,
    required this.difficulty,
    required this.tags,
    required this.modules,
    required this.createdAt,
    this.publishedAt,
    required this.status,
    this.enrolledCount = 0,
    this.rating = 0.0,
    this.price = 0.0,
    this.materialsUrls = const [],
  });

  factory CourseSchema.fromFirestore(Map<String, dynamic> data, String id) {
    return CourseSchema(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      instructorId: data['instructorId'] ?? '',
      thumbnail: data['thumbnail'] ?? '📚',
      thumbnailUrl: data['thumbnailUrl'],
      category: data['category'] ?? '',
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == data['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      tags: List<String>.from(data['tags'] ?? []),
      modules:
          (data['modules'] as List<dynamic>?)
              ?.map((m) => ModuleSchema.fromMap(m))
              .toList() ??
          [],
      createdAt: DateTime.parse(data['createdAt']),
      publishedAt:
          data['publishedAt'] != null
              ? DateTime.parse(data['publishedAt'])
              : null,
      status: CourseStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => CourseStatus.draft,
      ),
      enrolledCount: data['enrolledCount'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      price: (data['price'] ?? 0.0).toDouble(),
      materialsUrls: List<String>.from(data['materialsUrls'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'instructorId': instructorId,
      'thumbnail': thumbnail,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
      'difficulty': difficulty.name,
      'tags': tags,
      'modules': modules.map((m) => m.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'status': status.name,
      'enrolledCount': enrolledCount,
      'rating': rating,
      'price': price,
      'materialsUrls': materialsUrls,
    };
  }

  int get totalLessons => modules.fold(0, (sum, m) => sum + m.lessons.length);
}

enum CourseStatus { draft, review, published, archived }

enum DifficultyLevel { beginner, intermediate, advanced }

class ModuleSchema {
  final String id;
  final String title;
  final String description;
  final int order;
  final List<LessonSchema> lessons;

  ModuleSchema({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.lessons,
  });

  factory ModuleSchema.fromMap(Map<String, dynamic> data) {
    return ModuleSchema(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      order: data['order'] ?? 0,
      lessons:
          (data['lessons'] as List<dynamic>?)
              ?.map((l) => LessonSchema.fromMap(l))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order': order,
      'lessons': lessons.map((l) => l.toMap()).toList(),
    };
  }
}

class LessonSchema {
  final String id;
  final String title;
  final String description;
  final LessonType type;
  final Duration duration;
  final int order;
  final String? videoUrl;
  final String? content;
  final QuizSchema? quiz;

  LessonSchema({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.duration,
    required this.order,
    this.videoUrl,
    this.content,
    this.quiz,
  });

  factory LessonSchema.fromMap(Map<String, dynamic> data) {
    return LessonSchema(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: LessonType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => LessonType.video,
      ),
      duration: Duration(minutes: data['durationMinutes'] ?? 0),
      order: data['order'] ?? 0,
      videoUrl: data['videoUrl'],
      content: data['content'],
      quiz: data['quiz'] != null ? QuizSchema.fromMap(data['quiz']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'durationMinutes': duration.inMinutes,
      'order': order,
      'videoUrl': videoUrl,
      'content': content,
      'quiz': quiz?.toMap(),
    };
  }
}

enum LessonType { video, text, quiz, assignment }

class QuizSchema {
  final String id;
  final List<QuestionSchema> questions;
  final int passingScore;

  QuizSchema({
    required this.id,
    required this.questions,
    required this.passingScore,
  });

  factory QuizSchema.fromMap(Map<String, dynamic> data) {
    return QuizSchema(
      id: data['id'] ?? '',
      questions:
          (data['questions'] as List<dynamic>?)
              ?.map((q) => QuestionSchema.fromMap(q))
              .toList() ??
          [],
      passingScore: data['passingScore'] ?? 70,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questions': questions.map((q) => q.toMap()).toList(),
      'passingScore': passingScore,
    };
  }
}

class QuestionSchema {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;

  QuestionSchema({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  factory QuestionSchema.fromMap(Map<String, dynamic> data) {
    return QuestionSchema(
      id: data['id'] ?? '',
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? 0,
      explanation: data['explanation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}

class Enrollment {
  final String id;
  final String userId;
  final String courseId;
  final DateTime enrolledAt;
  final double progress;
  final Map<String, bool> completedLessons;
  final DateTime? lastAccessedAt;
  final PaymentStatus paymentStatus;
  final String? transactionId;

  Enrollment({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.enrolledAt,
    required this.progress,
    required this.completedLessons,
    this.lastAccessedAt,
    this.paymentStatus = PaymentStatus.pending,
    this.transactionId,
  });

  factory Enrollment.fromFirestore(Map<String, dynamic> data, String id) {
    return Enrollment(
      id: id,
      userId: data['userId'] ?? '',
      courseId: data['courseId'] ?? '',
      enrolledAt: DateTime.parse(data['enrolledAt']),
      progress: (data['progress'] ?? 0.0).toDouble(),
      completedLessons: Map<String, bool>.from(data['completedLessons'] ?? {}),
      lastAccessedAt:
          data['lastAccessedAt'] != null
              ? DateTime.parse(data['lastAccessedAt'])
              : null,
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == data['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: data['transactionId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'courseId': courseId,
      'enrolledAt': enrolledAt.toIso8601String(),
      'progress': progress,
      'completedLessons': completedLessons,
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      'paymentStatus': paymentStatus.name,
      'transactionId': transactionId,
    };
  }
}

enum PaymentStatus { pending, completed, failed, refunded }

class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.metadata,
  });

  factory Notification.fromFirestore(Map<String, dynamic> data, String id) {
    return Notification(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.info,
      ),
      createdAt: DateTime.parse(data['createdAt']),
      isRead: data['isRead'] ?? false,
      metadata: data['metadata'],
    );
  }
}

enum NotificationType { info, success, warning, courseUpdate, achievement }

// ==================== SERVICES ====================

class AuthService {
  static final instance = AuthService._();
  AuthService._();

  // Simulated Firebase Auth
  User? _currentUser;

  Future<User?> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // Simulate successful login
    _currentUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@')[0],
      email: email,
      avatar: '👨‍💻',
      role: UserRole.instructor,
      joinedDate: DateTime.now(),
      isEmailVerified: true,
    );

    return _currentUser;
  }

  Future<User?> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      avatar: '👤',
      role: UserRole.student,
      joinedDate: DateTime.now(),
      isEmailVerified: false,
    );

    return _currentUser;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  User? getCurrentUser() => _currentUser;

  Stream<User?> authStateChanges() async* {
    yield _currentUser;
  }
}

class FirestoreService {
  static final instance = FirestoreService._();
  FirestoreService._();

  // Simulated Firestore operations
  final Map<String, dynamic> _database = {};

  Future<void> setDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _database['$collection/$id'] = data;
  }

  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String id,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _database['$collection/$id'];
  }

  Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _database.entries.where((e) => e.key.startsWith('$collection/')).map(
      (e) {
        final map = Map<String, dynamic>.from(e.value as Map);
        map['id'] = e.key.split('/').last;
        return map;
      },
    ).toList();
  }

  Stream<List<Map<String, dynamic>>> streamCollection(
    String collection,
  ) async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      yield await getCollection(collection);
    }
  }
}

class StorageService {
  static final instance = StorageService._();
  StorageService._();

  Future<String> uploadFile(String path, List<int> bytes) async {
    await Future.delayed(const Duration(seconds: 2));
    // Simulate file upload and return URL
    return 'https://storage.example.com/$path';
  }

  Future<String> uploadVideo(String path, List<int> bytes) async {
    await Future.delayed(const Duration(seconds: 3));
    return 'https://storage.example.com/videos/$path';
  }

  Future<void> deleteFile(String url) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

class PaymentService {
  static final instance = PaymentService._();
  PaymentService._();

  Future<PaymentResult> processPayment(double amount, String currency) async {
    await Future.delayed(const Duration(seconds: 2));

    // Simulate successful payment
    return PaymentResult(
      success: true,
      transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      currency: currency,
    );
  }

  Future<void> refundPayment(String transactionId) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}

class PaymentResult {
  final bool success;
  final String? transactionId;
  final double amount;
  final String currency;
  final String? errorMessage;

  PaymentResult({
    required this.success,
    this.transactionId,
    required this.amount,
    required this.currency,
    this.errorMessage,
  });
}

class NotificationService {
  static final instance = NotificationService._();
  NotificationService._();

  final _notifications = <Notification>[];

  Future<void> sendNotification(Notification notification) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _notifications.add(notification);
  }

  Stream<List<Notification>> getNotificationsStream(String userId) async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      yield _notifications.where((n) => n.userId == userId).toList();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      // Create new notification with isRead = true
    }
  }
}

// ==================== PROVIDERS ====================

final authServiceProvider = Provider((ref) => AuthService.instance);
final firestoreServiceProvider = Provider((ref) => FirestoreService.instance);
final storageServiceProvider = Provider((ref) => StorageService.instance);
final paymentServiceProvider = Provider((ref) => PaymentService.instance);
final notificationServiceProvider = Provider(
  (ref) => NotificationService.instance,
);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

final coursesProvider = StreamProvider<List<CourseSchema>>((ref) async* {
  final firestore = ref.watch(firestoreServiceProvider);

  // Initial load
  await Future.delayed(const Duration(milliseconds: 500));
  yield _mockCourses;

  // Stream updates
  await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
    yield _mockCourses;
  }
});

final enrollmentsProvider = StreamProvider.family<List<Enrollment>, String>((
  ref,
  userId,
) async* {
  final firestore = ref.watch(firestoreServiceProvider);

  await Future.delayed(const Duration(milliseconds: 300));
  yield _mockEnrollments.where((e) => e.userId == userId).toList();

  await for (final _ in Stream.periodic(const Duration(seconds: 3))) {
    yield _mockEnrollments.where((e) => e.userId == userId).toList();
  }
});

final notificationsProvider = StreamProvider.family<List<Notification>, String>(
  (ref, userId) {
    return ref
        .watch(notificationServiceProvider)
        .getNotificationsStream(userId);
  },
);

// Mock data
final _mockCourses = [
  CourseSchema(
    id: '1',
    title: 'Advanced Flutter Architecture',
    description:
        'Master clean architecture, TDD, and advanced patterns in Flutter development',
    instructorId: '1',
    thumbnail: '📱',
    thumbnailUrl: 'https://example.com/flutter.jpg',
    category: 'Development',
    difficulty: DifficultyLevel.advanced,
    tags: ['Flutter', 'Architecture', 'Clean Code'],
    modules: [
      ModuleSchema(
        id: 'm1',
        title: 'Introduction to Clean Architecture',
        description: 'Learn the fundamentals of clean architecture',
        order: 1,
        lessons: [
          LessonSchema(
            id: 'l1',
            title: 'What is Clean Architecture?',
            description: 'Understanding the principles',
            type: LessonType.video,
            duration: const Duration(minutes: 15),
            order: 1,
            videoUrl: 'https://example.com/video1.mp4',
          ),
          LessonSchema(
            id: 'l2',
            title: 'Layers and Dependencies',
            description: 'Breaking down the layers',
            type: LessonType.video,
            duration: const Duration(minutes: 20),
            order: 2,
            videoUrl: 'https://example.com/video2.mp4',
          ),
          LessonSchema(
            id: 'l3',
            title: 'Quiz: Clean Architecture Basics',
            description: 'Test your knowledge',
            type: LessonType.quiz,
            duration: const Duration(minutes: 10),
            order: 3,
            quiz: QuizSchema(
              id: 'q1',
              passingScore: 70,
              questions: [
                QuestionSchema(
                  id: 'q1_1',
                  question: 'What is the main principle of clean architecture?',
                  options: [
                    'Dependency Inversion',
                    'Code Duplication',
                    'Tight Coupling',
                    'Global State',
                  ],
                  correctAnswer: 0,
                  explanation:
                      'The dependency rule states that dependencies should point inward',
                ),
                QuestionSchema(
                  id: 'q1_2',
                  question:
                      'How many layers are in typical clean architecture?',
                  options: ['2', '3', '4', '5'],
                  correctAnswer: 2,
                  explanation:
                      'Typically: Presentation, Domain, Data, and Infrastructure',
                ),
              ],
            ),
          ),
        ],
      ),
    ],
    createdAt: DateTime(2024, 1, 15),
    publishedAt: DateTime(2024, 2, 1),
    status: CourseStatus.published,
    enrolledCount: 1245,
    rating: 4.8,
    price: 99.99,
  ),
  CourseSchema(
    id: '2',
    title: 'UI/UX Design System Mastery',
    description: 'Build scalable design systems from scratch',
    instructorId: '1',
    thumbnail: '🎨',
    category: 'Design',
    difficulty: DifficultyLevel.intermediate,
    tags: ['Design Systems', 'UI', 'Figma'],
    modules: [
      ModuleSchema(
        id: 'm3',
        title: 'Design Tokens',
        description: 'Creating a token system',
        order: 1,
        lessons: [
          LessonSchema(
            id: 'l4',
            title: 'Color Systems',
            description: 'Building color palettes',
            type: LessonType.video,
            duration: const Duration(minutes: 18),
            order: 1,
            videoUrl: 'https://example.com/video4.mp4',
          ),
        ],
      ),
    ],
    createdAt: DateTime(2024, 2, 10),
    publishedAt: DateTime(2024, 3, 1),
    status: CourseStatus.published,
    enrolledCount: 892,
    rating: 4.6,
    price: 79.99,
  ),
];

final _mockEnrollments = [
  Enrollment(
    id: 'e1',
    userId: '1',
    courseId: '1',
    enrolledAt: DateTime(2024, 3, 1),
    progress: 0.65,
    completedLessons: {'l1': true, 'l2': true},
    lastAccessedAt: DateTime.now().subtract(const Duration(hours: 2)),
    paymentStatus: PaymentStatus.completed,
    transactionId: 'txn_123456',
  ),
];

// ==================== MAIN APP ====================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // Uncomment for real Firebase
  runApp(const ProviderScope(child: LMSApp()));
}

class LMSApp extends ConsumerWidget {
  const LMSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Advanced LMS Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: authState.when(
        loading:
            () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error: (_, __) => const LoginScreen(),
        data:
            (user) =>
                user == null ? const MainNavigator() : const MainNavigator(),
      ),
    );
  }
}

// ==================== LOGIN SCREEN ====================

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.school,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'LMS Pro',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin ? 'Welcome back!' : 'Create your account',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),
                    if (!_isLogin)
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    if (!_isLogin) const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Text(_isLogin ? 'Sign In' : 'Sign Up'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(
                        _isLogin
                            ? 'Don\'t have an account? Sign Up'
                            : 'Already have an account? Sign In',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);

      if (_isLogin) {
        await authService.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        await authService.signUpWithEmail(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// ==================== MAIN NAVIGATOR ====================

class MainNavigator extends ConsumerStatefulWidget {
  const MainNavigator({super.key});

  @override
  ConsumerState<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends ConsumerState<MainNavigator> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    final screens = [
      const DashboardScreen(),
      const CoursesListScreen(),
      const CourseBuilderScreen(),
      const VideoPlayerScreen(),
      const PaymentScreen(),
      const NotificationsScreen(),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            extended: MediaQuery.of(context).size.width > 800,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: Text(
                      user?.avatar ?? '👤',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (MediaQuery.of(context).size.width > 800)
                    Text(
                      user?.name ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _handleLogout(),
                    tooltip: 'Logout',
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school),
                label: Text('Courses'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add_box_outlined),
                selectedIcon: Icon(Icons.add_box),
                label: Text('Builder'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.play_circle_outlined),
                selectedIcon: Icon(Icons.play_circle),
                label: Text('Video Player'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.payment_outlined),
                selectedIcon: Icon(Icons.payment),
                label: Text('Payments'),
              ),
              NavigationRailDestination(
                icon: Badge(child: Icon(Icons.notifications_outlined)),
                selectedIcon: Badge(child: Icon(Icons.notifications)),
                label: Text('Notifications'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: screens[_selectedIndex]),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await ref.read(authServiceProvider).signOut();
    }
  }
}

// ==================== DASHBOARD SCREEN ====================

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, user),
              const SizedBox(height: 32),
              coursesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (courses) => _buildStatsGrid(context, courses),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${user?.name ?? 'User'}! 👋',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ready to continue learning?',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.verified,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                user?.role.name.toUpperCase() ?? 'STUDENT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, List<CourseSchema> courses) {
    final published =
        courses.where((c) => c.status == CourseStatus.published).length;
    final totalStudents = courses.fold(0, (sum, c) => sum + c.enrolledCount);
    final avgRating =
        courses.isEmpty
            ? 0.0
            : courses.fold(0.0, (sum, c) => sum + c.rating) / courses.length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          'Total Courses',
          courses.length.toString(),
          Icons.school,
          const Color(0xFF6366F1),
          '+${courses.length} this month',
        ),
        _buildStatCard(
          context,
          'Active Courses',
          published.toString(),
          Icons.play_circle,
          const Color(0xFF10B981),
          'Published',
        ),
        _buildStatCard(
          context,
          'Total Students',
          totalStudents.toString(),
          Icons.people,
          const Color(0xFFEC4899),
          'Enrolled users',
        ),
        _buildStatCard(
          context,
          'Avg Rating',
          avgRating.toStringAsFixed(1),
          Icons.star,
          const Color(0xFFF59E0B),
          'Out of 5.0',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ==================== COURSES LIST SCREEN ====================

class CoursesListScreen extends ConsumerWidget {
  const CoursesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Courses',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filter'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: coursesAsync.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (courses) {
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        return CourseCard(course: courses[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final CourseSchema course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          course.thumbnail,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(
                                course.difficulty,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              course.difficulty.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getDifficultyColor(course.difficulty),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\${course.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  course.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${course.enrolledCount}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.star, size: 16, color: Colors.amber[600]),
                    const SizedBox(width: 4),
                    Text(
                      course.rating.toString(),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return const Color(0xFF10B981);
      case DifficultyLevel.intermediate:
        return const Color(0xFFF59E0B);
      case DifficultyLevel.advanced:
        return const Color(0xFFEF4444);
    }
  }
}

// ==================== COURSE BUILDER ====================

class CourseBuilderScreen extends ConsumerStatefulWidget {
  const CourseBuilderScreen({super.key});

  @override
  ConsumerState<CourseBuilderScreen> createState() =>
      _CourseBuilderScreenState();
}

class _CourseBuilderScreenState extends ConsumerState<CourseBuilderScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Course',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              _buildFileUploadSection(),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Course Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Course Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price (USD)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _createCourse,
                  icon:
                      _isUploading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.publish),
                  label: Text(_isUploading ? 'Creating...' : 'Create Course'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_upload, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Upload Course Materials',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Videos, PDFs, Images supported',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _uploadVideo,
                icon: const Icon(Icons.video_library),
                label: const Text('Upload Video'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _uploadDocument,
                icon: const Icon(Icons.insert_drive_file),
                label: const Text('Upload Files'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _uploadVideo() async {
    setState(() => _isUploading = true);

    try {
      // Simulate file picker
      await Future.delayed(const Duration(seconds: 1));

      // Simulate upload
      final storage = ref.read(storageServiceProvider);
      final url = await storage.uploadVideo('course-videos/video1.mp4', []);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Video uploaded: $url')));
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _uploadDocument() async {
    setState(() => _isUploading = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      final storage = ref.read(storageServiceProvider);
      final url = await storage.uploadFile('course-materials/doc1.pdf', []);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Document uploaded: $url')));
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _createCourse() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a course title')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final firestore = ref.read(firestoreServiceProvider);
      final user = ref.read(currentUserProvider);

      final course = CourseSchema(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        instructorId: user?.id ?? '',
        thumbnail: '📚',
        category: 'Development',
        difficulty: DifficultyLevel.beginner,
        tags: [],
        modules: [],
        createdAt: DateTime.now(),
        status: CourseStatus.published,
        price: double.tryParse(_priceController.text) ?? 0.0,
      );

      await firestore.setDocument('courses', course.id, course.toFirestore());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course created successfully!')),
        );

        _titleController.clear();
        _descriptionController.clear();
        _priceController.clear();
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }
}

// ==================== VIDEO PLAYER SCREEN ====================

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _isPlaying = false;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Video Player',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.play_circle_outline,
                        size: 80,
                        color: Colors.white54,
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          children: [
                            LinearProgressIndicator(
                              value: _progress,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation(
                                Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() => _isPlaying = !_isPlaying);
                                    if (_isPlaying) _simulateProgress();
                                  },
                                ),
                                const Text(
                                  '00:00 / 10:30',
                                  style: TextStyle(color: Colors.white),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.fullscreen,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Lesson: Introduction to Clean Architecture',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Learn the fundamentals of clean architecture and how to apply them in your Flutter projects.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _simulateProgress() async {
    while (_isPlaying && _progress < 1.0) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() => _progress = (_progress + 0.01).clamp(0.0, 1.0));
      }
    }
  }
}

// ==================== PAYMENT SCREEN ====================

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Gateway',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Course Purchase',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Advanced Flutter Architecture',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Price:', style: TextStyle(color: Colors.white70)),
                        Text(
                          '\$99.99',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Payment Details',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.credit_card),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'Expiry',
                        hintText: 'MM/YY',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Pay \$99.99',
                            style: TextStyle(fontSize: 18),
                          ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Secure payment powered by Stripe',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_cardNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter card details')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final paymentService = ref.read(paymentServiceProvider);
      final result = await paymentService.processPayment(99.99, 'USD');

      if (result.success && mounted) {
        // Create enrollment
        final firestore = ref.read(firestoreServiceProvider);
        final user = ref.read(currentUserProvider);

        final enrollment = Enrollment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user?.id ?? '',
          courseId: '1',
          enrolledAt: DateTime.now(),
          progress: 0.0,
          completedLessons: {},
          paymentStatus: PaymentStatus.completed,
          transactionId: result.transactionId,
        );

        await firestore.setDocument(
          'enrollments',
          enrollment.id,
          enrollment.toFirestore(),
        );

        // Send notification
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.sendNotification(
          Notification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: user?.id ?? '',
            title: 'Payment Successful! 🎉',
            message: 'You are now enrolled in Advanced Flutter Architecture',
            type: NotificationType.success,
            createdAt: DateTime.now(),
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment successful! You are now enrolled.'),
              backgroundColor: Colors.green,
            ),
          );

          _cardNumberController.clear();
          _expiryController.clear();
          _cvvController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

// ==================== NOTIFICATIONS SCREEN ====================

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final notificationsAsync =
        user != null
            ? ref.watch(notificationsProvider(user.id))
            : const AsyncValue.data(<Notification>[]);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.done_all),
                    label: const Text('Mark all read'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: notificationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications yet',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return NotificationCard(
                        notification: notifications[index],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final Notification notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.grey[200]! : Colors.blue[200]!,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getTypeColor(notification.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTypeIcon(notification.type),
            color: _getTypeColor(notification.type),
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return const Color(0xFF10B981);
      case NotificationType.warning:
        return const Color(0xFFF59E0B);
      case NotificationType.courseUpdate:
        return const Color(0xFF6366F1);
      case NotificationType.achievement:
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.courseUpdate:
        return Icons.school;
      case NotificationType.achievement:
        return Icons.emoji_events;
      default:
        return Icons.info;
    }
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}

// ==================== QUIZ SCREEN ====================

class QuizScreen extends ConsumerStatefulWidget {
  final QuizSchema quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentQuestion = 0;
  final Map<int, int> _answers = {};
  bool _showResults = false;

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      return _buildResults();
    }

    final question = widget.quiz.questions[_currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz: Question ${_currentQuestion + 1}/${widget.quiz.questions.length}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / widget.quiz.questions.length,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 32),
            Text(
              question.question,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = _answers[_currentQuestion] == index;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap:
                      () => setState(() => _answers[_currentQuestion] = index),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            Row(
              children: [
                if (_currentQuestion > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentQuestion--),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentQuestion > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _answers.containsKey(_currentQuestion)
                            ? () {
                              if (_currentQuestion <
                                  widget.quiz.questions.length - 1) {
                                setState(() => _currentQuestion++);
                              } else {
                                setState(() => _showResults = true);
                              }
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _currentQuestion < widget.quiz.questions.length - 1
                          ? 'Next'
                          : 'Submit',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    int correctAnswers = 0;

    for (var i = 0; i < widget.quiz.questions.length; i++) {
      if (_answers[i] == widget.quiz.questions[i].correctAnswer) {
        correctAnswers++;
      }
    }

    final score = (correctAnswers / widget.quiz.questions.length * 100).toInt();
    final passed = score >= widget.quiz.passingScore;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                passed ? Icons.check_circle : Icons.cancel,
                size: 100,
                color: passed ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                passed ? 'Congratulations!' : 'Keep Practicing!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your Score: $score%',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Passing Score: ${widget.quiz.passingScore}%',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentQuestion = 0;
                        _answers.clear();
                        _showResults = false;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry Quiz'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Course'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== API INTEGRATION EXAMPLE ====================

class ApiService {
  static final instance = ApiService._();
  ApiService._();

  final String _baseUrl = 'https://api.example.com';

  // REST API Example
  Future<List<CourseSchema>> fetchCoursesFromAPI() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // In production, use dio package:
      // final response = await dio.get('$_baseUrl/courses');
      // return (response.data as List).map((e) => CourseSchema.fromFirestore(e, e['id'])).toList();

      return _mockCourses;
    } catch (e) {
      throw Exception('Failed to fetch courses: $e');
    }
  }

  // GraphQL Example
  Future<CourseSchema> fetchCourseByIdGraphQL(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // In production, use graphql_flutter:
      // final result = await client.query(QueryOptions(
      //   document: gql('''
      //     query GetCourse(\$id: ID!) {
      //       course(id: \$id) {
      //         id
      //         title
      //         description
      //       }
      //     }
      //   '''),
      //   variables: {'id': id},
      // ));

      return _mockCourses.firstWhere((c) => c.id == id);
    } catch (e) {
      throw Exception('Failed to fetch course: $e');
    }
  }

  // WebSocket for real-time updates
  Stream<Notification> connectToNotificationStream(String userId) async* {
    // In production, use web_socket_channel:
    // final channel = WebSocketChannel.connect(Uri.parse('wss://api.example.com/notifications'));
    // await for (final message in channel.stream) {
    //   yield Notification.fromJson(jsonDecode(message));
    // }

    await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
      yield Notification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: 'New Update',
        message: 'Check out the latest course updates',
        type: NotificationType.courseUpdate,
        createdAt: DateTime.now(),
      );
    }
  }
}

final apiServiceProvider = Provider((ref) => ApiService.instance);
