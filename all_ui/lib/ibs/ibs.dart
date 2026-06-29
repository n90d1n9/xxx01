import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'models/enums.dart';
import 'models/hafidz_progress.dart';
import 'models/student.dart';
import 'models/surah.dart';
import 'models/teacher.dart';

// Providers
final studentProvider = FutureProvider<Student>((ref) async {
  // In a real app, you would fetch the student from a repository
  return fetchCurrentStudent(); // Assume this function exists
});

final surahListProvider = FutureProvider<List<Surah>>((ref) async {
  // In a real app, you would fetch all surahs from a repository
  return fetchAllSurahs(); // Assume this function exists
});

final hafizProgressesProvider = FutureProvider.family<List<HafizProgress>, int>(
  (ref, studentId) async {
    // In a real app, you would fetch progresses from a repository
    return fetchHafizProgressesForStudent(
      studentId,
    ); // Assume this function exists
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
      final newProgress = await createHafizProgress(
        studentId: studentId,
        surahId: surahId,
        date: date,
        startVerse: startVerse,
        endVerse: endVerse,
        comments: comments,
        qualityScore: qualityScore,
        status: status,
      ); // Assume this function exists

      state = AsyncValue.data(newProgress);
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

class HafizProgressScreen extends ConsumerStatefulWidget {
  final int studentId;

  const HafizProgressScreen({super.key, required this.studentId});

  @override
  ConsumerState<HafizProgressScreen> createState() =>
      _HafizProgressScreenState();
}

class _HafizProgressScreenState extends ConsumerState<HafizProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy');

  // Form variables
  final _formKey = GlobalKey<FormState>();
  int? _selectedSurahId;
  DateTime _selectedDate = DateTime.now();
  int _startVerse = 1;
  int _endVerse = 1;
  String _comments = '';
  double _qualityScore = 7.0;
  MemorizationStatus _status = MemorizationStatus.inProgress;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentAsync = ref.watch(studentProvider);
    final surahsAsync = ref.watch(surahListProvider);
    final progressesAsync = ref.watch(
      hafizProgressesProvider(widget.studentId),
    );
    final saveProgressState = ref.watch(hafizProgressNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: studentAsync.when(
          data: (student) => Text('${student.firstName}\'s Hafiz Progress'),
          loading: () => const Text('Loading...'),
          error: (error, _) => Text('Error: ${error.toString()}'),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'History', icon: Icon(Icons.history)),
            Tab(text: 'Add Progress', icon: Icon(Icons.add)),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          _buildOverviewTab(studentAsync, progressesAsync),

          // History Tab
          _buildHistoryTab(progressesAsync, surahsAsync),

          // Add Progress Tab
          _buildAddProgressTab(surahsAsync, saveProgressState),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    AsyncValue<Student> studentAsync,
    AsyncValue<List<HafizProgress>> progressesAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          studentAsync.when(
            data: (student) => _buildStudentInfoCard(student),
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, _) => Center(child: Text('Error loading student data')),
          ),
          const SizedBox(height: 24),
          const Text(
            'Memorization Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          progressesAsync.when(
            data: (progresses) => _buildProgressOverview(progresses),
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, _) =>
                    Center(child: Text('Error loading progress data')),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          progressesAsync.when(
            data: (progresses) => _buildRecentActivity(progresses),
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, _) =>
                    Center(child: Text('Error loading activity data')),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfoCard(Student student) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.2),
                  child: Text(
                    student.firstName.substring(0, 1) +
                        (student.lastName?.isNotEmpty == true
                            ? student.lastName!.substring(0, 1)
                            : ''),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${student.firstName} ${student.lastName ?? ''}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Registration: ${student.registrationNumber}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enrolled: ${_dateFormat.format(student.enrollmentDate)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressOverview(List<HafizProgress> progresses) {
    if (progresses.isEmpty) {
      return const Center(
        child: Text(
          'No progress recorded yet.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Here you would aggregate the data to show overall progress
    // For demonstration, we'll show a simple chart

    // Calculate total verses memorized
    final totalVerses = progresses.fold<int>(
      0,
      (sum, progress) => sum + (progress.endVerse - progress.startVerse + 1),
    );

    // Calculate average quality score
    final avgQuality =
        progresses.isEmpty
            ? 0.0
            : progresses.fold<double>(
                  0,
                  (sum, progress) => sum + progress.qualityScore,
                ) /
                progresses.length;

    return Column(
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Total Verses',
                        totalVerses.toString(),
                        Icons.menu_book,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Surahs',
                        progresses
                            .map((p) => p.surah.number)
                            .toSet()
                            .length
                            .toString(),
                        Icons.bookmark,
                        Colors.amber,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Avg. Quality',
                        avgQuality.toStringAsFixed(1),
                        Icons.star,
                        Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Show last 5 entries only
                          final recentEntries =
                              progresses.length > 5
                                  ? progresses.sublist(progresses.length - 5)
                                  : progresses;

                          if (value.toInt() >= recentEntries.length) {
                            return const Text('');
                          }

                          return Text(
                            DateFormat(
                              'MM/dd',
                            ).format(recentEntries[value.toInt()].date),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  barGroups: _getQualityBarGroups(progresses),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _getQualityBarGroups(List<HafizProgress> progresses) {
    // Show last 5 entries only for quality scores
    final recentEntries =
        progresses.length > 5
            ? progresses.sublist(progresses.length - 5)
            : progresses;

    return List.generate(
      recentEntries.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: recentEntries[index].qualityScore,
            color: Theme.of(context).primaryColor,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildRecentActivity(List<HafizProgress> progresses) {
    if (progresses.isEmpty) {
      return const Center(
        child: Text(
          'No activities recorded yet.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Sort progresses by date (most recent first)
    final sortedProgresses = [...progresses]
      ..sort((a, b) => b.date.compareTo(a.date));

    // Show only the most recent 5 entries
    final recentProgresses = sortedProgresses.take(5).toList();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentProgresses.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final progress = recentProgresses[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: _getStatusIcon(progress.memorizationStatus),
            title: Text(
              'Surah ${progress.surah.name} (${progress.surah.transliteration})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Verses ${progress.startVerse}-${progress.endVerse}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  _dateFormat.format(progress.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getQualityColor(
                      progress.qualityScore,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${progress.qualityScore.toStringAsFixed(1)}/10',
                    style: TextStyle(
                      color: _getQualityColor(progress.qualityScore),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _getStatusIcon(MemorizationStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case MemorizationStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case MemorizationStatus.inProgress:
        icon = Icons.schedule;
        color = Colors.orange;
        break;
      case MemorizationStatus.needsRevision:
        icon = Icons.refresh;
        color = Colors.red;
        break;
      case MemorizationStatus.mastered:
        icon = Icons.star;
        color = Colors.amber;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }

  Color _getQualityColor(double score) {
    if (score >= 8.5) return Colors.green;
    if (score >= 7.0) return Colors.blue;
    if (score >= 5.0) return Colors.orange;
    return Colors.red;
  }

  Widget _buildHistoryTab(
    AsyncValue<List<HafizProgress>> progressesAsync,
    AsyncValue<List<Surah>> surahsAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 8),
                  const Text('Filter by Surah:'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: surahsAsync.when(
                      data:
                          (surahs) => DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            value: null,
                            hint: const Text('All Surahs'),
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('All Surahs'),
                              ),
                              ...surahs.map(
                                (surah) => DropdownMenuItem<int>(
                                  value: surah.id,
                                  child: Text(
                                    '${surah.number}. ${surah.transliteration}',
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              // In a real app, you would implement filtering logic here
                            },
                          ),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('Failed to load surahs'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: progressesAsync.when(
              data: (progresses) {
                if (progresses.isEmpty) {
                  return const Center(
                    child: Text(
                      'No history available',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                // Group progresses by month
                final groupedProgresses = <String, List<HafizProgress>>{};
                for (var progress in progresses) {
                  final monthYear = DateFormat(
                    'MMMM yyyy',
                  ).format(progress.date);
                  groupedProgresses.putIfAbsent(monthYear, () => []);
                  groupedProgresses[monthYear]!.add(progress);
                }

                // Sort groups by date (most recent first)
                final sortedMonths =
                    groupedProgresses.keys.toList()..sort((a, b) {
                      final aDate = DateFormat('MMMM yyyy').parse(a);
                      final bDate = DateFormat('MMMM yyyy').parse(b);
                      return bDate.compareTo(aDate);
                    });

                return ListView.builder(
                  itemCount: sortedMonths.length,
                  itemBuilder: (context, index) {
                    final month = sortedMonths[index];
                    final monthProgresses = groupedProgresses[month]!;

                    // Sort progresses within each month (most recent first)
                    monthProgresses.sort((a, b) => b.date.compareTo(a.date));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            month,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: monthProgresses.length,
                            separatorBuilder:
                                (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final progress = monthProgresses[index];
                              return ExpansionTile(
                                leading: _getStatusIcon(
                                  progress.memorizationStatus,
                                ),
                                title: Text(
                                  'Surah ${progress.surah.name} (${progress.surah.transliteration})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${DateFormat('MMM d').format(progress.date)} • Verses ${progress.startVerse}-${progress.endVerse}',
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getQualityColor(
                                      progress.qualityScore,
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${progress.qualityScore.toStringAsFixed(1)}/10',
                                    style: TextStyle(
                                      color: _getQualityColor(
                                        progress.qualityScore,
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Comments:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          progress.comments!.isNotEmpty
                                              ? progress.comments!
                                              : 'No comments provided',
                                          style: TextStyle(
                                            fontStyle:
                                                progress.comments!.isEmpty
                                                    ? FontStyle.italic
                                                    : FontStyle.normal,
                                            color:
                                                progress.comments!.isEmpty
                                                    ? Colors.grey[500]
                                                    : null,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Assessed by: ${progress.assessor.firstName} ${progress.assessor.lastName ?? ''}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (_, __) =>
                      const Center(child: Text('Failed to load history')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddProgressTab(
    AsyncValue<List<Surah>> surahsAsync,
    AsyncValue<HafizProgress?> saveProgressState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Memorization Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Surah selection
                    Text('Surah', style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    surahsAsync.when(
                      data:
                          (surahs) => DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            value: _selectedSurahId,
                            hint: const Text('Select Surah'),
                            isExpanded: true,
                            items:
                                surahs
                                    .map(
                                      (surah) => DropdownMenuItem<int>(
                                        value: surah.id,
                                        child: Text(
                                          '${surah.number}. ${surah.transliteration} (${surah.translation}) - ${surah.totalVerses} verses',
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSurahId = value;
                                // Reset verse range when surah changes
                                final selectedSurah = surahs.firstWhere(
                                  (s) => s.id == value,
                                );
                                _startVerse = 1;
                                _endVerse = _startVerse;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a surah';
                              }
                              return null;
                            },
                          ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('Failed to load surahs'),
                    ),
                    const SizedBox(height: 16),

                    // Date selection
                    Text('Date', style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(_dateFormat.format(_selectedDate)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Verse range
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Verse',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                initialValue: _startVerse.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _startVerse = int.tryParse(value) ?? 1;
                                    // Ensure end verse is not less than start verse
                                    if (_endVerse < _startVerse) {
                                      _endVerse = _startVerse;
                                    }
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (int.tryParse(value) == null ||
                                      int.parse(value) < 1) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Verse',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                initialValue: _endVerse.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _endVerse =
                                        int.tryParse(value) ?? _startVerse;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (int.tryParse(value) == null ||
                                      int.parse(value) < _startVerse) {
                                    return 'Must be >= start verse';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Status
                    Text('Status', style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<MemorizationStatus>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      value: _status,
                      isExpanded: true,
                      items:
                          MemorizationStatus.values
                              .map(
                                (status) =>
                                    DropdownMenuItem<MemorizationStatus>(
                                      value: status,
                                      child: Text(_getStatusText(status)),
                                    ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _status = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Quality score
                    Text(
                      'Quality Score (1-10)',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _qualityScore,
                            min: 0,
                            max: 10,
                            divisions: 20,
                            label: _qualityScore.toStringAsFixed(1),
                            onChanged: (value) {
                              setState(() {
                                _qualityScore = value;
                              });
                            },
                          ),
                        ),
                        Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getQualityColor(
                              _qualityScore,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _qualityScore.toStringAsFixed(1),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _getQualityColor(_qualityScore),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Comments
                    Text('Comments', style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        hintText: 'Enter any comments or notes',
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        setState(() {
                          _comments = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Save progress
                  ref
                      .read(hafizProgressNotifierProvider.notifier)
                      .saveProgress(
                        studentId: widget.studentId,
                        surahId: _selectedSurahId!,
                        date: _selectedDate,
                        startVerse: _startVerse,
                        endVerse: _endVerse,
                        comments: _comments,
                        qualityScore: _qualityScore,
                        status: _status,
                      );
                }
              },
              child: saveProgressState.when(
                data: (_) => const Text('SAVE PROGRESS'),
                loading:
                    () => const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                error: (_, __) => const Text('RETRY'),
              ),
            ),

            // Success message
            if (saveProgressState is AsyncData &&
                saveProgressState.value != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Card(
                  color: Colors.green[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Progress saved successfully!',
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Error message
            if (saveProgressState is AsyncError)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Card(
                  color: Colors.red[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Failed to save progress. Please try again.',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(MemorizationStatus status) {
    switch (status) {
      case MemorizationStatus.inProgress:
        return 'In Progress';
      case MemorizationStatus.completed:
        return 'Completed';
      case MemorizationStatus.needsRevision:
        return 'Needs Revision';
      case MemorizationStatus.mastered:
        return 'Mastered';
      default:
        return 'Unknown';
    }
  }
}

// These are the assumed model classes and enums for reference

// Repository functions implementation

Future<Student> fetchCurrentStudent() async {
  // In a real app, this would fetch from an API or local database
  // For demo purposes, returning mock data
  await Future.delayed(
    const Duration(milliseconds: 800),
  ); // Simulate network delay

  return Student(
    id: 1,
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

  return [
    Surah(
      id: 1,
      number: 1,
      name: "الفاتحة",
      transliteration: "Al-Fatihah",
      translation: "The Opening",
      totalVerses: 7,
      type: "Meccan",
    ),
    Surah(
      id: 2,
      number: 2,
      name: "البقرة",
      transliteration: "Al-Baqarah",
      translation: "The Cow",
      totalVerses: 286,
      type: "Medinan",
    ),
    Surah(
      id: 3,
      number: 3,
      name: "آل عمران",
      transliteration: "Ali 'Imran",
      translation: "Family of Imran",
      totalVerses: 200,
      type: "Medinan",
    ),
    Surah(
      id: 4,
      number: 4,
      name: "النساء",
      transliteration: "An-Nisa",
      translation: "The Women",
      totalVerses: 176,
      type: "Medinan",
    ),
    Surah(
      id: 5,
      number: 5,
      name: "المائدة",
      transliteration: "Al-Ma'idah",
      translation: "The Table Spread",
      totalVerses: 120,
      type: "Medinan",
    ),
    Surah(
      id: 36,
      number: 36,
      name: "يس",
      transliteration: "Ya-Sin",
      translation: "Ya Sin",
      totalVerses: 83,
      type: "Meccan",
    ),
    Surah(
      id: 112,
      number: 112,
      name: "الإخلاص",
      transliteration: "Al-Ikhlas",
      translation: "Sincerity",
      totalVerses: 4,
      type: "Meccan",
    ),
    Surah(
      id: 113,
      number: 113,
      name: "الفلق",
      transliteration: "Al-Falaq",
      translation: "The Daybreak",
      totalVerses: 5,
      type: "Meccan",
    ),
    Surah(
      id: 114,
      number: 114,
      name: "الناس",
      transliteration: "An-Nas",
      translation: "Mankind",
      totalVerses: 6,
      type: "Meccan",
    ),
  ];
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
  return [
    HafizProgress(
      id: 1,
      date: DateTime.now().subtract(const Duration(days: 1)),
      startVerse: 1,
      endVerse: 7,
      comments: "Excellent tajweed application, good fluency.",
      qualityScore: 9.0,
      memorizationStatus: MemorizationStatus.completed,
      student: student,
      surah: surahs.firstWhere((s) => s.number == 1), // Al-Fatihah
      assessor: teacher,
    ),
    HafizProgress(
      id: 2,
      date: DateTime.now().subtract(const Duration(days: 3)),
      startVerse: 1,
      endVerse: 5,
      comments: "Good pronunciation, but needs to work on fluency.",
      qualityScore: 7.5,
      memorizationStatus: MemorizationStatus.inProgress,
      student: student,
      surah: surahs.firstWhere((s) => s.number == 112), // Al-Ikhlas
      assessor: teacher,
    ),
    HafizProgress(
      id: 3,
      date: DateTime.now().subtract(const Duration(days: 5)),
      startVerse: 1,
      endVerse: 5,
      comments: "Struggled with pronunciation of certain words.",
      qualityScore: 6.0,
      memorizationStatus: MemorizationStatus.needsRevision,
      student: student,
      surah: surahs.firstWhere((s) => s.number == 113), // Al-Falaq
      assessor: teacher,
    ),
    HafizProgress(
      id: 4,
      date: DateTime.now().subtract(const Duration(days: 7)),
      startVerse: 1,
      endVerse: 6,
      comments: "Excellent work. All verses memorized perfectly.",
      qualityScore: 9.5,
      memorizationStatus: MemorizationStatus.mastered,
      student: student,
      surah: surahs.firstWhere((s) => s.number == 114), // An-Nas
      assessor: teacher,
    ),
    HafizProgress(
      id: 5,
      date: DateTime.now().subtract(const Duration(days: 14)),
      startVerse: 1,
      endVerse: 10,
      comments: "Good start on this surah, making progress.",
      qualityScore: 7.0,
      memorizationStatus: MemorizationStatus.inProgress,
      student: student,
      surah: surahs.firstWhere((s) => s.number == 2), // Al-Baqarah
      assessor: teacher,
    ),
    HafizProgress(
      id: 6,
      date: DateTime.now().subtract(const Duration(days: 16)),
      startVerse: 11,
      endVerse: 20,
      comments: "Continued progress, but needs to work on verse 15-17.",
      qualityScore: 6.5,
      memorizationStatus: MemorizationStatus.needsRevision,
      student: student,
      surah: surahs.firstWhere((s) => s.number == 2), // Al-Baqarah
      assessor: teacher,
    ),
    HafizProgress(
      id: 7,
      date: DateTime.now().subtract(const Duration(days: 45)),
      startVerse: 1,
      endVerse: 10,
      comments: "Started memorization of Ya-Sin with good tajweed.",
      qualityScore: 8.0,
      memorizationStatus: MemorizationStatus.inProgress,
      student: student,
      surah: surahs.firstWhere((s) => s.number == 36), // Ya-Sin
      assessor: teacher,
    ),
  ];
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
    surah: surah,
    assessor: teacher,
  );
}

// Simple Teacher class for the mock functions
void main() {
  runApp(
    ProviderScope(
      child: const MaterialApp(home: HafizProgressScreen(studentId: 1)),
    ),
  );
}
