import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
enum Gender { male, female, other }

enum EmploymentType { fullTime, partTime, contract, visiting }

class Teacher {
  final int id;
  final String employeeId;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final DateTime hireDate;
  final String phoneNumber;
  final String? email;
  final String? address;
  final String qualification;
  final String? expertise;
  final bool isActive;
  final Gender gender;
  final EmploymentType employmentType;

  Teacher({
    required this.id,
    required this.employeeId,
    required this.firstName,
    this.lastName = '',
    required this.dateOfBirth,
    required this.hireDate,
    required this.phoneNumber,
    this.email,
    this.address,
    required this.qualification,
    this.expertise,
    this.isActive = true,
    required this.gender,
    required this.employmentType,
  });

  String get fullName => '$firstName ${lastName ?? ""}';

  int get age {
    final today = DateTime.now();
    int years = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      years--;
    }
    return years;
  }

  String get experienceYears {
    final today = DateTime.now();
    int years = today.year - hireDate.year;
    if (today.month < hireDate.month ||
        (today.month == hireDate.month && today.day < hireDate.day)) {
      years--;
    }
    return '$years ${years == 1 ? 'year' : 'years'}';
  }
}

// Providers
final teachersProvider = StateNotifierProvider<TeachersNotifier, List<Teacher>>(
  (ref) {
    return TeachersNotifier();
  },
);

final filteredTeachersProvider = Provider<List<Teacher>>((ref) {
  final teachers = ref.watch(teachersProvider);
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
  }).toList();
});

final selectedTeacherProvider = StateProvider<Teacher?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final activeFilterProvider = StateProvider<bool>((ref) => false);

class TeachersNotifier extends StateNotifier<List<Teacher>> {
  TeachersNotifier()
    : super([
        // Sample data
        Teacher(
          id: 1,
          employeeId: "TCH00123",
          firstName: "Ahmed",
          lastName: "Khalid",
          dateOfBirth: DateTime(1985, 3, 15),
          hireDate: DateTime(2018, 9, 1),
          phoneNumber: "+6012345678",
          email: "ahmed.khalid@school.edu",
          address: "123 Jalan Ampang, Kuala Lumpur",
          qualification: "Ph.D in Islamic Studies",
          expertise: "Tafsir, Hadith Studies",
          gender: Gender.male,
          employmentType: EmploymentType.fullTime,
        ),
        Teacher(
          id: 2,
          employeeId: "TCH00124",
          firstName: "Fatimah",
          lastName: "Abdullah",
          dateOfBirth: DateTime(1990, 6, 22),
          hireDate: DateTime(2019, 1, 15),
          phoneNumber: "+6013456789",
          email: "fatimah.a@school.edu",
          qualification: "Master's in Arabic Literature",
          expertise: "Classical Arabic, Poetry",
          gender: Gender.female,
          employmentType: EmploymentType.fullTime,
        ),
        Teacher(
          id: 3,
          employeeId: "TCH00125",
          firstName: "Yusuf",
          lastName: "Ibrahim",
          dateOfBirth: DateTime(1978, 11, 8),
          hireDate: DateTime(2015, 7, 10),
          phoneNumber: "+6014567890",
          qualification: "Bachelor's in Education",
          expertise: "Quranic Memorization",
          isActive: false,
          gender: Gender.male,
          employmentType: EmploymentType.partTime,
        ),
      ]);

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
            isActive: !teacher.isActive,
            gender: teacher.gender,
            employmentType: teacher.employmentType,
          )
        else
          teacher,
    ];
  }
}

// Main Screens
class TeachersScreen extends ConsumerWidget {
  const TeachersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context, ref);
            },
          ),
        ],
      ),
      body: Column(children: [_buildSearchBar(ref), _buildTeachersList(ref)]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add teacher screen
          // Navigator.push(context, MaterialPageRoute(builder: (_) => AddTeacherScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) =>
            ref.read(searchQueryProvider.notifier).state = value,
        decoration: InputDecoration(
          hintText: 'Search teachers...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildTeachersList(WidgetRef ref) {
    final teachers = ref.watch(filteredTeachersProvider);
    final isActiveFilterEnabled = ref.watch(activeFilterProvider);

    if (teachers.isEmpty) {
      return const Expanded(child: Center(child: Text('No teachers found')));
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: teachers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final teacher = teachers[index];
          return TeacherCard(
            teacher: teacher,
            onTap: () {
              ref.read(selectedTeacherProvider.notifier).state = teacher;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TeacherDetailScreen()),
              );
            },
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final isActiveFilterEnabled = ref.watch(activeFilterProvider);

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Show only active teachers'),
                    value: isActiveFilterEnabled,
                    onChanged: (value) {
                      ref.read(activeFilterProvider.notifier).state = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Reset all filters
                      ref.read(activeFilterProvider.notifier).state = false;
                      ref.read(searchQueryProvider.notifier).state = '';
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Reset Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class TeacherCard extends StatelessWidget {
  final Teacher teacher;
  final VoidCallback onTap;

  const TeacherCard({Key? key, required this.teacher, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: _getAvatarColor(teacher.id),
                child: Text(
                  teacher.firstName[0] +
                      (teacher.lastName.isNotEmpty ? teacher.lastName[0] : ''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            teacher.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!teacher.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Inactive',
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher.qualification,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.card_membership,
                          teacher.employeeId,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.access_time,
                          teacher.experienceYears,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Color _getAvatarColor(int id) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];
    return colors[id % colors.length];
  }
}

class TeacherDetailScreen extends ConsumerWidget {
  const TeacherDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacher = ref.watch(selectedTeacherProvider);

    if (teacher == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Teacher Details')),
        body: const Center(child: Text('Teacher not found')),
      );
    }

    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Details'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                // Navigate to edit screen
              } else if (value == 'toggleStatus') {
                ref
                    .read(teachersProvider.notifier)
                    .toggleTeacherStatus(teacher.id);
              } else if (value == 'delete') {
                _showDeleteConfirmation(context, ref, teacher);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(
                value: 'toggleStatus',
                child: Text(
                  teacher.isActive ? 'Mark as Inactive' : 'Mark as Active',
                ),
              ),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: _getAvatarColor(teacher.id),
                    child: Text(
                      teacher.firstName[0] +
                          (teacher.lastName.isNotEmpty
                              ? teacher.lastName[0]
                              : ''),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    teacher.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    teacher.qualification,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      teacher.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: teacher.isActive
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                    ),
                    backgroundColor: teacher.isActive
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Personal Information'),
                  _buildInfoTile('Employee ID', teacher.employeeId),
                  _buildInfoTile(
                    'Date of Birth',
                    dateFormat.format(teacher.dateOfBirth),
                  ),
                  _buildInfoTile('Age', '${teacher.age} years'),
                  _buildInfoTile(
                    'Gender',
                    _formatEnum(teacher.gender.toString()),
                  ),
                  _buildInfoTile('Phone', teacher.phoneNumber),
                  if (teacher.email != null)
                    _buildInfoTile('Email', teacher.email!),
                  if (teacher.address != null)
                    _buildInfoTile('Address', teacher.address!),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Employment Details'),
                  _buildInfoTile(
                    'Employment Type',
                    _formatEnum(teacher.employmentType.toString()),
                  ),
                  _buildInfoTile(
                    'Hire Date',
                    dateFormat.format(teacher.hireDate),
                  ),
                  _buildInfoTile('Experience', teacher.experienceYears),

                  if (teacher.expertise != null) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('Expertise'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(teacher.expertise!),
                    ),
                  ],

                  const SizedBox(height: 24),
                  _buildSectionTitle('Actions'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // View subjects
                          },
                          icon: const Icon(Icons.book),
                          label: const Text('View Subjects'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // View classes
                          },
                          icon: const Icon(Icons.group),
                          label: const Text('View Classes'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // View salary history
                      },
                      icon: const Icon(Icons.account_balance_wallet),
                      label: const Text('Salary History'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatEnum(String enumValue) {
    // Convert "Gender.male" to "Male"
    final parts = enumValue.split('.');
    if (parts.length > 1) {
      String value = parts[1];
      // Convert camelCase to Title Case with Spaces (e.g. fullTime to Full Time)
      final result = value.replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => ' ${match.group(0)}',
      );
      return result.substring(0, 1).toUpperCase() + result.substring(1);
    }
    return enumValue;
  }

  Color _getAvatarColor(int id) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];
    return colors[id % colors.length];
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Teacher teacher,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: Text(
          'Are you sure you want to delete ${teacher.fullName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              ref.read(teachersProvider.notifier).deleteTeacher(teacher.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to teachers list
            },
            child: const Text('DELETE'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}

// Main app
class TeacherManagementApp extends StatelessWidget {
  const TeacherManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Teacher Management',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: Colors.grey.shade50,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey.shade800,
            centerTitle: false,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const TeachersScreen(),
      ),
    );
  }
}

void main() {
  runApp(const TeacherManagementApp());
}
