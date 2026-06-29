import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'grade_provider.dart';

// lib/features/grades/models/grade.dart
class Grade {
  final int id;
  final double assignmentScore;
  final double midtermScore;
  final double finalScore;
  final double practicalScore;
  final double finalGrade;
  final String notes;
  final GradeStatus gradeStatus;
  final LetterGrade letterGrade;
  final int studentId;
  final int subjectId;
  final int teacherId;
  final int academicYearId;
  final int semesterId;
  final int schoolId;

  Grade({
    required this.id,
    this.assignmentScore = 0.0,
    this.midtermScore = 0.0,
    this.finalScore = 0.0,
    this.practicalScore = 0.0,
    this.finalGrade = 0.0,
    this.notes = '',
    required this.gradeStatus,
    required this.letterGrade,
    required this.studentId,
    required this.subjectId,
    required this.teacherId,
    required this.academicYearId,
    required this.semesterId,
    required this.schoolId,
  });

  Grade copyWith({
    int? id,
    double? assignmentScore,
    double? midtermScore,
    double? finalScore,
    double? practicalScore,
    double? finalGrade,
    String? notes,
    GradeStatus? gradeStatus,
    LetterGrade? letterGrade,
    int? studentId,
    int? subjectId,
    int? teacherId,
    int? academicYearId,
    int? semesterId,
    int? schoolId,
  }) {
    return Grade(
      id: id ?? this.id,
      assignmentScore: assignmentScore ?? this.assignmentScore,
      midtermScore: midtermScore ?? this.midtermScore,
      finalScore: finalScore ?? this.finalScore,
      practicalScore: practicalScore ?? this.practicalScore,
      finalGrade: finalGrade ?? this.finalGrade,
      notes: notes ?? this.notes,
      gradeStatus: gradeStatus ?? this.gradeStatus,
      letterGrade: letterGrade ?? this.letterGrade,
      studentId: studentId ?? this.studentId,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      academicYearId: academicYearId ?? this.academicYearId,
      semesterId: semesterId ?? this.semesterId,
      schoolId: schoolId ?? this.schoolId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignmentScore': assignmentScore,
      'midtermScore': midtermScore,
      'finalScore': finalScore,
      'practicalScore': practicalScore,
      'finalGrade': finalGrade,
      'notes': notes,
      'gradeStatus': gradeStatus.toString().split('.').last,
      'letterGrade': letterGrade.toString().split('.').last,
      'studentId': studentId,
      'subjectId': subjectId,
      'teacherId': teacherId,
      'academicYearId': academicYearId,
      'semesterId': semesterId,
      'schoolId': schoolId,
    };
  }

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'],
      assignmentScore: json['assignmentScore'] ?? 0.0,
      midtermScore: json['midtermScore'] ?? 0.0,
      finalScore: json['finalScore'] ?? 0.0,
      practicalScore: json['practicalScore'] ?? 0.0,
      finalGrade: json['finalGrade'] ?? 0.0,
      notes: json['notes'] ?? '',
      gradeStatus: GradeStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['gradeStatus'],
        orElse: () => GradeStatus.draft,
      ),
      letterGrade: LetterGrade.values.firstWhere(
        (e) => e.toString().split('.').last == json['letterGrade'],
        orElse: () => LetterGrade.F,
      ),
      studentId: json['studentId'],
      subjectId: json['subjectId'],
      teacherId: json['teacherId'],
      academicYearId: json['academicYearId'],
      semesterId: json['semesterId'],
      schoolId: json['schoolId'],
    );
  }
}

enum GradeStatus { draft, published, archived }

enum LetterGrade { A, B, C, D, E, F }

// lib/features/grades/repositories/grade_repository.dart
class GradeRepository {
  final String baseUrl = 'https://api.school.com/v1';
  final http.Client client;

  GradeRepository({http.Client? client}) : client = client ?? http.Client();

  Future<List<Grade>> getGrades({
    Map<String, dynamic>? filters,
    Map<String, dynamic>? pagination,
  }) async {
    final queryParams = <String, String>{};

    if (filters != null) {
      filters.forEach((key, value) {
        queryParams[key] = value.toString();
      });
    }

    if (pagination != null) {
      pagination.forEach((key, value) {
        queryParams[key] = value.toString();
      });
    }

    final uri = Uri.parse(
      '$baseUrl/grades',
    ).replace(queryParameters: queryParams);
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Grade.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load grades');
    }
  }

  Future<Grade> getGrade(int id) async {
    final response = await client.get(Uri.parse('$baseUrl/grades/$id'));

    if (response.statusCode == 200) {
      return Grade.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load grade');
    }
  }

  Future<Grade> createGrade(Grade grade) async {
    final response = await client.post(
      Uri.parse('$baseUrl/grades'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(grade.toJson()),
    );

    if (response.statusCode == 201) {
      return Grade.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create grade');
    }
  }

  Future<Grade> updateGrade(int id, Grade grade) async {
    final response = await client.put(
      Uri.parse('$baseUrl/grades/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(grade.toJson()),
    );

    if (response.statusCode == 200) {
      return Grade.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update grade');
    }
  }

  Future<bool> deleteGrade(int id) async {
    final response = await client.delete(Uri.parse('$baseUrl/grades/$id'));

    if (response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Failed to delete grade');
    }
  }

  Future<Grade> calculateFinalGrade(int gradeId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/grades/$gradeId/calculate'),
    );

    if (response.statusCode == 200) {
      return Grade.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to calculate final grade');
    }
  }

  Future<List<Grade>> bulkInputGrades({
    required List<Grade> grades,
    required int subjectId,
    required int classroomId,
    required int academicYearId,
    required int semesterId,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/grades/bulk'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'grades': grades.map((g) => g.toJson()).toList(),
        'subjectId': subjectId,
        'classroomId': classroomId,
        'academicYearId': academicYearId,
        'semesterId': semesterId,
      }),
    );

    if (response.statusCode == 201) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Grade.fromJson(json)).toList();
    } else {
      throw Exception('Failed to bulk input grades');
    }
  }
}

// lib/features/grades/providers/grade_providers.dart
final gradeRepositoryProvider = Provider<GradeRepository>((ref) {
  return GradeRepository();
});

final gradesProvider = FutureProvider.family<List<Grade>, Map<String, dynamic>>(
  (ref, params) async {
    final repository = ref.watch(gradeRepositoryProvider);
    return repository.getGrades(
      filters: params['filters'],
      pagination: params['pagination'],
    );
  },
);

final gradeProvider = FutureProvider.family<Grade, int>((ref, id) async {
  final repository = ref.watch(gradeRepositoryProvider);
  return repository.getGrade(id);
});

/* final gradeProvider = StateNotifierProvider<GradeNotifier, AsyncValue<List<Grade>>>((ref) {
  final repository = ref.watch(gradeRepositoryProvider);
  return GradeNotifier(repository);
}); */

class GradeNotifier extends StateNotifier<AsyncValue<Grade?>> {
  final GradeRepository repository;

  GradeNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> getGrade(int id) async {
    state = const AsyncValue.loading();
    try {
      final grade = await repository.getGrade(id);
      state = AsyncValue.data(grade);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createGrade(Grade grade) async {
    state = const AsyncValue.loading();
    try {
      final newGrade = await repository.createGrade(grade);
      state = AsyncValue.data(newGrade);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateGrade(Grade grade) async {
    state = const AsyncValue.loading();
    try {
      final updatedGrade = await repository.updateGrade(grade.id, grade);
      state = AsyncValue.data(updatedGrade);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> calculateFinalGrade(int id) async {
    state = const AsyncValue.loading();
    try {
      final calculatedGrade = await repository.calculateFinalGrade(id);
      state = AsyncValue.data(calculatedGrade);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final gradeNotifierProvider =
    StateNotifierProvider<GradeNotifier, AsyncValue<Grade?>>((ref) {
      final repository = ref.watch(gradeRepositoryProvider);
      return GradeNotifier(repository);
    });

// lib/features/grades/screens/grade_list_screen.dart

class GradeListScreen extends ConsumerStatefulWidget {
  const GradeListScreen({Key? key}) : super(key: key);

  @override
  _GradeListScreenState createState() => _GradeListScreenState();
}

class _GradeListScreenState extends ConsumerState<GradeListScreen> {
  int _currentPage = 1;
  final int _pageSize = 20;
  String _searchQuery = '';
  int? _selectedSubjectId;
  int? _selectedSemesterId;

  @override
  Widget build(BuildContext context) {
    final gradesAsyncValue = ref.watch(
      gradesProvider({
        'filters': {
          'search': _searchQuery,
          'subjectId': _selectedSubjectId,
          'semesterId': _selectedSemesterId,
        },
        'pagination': {'page': _currentPage, 'pageSize': _pageSize},
      }),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Grades'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              hintText: 'Search students...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentPage = 1;
                });
              },
            ),
          ),
          Expanded(
            child: gradesAsyncValue.when(
              data:
                  (grades) =>
                      grades.isEmpty
                          ? _buildEmptyState()
                          : _buildGradeList(grades),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Text(
                      'Error: ${error.toString()}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddGrade(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/empty_grades.png', height: 150),
          const SizedBox(height: 16),
          const Text(
            'No grades found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add new grades or adjust your filters',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Grades'),
            onPressed: () => _navigateToAddGrade(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeList(List<Grade> grades) {
    return ListView.builder(
      itemCount: grades.length,
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        final grade = grades[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _navigateToGradeDetail(context, grade.id),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Student ID: ${grade.studentId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      _buildStatusBadge(grade.gradeStatus),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Subject ID: ${grade.subjectId}'),
                  const SizedBox(height: 12),
                  _buildGradeProgressIndicator(grade),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Final Grade: ${grade.finalGrade.toStringAsFixed(1)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getLetterGradeColor(grade.letterGrade),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          grade.letterGrade.toString().split('.').last,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(GradeStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case GradeStatus.draft:
        color = Colors.orange;
        icon = Icons.edit;
        break;
      case GradeStatus.published:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case GradeStatus.archived:
        color = Colors.grey;
        icon = Icons.archive;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.toString().split('.').last,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeProgressIndicator(Grade grade) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Assignment', style: TextStyle(fontSize: 12)),
            Text(
              '${grade.assignmentScore.toStringAsFixed(1)}/100',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 2),
        LinearProgressIndicator(
          value: grade.assignmentScore / 100,
          backgroundColor: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Midterm', style: TextStyle(fontSize: 12)),
            Text(
              '${grade.midtermScore.toStringAsFixed(1)}/100',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 2),
        LinearProgressIndicator(
          value: grade.midtermScore / 100,
          backgroundColor: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Final', style: TextStyle(fontSize: 12)),
            Text(
              '${grade.finalScore.toStringAsFixed(1)}/100',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 2),
        LinearProgressIndicator(
          value: grade.finalScore / 100,
          backgroundColor: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Color _getLetterGradeColor(LetterGrade grade) {
    switch (grade) {
      case LetterGrade.A:
        return Colors.green;
      case LetterGrade.B:
        return Colors.blue;
      case LetterGrade.C:
        return Colors.orange;
      case LetterGrade.D:
        return Colors.deepOrange;
      case LetterGrade.E:
      case LetterGrade.F:
        return Colors.red;
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Filter Grades',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Subject dropdown
                const Text('Subject'),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  value: _selectedSubjectId,
                  hint: const Text('Select Subject'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Mathematics')),
                    DropdownMenuItem(value: 2, child: Text('Science')),
                    DropdownMenuItem(value: 3, child: Text('History')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSubjectId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Semester dropdown
                const Text('Semester'),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  value: _selectedSemesterId,
                  hint: const Text('Select Semester'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Semester 1')),
                    DropdownMenuItem(value: 2, child: Text('Semester 2')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSemesterId = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedSubjectId = null;
                            _selectedSemesterId = null;
                          });
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _currentPage = 1;
                          });
                          Navigator.pop(context);
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _navigateToGradeDetail(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GradeDetailScreen(gradeId: id)),
    );
  }

  void _navigateToAddGrade(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GradeDetailScreen()),
    );
  }
}

// lib/features/grades/screens/grade_detail_screen.dart

class GradeDetailScreen extends ConsumerStatefulWidget {
  final int? gradeId;

  const GradeDetailScreen({Key? key, this.gradeId}) : super(key: key);

  @override
  _GradeDetailScreenState createState() => _GradeDetailScreenState();
}

class _GradeDetailScreenState extends ConsumerState<GradeDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _assignmentController;
  late final TextEditingController _midtermController;
  late final TextEditingController _finalController;
  late final TextEditingController _practicalController;
  late final TextEditingController _notesController;

  late int _studentId = 1; // Default values for new grade
  late int _subjectId = 1;
  late int _teacherId = 1;
  late int _academicYearId = 1;
  late int _semesterId = 1;
  late int _schoolId = 1;
  late GradeStatus _gradeStatus = GradeStatus.draft;
  late LetterGrade _letterGrade = LetterGrade.F;

  bool _isEditing = false;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();

    _assignmentController = TextEditingController(text: '0.0');
    _midtermController = TextEditingController(text: '0.0');
    _finalController = TextEditingController(text: '0.0');
    _practicalController = TextEditingController(text: '0.0');
    _notesController = TextEditingController(text: '');

    _isEditing = widget.gradeId == null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.gradeId != null) {
        ref.read(gradeProvider.notifier).getGrade(widget.gradeId!);
      }
    });
  }

  @override
  void dispose() {
    _assignmentController.dispose();
    _midtermController.dispose();
    _finalController.dispose();
    _practicalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradeState = ref.watch(gradeNotifierProvider);

    if (widget.gradeId != null &&
        gradeState is AsyncData &&
        gradeState.value != null &&
        !_isCalculating) {
      _populateForm(gradeState.value!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gradeId == null ? 'New Grade' : 'Grade Details'),
        centerTitle: true,
        actions: [
          if (widget.gradeId != null && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (widget.gradeId != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context),
            ),
        ],
      ),
      body:
          gradeState is AsyncLoading && !_isCalculating
              ? const Center(child: CircularProgressIndicator())
              : gradeState is AsyncError && widget.gradeId != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: ${gradeState.error.toString()}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(gradeNotifierProvider.notifier)
                            .getGrade(widget.gradeId!);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _buildForm(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.gradeId != null) _buildGradeSummary(),

            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grade Scores',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Assignment Score
                    TextFormField(
                      controller: _assignmentController,
                      decoration: InputDecoration(
                        labelText: 'Assignment Score',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixText: '/100',
                        enabled: _isEditing,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter assignment score';
                        }
                        final score = double.tryParse(value);
                        if (score == null || score < 0 || score > 100) {
                          return 'Score must be between 0 and 100';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Midterm Score
                    TextFormField(
                      controller: _midtermController,
                      decoration: InputDecoration(
                        labelText: 'Midterm Score',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixText: '/100',
                        enabled: _isEditing,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter midterm score';
                        }
                        final score = double.tryParse(value);
                        if (score == null || score < 0 || score > 100) {
                          return 'Score must be between 0 and 100';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Final Score
                    TextFormField(
                      controller: _finalController,
                      decoration: InputDecoration(
                        labelText: 'Final Score',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixText: '/100',
                        enabled: _isEditing,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter final score';
                        }
                        final score = double.tryParse(value);
                        if (score == null || score < 0 || score > 100) {
                          return 'Score must be between 0 and 100';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Practical Score
                    TextFormField(
                      controller: _practicalController,
                      decoration: InputDecoration(
                        labelText: 'Practical Score',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixText: '/100',
                        enabled: _isEditing,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter practical score';
                        }
                        final score = double.tryParse(value);
                        if (score == null || score < 0 || score > 100) {
                          return 'Score must be between 0 and 100';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Relationship fields (student, subject, etc.)
            if (_isEditing)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Student dropdown
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Student',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: _studentId,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('John Doe')),
                          DropdownMenuItem(value: 2, child: Text('Jane Smith')),
                          DropdownMenuItem(
                            value: 3,
                            child: Text('Bob Johnson'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _studentId = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Subject dropdown
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Subject',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: _subjectId,
                        items: const [
                          DropdownMenuItem(
                            value: 1,
                            child: Text('Mathematics'),
                          ),
                          DropdownMenuItem(value: 2, child: Text('Science')),
                          DropdownMenuItem(value: 3, child: Text('History')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _subjectId = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Semester dropdown
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Semester',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: _semesterId,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Semester 1')),
                          DropdownMenuItem(value: 2, child: Text('Semester 2')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _semesterId = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Grade status dropdown
                      DropdownButtonFormField<GradeStatus>(
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: _gradeStatus,
                        items:
                            GradeStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status.toString().split('.').last),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _gradeStatus = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Notes field
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Teacher Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Catatan guru',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabled: _isEditing,
                      ),
                      maxLines: 4,
                      maxLength: 500,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeSummary() {
    final gradeState = ref.watch(gradeNotifierProvider);
    if (gradeState is! AsyncData || gradeState.value == null) {
      return const SizedBox.shrink();
    }

    final grade = gradeState.value!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Final Grade',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getLetterGradeColor(grade.letterGrade),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    grade.letterGrade.toString().split('.').last,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${grade.finalGrade.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: grade.finalGrade / 100,
              backgroundColor: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              minHeight: 10,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreLabel('Assignment', grade.assignmentScore),
                _buildScoreLabel('Midterm', grade.midtermScore),
                _buildScoreLabel('Final', grade.finalScore),
                _buildScoreLabel('Practical', grade.practicalScore),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreLabel(String label, double score) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          score.toStringAsFixed(1),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    if (!_isEditing && widget.gradeId != null) {
      // View mode
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _calculateFinalGrade,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculate Final Grade'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Edit mode
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (widget.gradeId != null)
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        // Restore original values
                        if (ref.read(gradeNotifierProvider) is AsyncData) {
                          final grade =
                              (ref.read(gradeNotifierProvider) as AsyncData)
                                  .value;
                          if (grade != null) {
                            _populateForm(grade);
                          }
                        }
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              if (widget.gradeId != null) const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _saveGrade,
                  icon: const Icon(Icons.save),
                  label: Text(
                    widget.gradeId == null ? 'Create Grade' : 'Save Changes',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _populateForm(Grade grade) {
    _assignmentController.text = grade.assignmentScore.toString();
    _midtermController.text = grade.midtermScore.toString();
    _finalController.text = grade.finalScore.toString();
    _practicalController.text = grade.practicalScore.toString();
    _notesController.text = grade.notes;

    _studentId = grade.studentId;
    _subjectId = grade.subjectId;
    _teacherId = grade.teacherId;
    _academicYearId = grade.academicYearId;
    _semesterId = grade.semesterId;
    _schoolId = grade.schoolId;
    _gradeStatus = grade.gradeStatus;
    _letterGrade = grade.letterGrade;
  }

  void _saveGrade() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get values from form
    final assignmentScore = double.parse(_assignmentController.text);
    final midtermScore = double.parse(_midtermController.text);
    final finalScore = double.parse(_finalController.text);
    final practicalScore = double.parse(_practicalController.text);
    final notes = _notesController.text;

    // Calculate simple final grade
    final finalGrade =
        (assignmentScore * 0.2) +
        (midtermScore * 0.3) +
        (finalScore * 0.4) +
        (practicalScore * 0.1);

    // Determine letter grade
    final letterGrade = _calculateLetterGrade(finalGrade);

    final grade = Grade(
      id:
          widget.gradeId ??
          DateTime.now().millisecondsSinceEpoch, // Temporary ID for new grades
      assignmentScore: assignmentScore,
      midtermScore: midtermScore,
      finalScore: finalScore,
      practicalScore: practicalScore,
      finalGrade: finalGrade,
      notes: notes,
      gradeStatus: _gradeStatus,
      letterGrade: letterGrade,
      studentId: _studentId,
      subjectId: _subjectId,
      teacherId: _teacherId,
      academicYearId: _academicYearId,
      semesterId: _semesterId,
      schoolId: _schoolId,
    );

    if (widget.gradeId == null) {
      await ref.read(gradeNotifierProvider.notifier).createGrade(grade);
    } else {
      await ref.read(gradeNotifierProvider.notifier).updateGrade(grade);
    }

    if (context.mounted) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.gradeId == null
                ? 'Grade created successfully'
                : 'Grade updated successfully',
          ),
        ),
      );

      if (widget.gradeId == null) {
        Navigator.pop(context);
      }
    }
  }

  LetterGrade _calculateLetterGrade(double score) {
    if (score >= 90) return LetterGrade.A;
    if (score >= 80) return LetterGrade.B;
    if (score >= 70) return LetterGrade.C;
    if (score >= 60) return LetterGrade.D;
    if (score >= 50) return LetterGrade.E;
    return LetterGrade.F;
  }

  Color _getLetterGradeColor(LetterGrade grade) {
    switch (grade) {
      case LetterGrade.A:
        return Colors.green;
      case LetterGrade.B:
        return Colors.blue;
      case LetterGrade.C:
        return Colors.orange;
      case LetterGrade.D:
        return Colors.deepOrange;
      case LetterGrade.E:
      case LetterGrade.F:
        return Colors.red;
    }
  }

  void _calculateFinalGrade() async {
    if (widget.gradeId == null) return;

    setState(() {
      _isCalculating = true;
    });

    await ref
        .read(gradeNotifierProvider.notifier)
        .calculateFinalGrade(widget.gradeId!);

    setState(() {
      _isCalculating = false;
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Final grade calculated successfully')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Grade'),
            content: const Text(
              'Are you sure you want to delete this grade? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(context);

                  if (widget.gradeId != null) {
                    final repository = ref.read(gradeRepositoryProvider);
                    try {
                      await repository.deleteGrade(widget.gradeId!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Grade deleted successfully'),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  }
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

// lib/features/grades/screens/bulk_grade_input_screen.dart
class BulkGradeInputScreen extends ConsumerStatefulWidget {
  final int subjectId;
  final int classroomId;
  final int academicYearId;
  final int semesterId;

  const BulkGradeInputScreen({
    Key? key,
    required this.subjectId,
    required this.classroomId,
    required this.academicYearId,
    required this.semesterId,
  }) : super(key: key);

  @override
  _BulkGradeInputScreenState createState() => _BulkGradeInputScreenState();
}

class _BulkGradeInputScreenState extends ConsumerState<BulkGradeInputScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<StudentGradeRow> _studentRows;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Mock student data
    _studentRows = [
      StudentGradeRow(id: 1, name: 'John Doe'),
      StudentGradeRow(id: 2, name: 'Jane Smith'),
      StudentGradeRow(id: 3, name: 'Bob Johnson'),
      StudentGradeRow(id: 4, name: 'Alice Brown'),
      StudentGradeRow(id: 5, name: 'Michael Davis'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bulk Grade Input'), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Subject: Mathematics',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  Text(
                                    'Class: 10A • Semester: 1 • Academic Year: 2023/2024',
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildTableHeader(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _studentRows.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemBuilder: (context, index) {
                          return _buildStudentRow(_studentRows[index], index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: _submitGrades,
            icon: const Icon(Icons.save),
            label: const Text('Save All Grades'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: Text(
              'Student',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                'Assignment',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                'Midterm',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                'Final',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                'Practical',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRow(StudentGradeRow student, int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(student.name)),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextFormField(
                controller: student.assignmentController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: _validateScore,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextFormField(
                controller: student.midtermController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: _validateScore,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextFormField(
                controller: student.finalController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: _validateScore,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextFormField(
                controller: student.practicalController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: _validateScore,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateScore(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }
    final score = double.tryParse(value);
    if (score == null || score < 0 || score > 100) {
      return '';
    }
    return null;
  }

  void _submitGrades() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check all scores are between 0 and 100'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final grades =
          _studentRows.map((student) {
            // Calculate simple final grade
            final assignmentScore =
                double.tryParse(student.assignmentController.text) ?? 0.0;
            final midtermScore =
                double.tryParse(student.midtermController.text) ?? 0.0;
            final finalScore =
                double.tryParse(student.finalController.text) ?? 0.0;
            final practicalScore =
                double.tryParse(student.practicalController.text) ?? 0.0;

            final finalGrade =
                (assignmentScore * 0.2) +
                (midtermScore * 0.3) +
                (finalScore * 0.4) +
                (practicalScore * 0.1);

            final letterGrade = _calculateLetterGrade(finalGrade);

            return Grade(
              id: DateTime.now().millisecondsSinceEpoch + student.id,
              assignmentScore: assignmentScore,
              midtermScore: midtermScore,
              finalScore: finalScore,
              practicalScore: practicalScore,
              finalGrade: finalGrade,
              notes: '',
              gradeStatus: GradeStatus.draft,
              letterGrade: LetterGrade.A, //letterGrade,
              studentId: student.id,
              subjectId: widget.subjectId,
              teacherId: 1, // Assuming current teacher id
              academicYearId: widget.academicYearId,
              semesterId: widget.semesterId,
              schoolId: 1, // Assuming current school id
            );
          }).toList();

      // Call the provider to submit the grades
      await ref
          .read(gradeProvider.notifier)
          .bulkInputGrades(
            grades: grades,
            subjectId: widget.subjectId,
            classroomId: widget.classroomId,
            academicYearId: widget.academicYearId,
            semesterId: widget.semesterId,
          );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grades saved successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to previous screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving grades: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _calculateLetterGrade(double finalGrade) {
    // Simple letter grade calculation
    if (finalGrade >= 90) return 'A';
    if (finalGrade >= 80) return 'B';
    if (finalGrade >= 70) return 'C';
    if (finalGrade >= 60) return 'D';
    return 'F';
  }
}

class StudentGradeRow {
  final int id;
  final String name;
  final TextEditingController assignmentController = TextEditingController();
  final TextEditingController midtermController = TextEditingController();
  final TextEditingController finalController = TextEditingController();
  final TextEditingController practicalController = TextEditingController();

  StudentGradeRow({required this.id, required this.name});
}
