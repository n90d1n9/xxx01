import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

// Models
class Subject {
  final int id;
  final String code;
  final String name;
  final String description;
  final double passingGrade;
  final int creditHours;
  final SubjectType subjectType;
  final SubjectCategory subjectCategory;

  Subject({
    required this.id,
    required this.code,
    required this.name,
    this.description = '',
    this.passingGrade = 70.0,
    required this.creditHours,
    required this.subjectType,
    required this.subjectCategory,
  });
}

enum SubjectType { core, elective, extracurricular }

enum SubjectCategory { science, arts, language, mathematics, social, physical }

// State classes
class SubjectsState {
  final bool isLoading;
  final List<Subject> subjects;
  final String? errorMessage;

  SubjectsState({
    this.isLoading = false,
    this.subjects = const [],
    this.errorMessage,
  });

  SubjectsState copyWith({
    bool? isLoading,
    List<Subject>? subjects,
    String? errorMessage,
  }) {
    return SubjectsState(
      isLoading: isLoading ?? this.isLoading,
      subjects: subjects ?? this.subjects,
      errorMessage: errorMessage,
    );
  }
}

// Providers
final subjectsProvider = StateNotifierProvider<SubjectsNotifier, SubjectsState>(
  (ref) {
    return SubjectsNotifier();
  },
);

final filteredSubjectsProvider = Provider<List<Subject>>((ref) {
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final subjects = ref.watch(subjectsProvider).subjects;

  return subjects.where((subject) {
    final matchesSearch =
        subject.name.toLowerCase().contains(searchQuery) ||
        subject.code.toLowerCase().contains(searchQuery);

    final matchesCategory =
        selectedCategory == null || subject.subjectCategory == selectedCategory;

    return matchesSearch && matchesCategory;
  }).toList();
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<SubjectCategory?>((ref) => null);

// Notifier
class SubjectsNotifier extends StateNotifier<SubjectsState> {
  SubjectsNotifier() : super(SubjectsState()) {
    getSubjects();
  }

  Future<void> getSubjects({
    Map<String, dynamic>? filters,
    Map<String, dynamic>? pagination,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Simulated API call
      await Future.delayed(const Duration(seconds: 1));

      final subjects = [
        Subject(
          id: 1,
          code: 'MAT101',
          name: 'Basic Mathematics',
          description: 'Fundamental mathematical concepts and operations',
          creditHours: 3,
          subjectType: SubjectType.core,
          subjectCategory: SubjectCategory.mathematics,
        ),
        Subject(
          id: 2,
          code: 'PHY101',
          name: 'Physics I',
          description: 'Introduction to physics principles',
          creditHours: 4,
          subjectType: SubjectType.core,
          subjectCategory: SubjectCategory.science,
        ),
        Subject(
          id: 3,
          code: 'ENG101',
          name: 'English Literature',
          description: 'Study of classic literary works',
          creditHours: 2,
          subjectType: SubjectType.elective,
          subjectCategory: SubjectCategory.language,
        ),
        Subject(
          id: 4,
          code: 'ART102',
          name: 'Visual Arts',
          description: 'Exploration of various visual art forms and techniques',
          creditHours: 2,
          subjectType: SubjectType.elective,
          subjectCategory: SubjectCategory.arts,
        ),
        Subject(
          id: 5,
          code: 'SOC101',
          name: 'Introduction to Sociology',
          description: 'Study of human society and social behavior',
          creditHours: 3,
          subjectType: SubjectType.core,
          subjectCategory: SubjectCategory.social,
        ),
        Subject(
          id: 6,
          code: 'PE101',
          name: 'Physical Education',
          description: 'Development of physical fitness and motor skills',
          creditHours: 1,
          subjectType: SubjectType.extracurricular,
          subjectCategory: SubjectCategory.physical,
        ),
      ];

      state = state.copyWith(subjects: subjects, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load subjects: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> createSubject(Subject subject) async {
    // Implementation for creating a subject
  }

  Future<void> updateSubject(int id, Subject subject) async {
    // Implementation for updating a subject
  }

  Future<void> deleteSubject(int id) async {
    // Implementation for deleting a subject
  }
}

// UI Components
class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subjectsProvider);
    final filteredSubjects = ref.watch(filteredSubjectsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Subjects',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF6366F1)),
            onPressed: () => _showFilterBottomSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(ref),
          _buildCategoryChips(ref),
          Expanded(
            child:
                state.isLoading
                    ? _buildLoadingShimmer()
                    : state.errorMessage != null
                    ? _buildErrorView(state.errorMessage!)
                    : _buildSubjectsList(filteredSubjects),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 2,
        onPressed: () => _showAddSubjectDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged:
            (value) => ref.read(searchQueryProvider.notifier).state = value,
        decoration: InputDecoration(
          hintText: 'Search subjects...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1)),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildCategoryChip(ref, null, 'All', selectedCategory == null),
          ...SubjectCategory.values.map((category) {
            return _buildCategoryChip(
              ref,
              category,
              _getCategoryLabel(category),
              selectedCategory == category,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    WidgetRef ref,
    SubjectCategory? category,
    String label,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade300,
          ),
        ),
        selectedColor: const Color(0xFFEEF2FF),
        checkmarkColor: const Color(0xFF6366F1),
        showCheckmark: false,
        label: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade600,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
        onSelected: (_) {
          ref.read(selectedCategoryProvider.notifier).state = category;
        },
      ),
    );
  }

  String _getCategoryLabel(SubjectCategory category) {
    switch (category) {
      case SubjectCategory.science:
        return 'Science';
      case SubjectCategory.arts:
        return 'Arts';
      case SubjectCategory.language:
        return 'Language';
      case SubjectCategory.mathematics:
        return 'Mathematics';
      case SubjectCategory.social:
        return 'Social';
      case SubjectCategory.physical:
        return 'Physical';
    }
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(color: Colors.red.shade300),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList(List<Subject> subjects) {
    if (subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No subjects found',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return _buildSubjectCard(subject);
      },
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getSubjectTypeColor(
                subject.subjectType,
              ).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getSubjectTypeColor(subject.subjectType),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        subject.code,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getSubjectTypeLabel(subject.subjectType),
                      style: GoogleFonts.poppins(
                        color: _getSubjectTypeColor(subject.subjectType),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Color(0xFF6366F1),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${subject.creditHours} hr',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF6366F1),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                if (subject.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subject.description,
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.category_outlined,
                          _getCategoryLabel(subject.subjectCategory),
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.verified_outlined,
                          'Pass: ${subject.passingGrade}%',
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildActionButton(
                          Icons.edit_outlined,
                          const Color(0xFF6366F1),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          Icons.delete_outline,
                          Colors.red.shade400,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color color, {
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Color _getSubjectTypeColor(SubjectType type) {
    switch (type) {
      case SubjectType.core:
        return const Color(0xFF6366F1); // Indigo
      case SubjectType.elective:
        return const Color(0xFF10B981); // Emerald
      case SubjectType.extracurricular:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  String _getSubjectTypeLabel(SubjectType type) {
    switch (type) {
      case SubjectType.core:
        return 'Core';
      case SubjectType.elective:
        return 'Elective';
      case SubjectType.extracurricular:
        return 'Extracurricular';
    }
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Subjects',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Subject Type',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    SubjectType.values.map((type) {
                      return ChoiceChip(
                        selected: false,
                        label: Text(_getSubjectTypeLabel(type)),
                        onSelected: (_) {},
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Credit Hours',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const SliderTheme(
                data: SliderThemeData(
                  thumbColor: Color(0xFF6366F1),
                  activeTrackColor: Color(0xFF6366F1),
                  inactiveTrackColor: Color(0xFFE5E7EB),
                ),
                child: Slider(
                  value: 3,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '3',
                  onChanged: null,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Apply Filters',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSubjectDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Add New Subject',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: const Text('Subject form would go here...'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('Save', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }
}

// Main app entry point
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'School Management',
      theme: ThemeData(
        primaryColor: const Color(0xFF6366F1),
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: const SubjectsScreen(),
    );
  }
}
