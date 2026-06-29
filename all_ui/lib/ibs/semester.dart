import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Models based on the provided schema
class Semester {
  final int id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String semesterType;
  final int academicYearId;
  final int schoolId;

  Semester({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.isActive = false,
    required this.semesterType,
    required this.academicYearId,
    required this.schoolId,
  });
}

class School {
  final int id;
  final String npsn;
  final String name;
  final String address;
  final String city;
  final String province;
  final String postalCode;
  final String phone;
  final String email;
  final String? website;
  final int foundingYear;
  final String? accreditationNumber;
  final String? logo;
  final String schoolType;
  final String? accreditationGrade;

  School({
    required this.id,
    required this.npsn,
    required this.name,
    required this.address,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.phone,
    required this.email,
    this.website,
    required this.foundingYear,
    this.accreditationNumber,
    this.logo,
    required this.schoolType,
    this.accreditationGrade,
  });
}

// Repository to fetch data from API
class SemesterRepository {
  Future<List<Semester>> getSemesters() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    return [
      Semester(
        id: 1,
        name: 'Semester Ganjil 2024/2025',
        startDate: DateTime(2024, 7, 15),
        endDate: DateTime(2024, 12, 20),
        isActive: true,
        semesterType: 'ODD',
        academicYearId: 1,
        schoolId: 1,
      ),
      Semester(
        id: 2,
        name: 'Semester Genap 2024/2025',
        startDate: DateTime(2025, 1, 7),
        endDate: DateTime(2025, 6, 15),
        isActive: false,
        semesterType: 'EVEN',
        academicYearId: 1,
        schoolId: 1,
      ),
      Semester(
        id: 3,
        name: 'Semester Ganjil 2023/2024',
        startDate: DateTime(2023, 7, 17),
        endDate: DateTime(2023, 12, 22),
        isActive: false,
        semesterType: 'ODD',
        academicYearId: 2,
        schoolId: 1,
      ),
    ];
  }

  Future<School> getSchool(int id) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    return School(
      id: 1,
      npsn: '12345678',
      name: 'SMA Negeri 1 Jakarta',
      address: 'Jl. Pendidikan No. 1',
      city: 'Jakarta',
      province: 'DKI Jakarta',
      postalCode: '12345',
      phone: '0217654321',
      email: 'info@sman1.sch.id',
      website: 'www.sman1.sch.id',
      foundingYear: 1970,
      accreditationNumber: 'ACC-2023-001',
      logo: 'assets/logo.png',
      schoolType: 'HIGH_SCHOOL',
      accreditationGrade: 'A',
    );
  }

  Future<bool> setActiveSemester(int id) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}

// Riverpod providers
final semesterRepositoryProvider = Provider<SemesterRepository>((ref) {
  return SemesterRepository();
});

final semestersProvider = FutureProvider<List<Semester>>((ref) async {
  final repository = ref.watch(semesterRepositoryProvider);
  return repository.getSemesters();
});

final schoolProvider = FutureProvider.family<School, int>((ref, id) async {
  final repository = ref.watch(semesterRepositoryProvider);
  return repository.getSchool(id);
});

final activeSemesterProvider = StateProvider<Semester?>((ref) => null);

// Main screen
class SemesterManagementScreen extends ConsumerStatefulWidget {
  const SemesterManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SemesterManagementScreen> createState() =>
      _SemesterManagementScreenState();
}

class _SemesterManagementScreenState
    extends ConsumerState<SemesterManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize active semester
    Future.delayed(Duration.zero, () async {
      final semestersAsync = ref.read(semestersProvider);
      semestersAsync.whenData((semesters) {
        final activeSemester = semesters.firstWhere(
          (sem) => sem.isActive,
          orElse: () => semesters.first,
        );
        ref.read(activeSemesterProvider.notifier).state = activeSemester;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final semestersAsync = ref.watch(semestersProvider);
    final schoolAsync = ref.watch(schoolProvider(1));
    final activeSemester = ref.watch(activeSemesterProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Semester Management'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add semester screen
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Add new semester')));
            },
          ),
        ],
      ),
      body: schoolAsync.when(
        data: (school) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // School information header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Text(
                            school.name.substring(0, 2),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                school.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NPSN: ${school.npsn}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                school.address,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (activeSemester != null) ...[
                      Text(
                        'Active Semester',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.indigo,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              activeSemester.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Semester list section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'All Semesters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),

              Expanded(
                child: semestersAsync.when(
                  data: (semesters) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: semesters.length,
                      itemBuilder: (context, index) {
                        final semester = semesters[index];
                        final isActive = semester.isActive;
                        final dateFormat = DateFormat('dd MMM yyyy');

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color:
                                  isActive ? Colors.indigo : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        semester.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ),
                                    if (isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              size: 14,
                                              color: Colors.green,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Active',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Start Date',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            dateFormat.format(
                                              semester.startDate,
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'End Date',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            dateFormat.format(semester.endDate),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        semester.semesterType,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (!isActive)
                                          OutlinedButton.icon(
                                            onPressed: () async {
                                              // Set as active semester
                                              final repository = ref.read(
                                                semesterRepositoryProvider,
                                              );
                                              await repository
                                                  .setActiveSemester(
                                                    semester.id,
                                                  );

                                              // Update state
                                              ref
                                                  .read(
                                                    activeSemesterProvider
                                                        .notifier,
                                                  )
                                                  .state = semester;

                                              // Show success message
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      '${semester.name} set as active',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.check,
                                              size: 16,
                                            ),
                                            label: const Text('Set Active'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.indigo,
                                              side: const BorderSide(
                                                color: Colors.indigo,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            // Navigate to edit semester
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Edit ${semester.name}',
                                                ),
                                              ),
                                            );
                                          },
                                          color: Colors.grey[700],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (error, stack) => Center(
                        child: Text('Error loading semesters: $error'),
                      ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) =>
                Center(child: Text('Error loading school data: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Refresh data
          ref.refresh(semestersProvider);
          ref.refresh(schoolProvider(1));
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Management System',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Poppins',
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(elevation: 0),
      ),
      home: const SemesterManagementScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
