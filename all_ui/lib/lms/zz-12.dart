import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:flutter_riverpod/legacy.dart';

class TryOutCard extends StatelessWidget {
  final TryOutSession tryOut;
  final WidgetRef ref;

  const TryOutCard({super.key, required this.tryOut, required this.ref});

  @override
  Widget build(BuildContext context) {
    final daysUntil = tryOut.scheduledDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tryOut.examType.name.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, size: 12, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '$daysUntil hari',
                      style: const TextStyle(
                        fontSize: 11,
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.timer, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${tryOut.duration.inMinutes} menit',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(width: 12),
              Icon(Icons.quiz, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${tryOut.totalQuestions} soal',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TryOutDetailScreen(tryOut: tryOut),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mulai Try Out'),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== TRY OUT LIST SCREEN ====================

class TryOutListScreen extends ConsumerWidget {
  const TryOutListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tryOuts = ref.watch(tryOutsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Try Out'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: tryOuts.length,
        itemBuilder: (context, index) {
          return TryOutCard(tryOut: tryOuts[index], ref: ref);
        },
      ),
    );
  }
}

// ==================== TRY OUT DETAIL SCREEN ====================

class TryOutDetailScreen extends ConsumerWidget {
  final TryOutSession tryOut;

  const TryOutDetailScreen({super.key, required this.tryOut});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Try Out')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  Text(
                    tryOut.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.calendar_today,
                    _formatDate(tryOut.scheduledDate),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.timer,
                    '${tryOut.duration.inMinutes} menit',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.quiz, '${tryOut.totalQuestions} soal'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Mata Pelajaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  tryOut.subjects.map((subject) {
                    return Chip(
                      label: Text(_getSubjectName(subject)),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Informasi Penting',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              Icons.info_outline,
              'Pastikan koneksi internet stabil',
              Colors.blue,
            ),
            _buildInfoCard(
              Icons.warning_amber,
              'Tidak bisa keluar setelah memulai',
              Colors.orange,
            ),
            _buildInfoCard(
              Icons.check_circle_outline,
              'Jawaban otomatis tersimpan',
              Colors.green,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(activeTryOutProvider.notifier).state = tryOut;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TryOutExamScreen(tryOut: tryOut),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Mulai Try Out Sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: color.withOpacity(0.9))),
          ),
        ],
      ),
    );
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

  String _getSubjectName(SubjectCategory category) {
    const names = {
      SubjectCategory.matematikaSaintek: 'Matematika',
      SubjectCategory.fisika: 'Fisika',
      SubjectCategory.kimia: 'Kimia',
      SubjectCategory.biologi: 'Biologi',
      SubjectCategory.penalaranMatematika: 'Penalaran Matematika',
    };
    return names[category] ?? category.name;
  }
}

// ==================== TRY OUT EXAM SCREEN ====================

class TryOutExamScreen extends ConsumerStatefulWidget {
  final TryOutSession tryOut;

  const TryOutExamScreen({super.key, required this.tryOut});

  @override
  ConsumerState<TryOutExamScreen> createState() => _TryOutExamScreenState();
}

class _TryOutExamScreenState extends ConsumerState<TryOutExamScreen> {
  int _currentQuestion = 0;
  final Map<String, int> _answers = {};
  late DateTime _startTime;
  Duration _timeRemaining = const Duration();

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _timeRemaining = widget.tryOut.duration;
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _timeRemaining.inSeconds > 0) {
        setState(() {
          _timeRemaining = _timeRemaining - const Duration(seconds: 1);
        });
        _startTimer();
      } else if (_timeRemaining.inSeconds == 0) {
        _submitTryOut();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tryOut.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Try Out')),
        body: const Center(child: Text('Tidak ada soal tersedia')),
      );
    }

    final question = widget.tryOut.questions[_currentQuestion];

    return WillPopScope(
      onWillPop: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Keluar dari Try Out?'),
                content: const Text(
                  'Progres kamu akan hilang jika keluar sekarang.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Keluar'),
                  ),
                ],
              ),
        );
        return confirm ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Soal ${_currentQuestion + 1}/${widget.tryOut.questions.length}',
          ),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color:
                    _timeRemaining.inMinutes < 5
                        ? Colors.red
                        : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 18,
                    color: _timeRemaining.inMinutes < 5 ? Colors.white : null,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDuration(_timeRemaining),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _timeRemaining.inMinutes < 5 ? Colors.white : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / widget.tryOut.questions.length,
              backgroundColor: Colors.grey[200],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getSubjectName(question.subject),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      question.question,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    ...question.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isSelected = _answers[question.id] == index;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap:
                              () =>
                                  setState(() => _answers[question.id] = index),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer
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
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                            : Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index),
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentQuestion > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentQuestion--),
                        child: const Text('Sebelumnya'),
                      ),
                    ),
                  if (_currentQuestion > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentQuestion <
                            widget.tryOut.questions.length - 1) {
                          setState(() => _currentQuestion++);
                        } else {
                          _submitTryOut();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _currentQuestion < widget.tryOut.questions.length - 1
                            ? 'Selanjutnya'
                            : 'Selesai',
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _submitTryOut() {
    // Calculate score
    int correctCount = 0;
    int wrongCount = 0;
    int blankCount = 0;

    for (final question in widget.tryOut.questions) {
      if (_answers.containsKey(question.id)) {
        if (_answers[question.id] == question.correctAnswer) {
          correctCount++;
        } else {
          wrongCount++;
        }
      } else {
        blankCount++;
      }
    }

    final totalScore = correctCount * 4;
    final maxScore = widget.tryOut.questions.length * 4;
    final percentage = (totalScore / maxScore * 100);

    final result = TryOutResult(
      id: 'result_${DateTime.now().millisecondsSinceEpoch}',
      studentId: 'user1',
      tryOutId: widget.tryOut.id,
      scores: {
        SubjectCategory.matematikaSaintek: SubjectScore(
          subject: SubjectCategory.matematikaSaintek,
          score: totalScore,
          maxScore: maxScore,
          correct: correctCount,
          wrong: wrongCount,
          blank: blankCount,
          percentage: percentage,
        ),
      },
      completedAt: DateTime.now(),
      totalScore: totalScore,
      maxScore: maxScore,
      percentage: percentage,
      ranking: 15,
      totalParticipants: 234,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TryOutResultScreen(result: result)),
    );
  }

  String _getSubjectName(SubjectCategory category) {
    const names = {
      SubjectCategory.matematikaSaintek: 'Matematika Saintek',
      SubjectCategory.fisika: 'Fisika',
    };
    return names[category] ?? category.name;
  }
}

// ==================== TRY OUT RESULT SCREEN ====================

class TryOutResultScreen extends StatelessWidget {
  final TryOutResult result;

  const TryOutResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Try Out'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
                  const SizedBox(height: 16),
                  const Text(
                    'Selamat!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kamu mendapat skor ${result.totalScore}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${result.percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildRankingCard(context),
            const SizedBox(height: 20),
            _buildScoreBreakdown(context),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        () => Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst),
                    child: const Text('Kembali ke Beranda'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Lihat Pembahasan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingCard(BuildContext context) {
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.orange,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peringkat #${result.ranking}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'dari ${result.totalParticipants} peserta',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown(BuildContext context) {
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
          const Text(
            'Rincian Jawaban',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...result.scores.values.map((score) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('Benar', score.correct, Colors.green),
                    _buildStatItem('Salah', score.wrong, Colors.red),
                    _buildStatItem('Kosong', score.blank, Colors.grey),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}

// ==================== STUDY MATERIALS SCREEN ====================

class StudyMaterialsScreen extends ConsumerWidget {
  const StudyMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Materi Belajar')),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getColor(index),
                        _getColor(index).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Icon(_getIcon(index), size: 40, color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Materi ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Matematika',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
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

  Color _getColor(int index) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF10B981),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
    ];
    return colors[index % colors.length];
  }

  IconData _getIcon(int index) {
    final icons = [
      Icons.play_circle_outline,
      Icons.picture_as_pdf,
      Icons.quiz,
      Icons.description,
    ];
    return icons[index % icons.length];
  }
}

// ==================== LEADERBOARD SCREEN ====================

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Peringkat')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: leaderboard.length,
        itemBuilder: (context, index) {
          final entry = leaderboard[index];
          final isCurrentUser = entry.userId == 'user1';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isCurrentUser
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isCurrentUser
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[200]!,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getRankColor(entry.rank),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      entry.rank.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(entry.avatar, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${entry.tryOutsCompleted} Try Out • ${entry.averageScore.toStringAsFixed(1)}%',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${entry.totalScore}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return const Color(0xFF6366F1);
  }
}

// ==================== DISCUSSION FORUM SCREEN ====================

class DiscussionForumScreen extends ConsumerWidget {
  const DiscussionForumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discussions = ref.watch(discussionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum Diskusi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateDiscussionScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: discussions.length,
        itemBuilder: (context, index) {
          final discussion = discussions[index];
          return DiscussionCard(discussion: discussion);
        },
      ),
    );
  }
}

class DiscussionCard extends StatelessWidget {
  final DiscussionThread discussion;

  const DiscussionCard({super.key, required this.discussion});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
            children: [
              CircleAvatar(child: Text(discussion.authorName[0])),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      discussion.authorName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatTime(discussion.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (discussion.subject != null)
                Chip(
                  label: Text(
                    _getSubjectName(discussion.subject!),
                    style: const TextStyle(fontSize: 11),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            discussion.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            discussion.content,
            style: TextStyle(color: Colors.grey[700]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatButton(
                Icons.thumb_up_outlined,
                discussion.likes.toString(),
              ),
              const SizedBox(width: 16),
              _buildStatButton(
                Icons.chat_bubble_outline,
                discussion.replies.toString(),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => DiscussionDetailScreen(discussion: discussion),
                    ),
                  );
                },
                child: const Text('Lihat Detail'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatButton(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(count, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 24) return '${diff.inHours}j yang lalu';
    return '${diff.inDays}h yang lalu';
  }

  String _getSubjectName(SubjectCategory category) {
    const names = {
      SubjectCategory.matematikaSaintek: 'Matematika',
      SubjectCategory.fisika: 'Fisika',
    };
    return names[category] ?? category.name;
  }
}

// ==================== DISCUSSION DETAIL SCREEN ====================

class DiscussionDetailScreen extends ConsumerStatefulWidget {
  final DiscussionThread discussion;

  const DiscussionDetailScreen({super.key, required this.discussion});

  @override
  ConsumerState<DiscussionDetailScreen> createState() =>
      _DiscussionDetailScreenState();
}

class _DiscussionDetailScreenState
    extends ConsumerState<DiscussionDetailScreen> {
  final _replyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diskusi')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        child: Text(widget.discussion.authorName[0]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.discussion.authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _formatTime(widget.discussion.createdAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.discussion.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.discussion.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildActionButton(
                        Icons.thumb_up_outlined,
                        widget.discussion.likes.toString(),
                      ),
                      const SizedBox(width: 16),
                      _buildActionButton(Icons.share, 'Bagikan'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '${widget.discussion.replies} Balasan',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.discussion.replyList.map(
                    (reply) => _buildReplyCard(reply),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Tulis balasan...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      // Add reply logic
                      _replyController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Balasan terkirim!')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildReplyCard(DiscussionReply reply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                child: Text(
                  reply.authorName[0],
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reply.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatTime(reply.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(reply.content),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.thumb_up_outlined, size: 16),
                label: Text(reply.likes.toString()),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 24) return '${diff.inHours}j yang lalu';
    return '${diff.inDays}h yang lalu';
  }
}

// ==================== CREATE DISCUSSION SCREEN ====================

class CreateDiscussionScreen extends ConsumerStatefulWidget {
  const CreateDiscussionScreen({super.key});

  @override
  ConsumerState<CreateDiscussionScreen> createState() =>
      _CreateDiscussionScreenState();
}

class _CreateDiscussionScreenState
    extends ConsumerState<CreateDiscussionScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  SubjectCategory? _selectedSubject;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Diskusi Baru'),
        actions: [
          TextButton(
            onPressed: _submitDiscussion,
            child: const Text('Posting'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kategori',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  SubjectCategory.values.take(6).map((subject) {
                    final isSelected = _selectedSubject == subject;
                    return FilterChip(
                      label: Text(_getSubjectName(subject)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(
                          () => _selectedSubject = selected ? subject : null,
                        );
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Judul',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Tulis judul diskusi...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Deskripsi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Jelaskan pertanyaan atau topik diskusi kamu...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitDiscussion() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi judul dan deskripsi')),
      );
      return;
    }

    final newDiscussion = DiscussionThread(
      id: 'disc_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      content: _contentController.text,
      authorId: 'user1',
      authorName: 'Budi Santoso',
      subject: _selectedSubject,
      createdAt: DateTime.now(),
      likes: 0,
      replies: 0,
    );

    ref.read(discussionsProvider.notifier).state = [
      newDiscussion,
      ...ref.read(discussionsProvider),
    ];

    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Diskusi berhasil dibuat!')));
  }

  String _getSubjectName(SubjectCategory category) {
    const names = {
      SubjectCategory.matematikaSaintek: 'Matematika',
      SubjectCategory.fisika: 'Fisika',
      SubjectCategory.kimia: 'Kimia',
      SubjectCategory.biologi: 'Biologi',
      SubjectCategory.penalaranMatematika: 'Penalaran Matematika',
      SubjectCategory.literasiBahasaIndonesia: 'B. Indonesia',
    };
    return names[category] ?? category.name;
  }
} // pubspec.yaml dependencies:
// flutter_riverpod: ^2.4.0
// firebase_core: ^2.24.0
// firebase_auth: ^4.15.0
// cloud_firestore: ^4.13.0
// firebase_storage: ^11.5.0
// shared_preferences: ^2.2.0
// fl_chart: ^0.65.0

// ==================== COMPREHENSIVE MODELS ====================

class User {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final UserRole role;
  final DateTime joinedDate;
  final String? photoUrl;
  final bool isEmailVerified;
  final StudyLevel? studyLevel;
  final List<String> targetUniversities;
  final String? phoneNumber;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.role,
    required this.joinedDate,
    this.photoUrl,
    this.isEmailVerified = false,
    this.studyLevel,
    this.targetUniversities = const [],
    this.phoneNumber,
  });
}

enum UserRole { student, instructor, admin }

enum StudyLevel { sma10, sma11, sma12, alumni, university }

enum ExamType { snbt, snbp, simak, um, sbmptn, utbk }

enum SubjectCategory {
  penalaranMatematika,
  literasiBahasaIndonesia,
  literasiBahasaInggris,
  penalaran,
  matematikaSaintek,
  fisika,
  kimia,
  biologi,
  geografiSejarah,
  sosiologi,
  ekonomi,
  matematikaSMA,
  bahasaIndonesia,
  bahasaInggris,
  ipa,
  ips,
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
  final List<TryOutQuestion> questions;

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
    this.questions = const [],
  });
}

enum TryOutStatus { upcoming, ongoing, completed, graded }

class TryOutQuestion {
  final String id;
  final SubjectCategory subject;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;
  final int points;

  TryOutQuestion({
    required this.id,
    required this.subject,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.points = 1,
  });
}

class TryOutSubmission {
  final String id;
  final String studentId;
  final String tryOutId;
  final Map<String, int> answers; // questionId -> answer index
  final DateTime startedAt;
  final DateTime? submittedAt;
  final bool isCompleted;

  TryOutSubmission({
    required this.id,
    required this.studentId,
    required this.tryOutId,
    required this.answers,
    required this.startedAt,
    this.submittedAt,
    this.isCompleted = false,
  });
}

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
  final String? description;

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
    this.description,
  });
}

enum MaterialType { video, pdf, soalLatihan, rangkuman, mindMap, flashcard }

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
  final String? description;

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
    this.description,
  });
}

enum ClassStatus { scheduled, live, completed, cancelled }

class StudentProgress {
  final String studentId;
  final StudyLevel level;
  final Map<SubjectCategory, SubjectProgress> subjectProgress;
  final List<String> completedMaterials;
  final List<String> completedTryOuts;
  final double averageScore;
  final int studyStreak;
  final DateTime lastStudyDate;
  final int totalStudyHours;
  final List<Achievement> achievements;

  StudentProgress({
    required this.studentId,
    required this.level,
    required this.subjectProgress,
    required this.completedMaterials,
    required this.completedTryOuts,
    required this.averageScore,
    required this.studyStreak,
    required this.lastStudyDate,
    this.totalStudyHours = 0,
    this.achievements = const [],
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

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedAt,
  });
}

class DiscussionThread {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final SubjectCategory? subject;
  final DateTime createdAt;
  final int likes;
  final int replies;
  final List<DiscussionReply> replyList;

  DiscussionThread({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.subject,
    required this.createdAt,
    this.likes = 0,
    this.replies = 0,
    this.replyList = const [],
  });
}

class DiscussionReply {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final int likes;

  DiscussionReply({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.likes = 0,
  });
}

class LeaderboardEntry {
  final String userId;
  final String userName;
  final String avatar;
  final int totalScore;
  final int tryOutsCompleted;
  final double averageScore;
  final int rank;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.avatar,
    required this.totalScore,
    required this.tryOutsCompleted,
    required this.averageScore,
    required this.rank,
  });
}

// ==================== MOCK DATA ====================

final _mockUser = User(
  id: 'user1',
  name: 'Budi Santoso',
  email: 'budi@example.com',
  avatar: '👨‍🎓',
  role: UserRole.student,
  joinedDate: DateTime(2024, 1, 15),
  studyLevel: StudyLevel.sma12,
  targetUniversities: ['UI', 'ITB', 'UGM'],
  phoneNumber: '081234567890',
);

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
      SubjectCategory.matematikaSaintek,
      SubjectCategory.fisika,
    ],
    totalQuestions: 185,
    isSimulation: true,
    enrolledStudents: ['user1', 'user2'],
    status: TryOutStatus.upcoming,
    questions: List.generate(
      10,
      (i) => TryOutQuestion(
        id: 'q$i',
        subject: SubjectCategory.matematikaSaintek,
        question:
            'Soal matematika nomor ${i + 1}: Jika f(x) = x² + 2x - 3, maka nilai f(2) adalah...',
        options: ['3', '5', '7', '9', '11'],
        correctAnswer: 1,
        explanation: 'f(2) = 2² + 2(2) - 3 = 4 + 4 - 3 = 5',
        points: 4,
      ),
    ),
  ),
  TryOutSession(
    id: 'to2',
    title: 'Try Out SIMAK UI 2025',
    examType: ExamType.simak,
    scheduledDate: DateTime.now().add(const Duration(days: 7)),
    duration: const Duration(minutes: 120),
    subjects: [SubjectCategory.matematikaSaintek, SubjectCategory.fisika],
    totalQuestions: 60,
    enrolledStudents: ['user1'],
    status: TryOutStatus.upcoming,
    questions: [],
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
    description: 'Belajar strategi efektif mengerjakan soal TPS',
  ),
];

final _mockProgress = StudentProgress(
  studentId: 'user1',
  level: StudyLevel.sma12,
  subjectProgress: {
    SubjectCategory.matematikaSaintek: SubjectProgress(
      subject: SubjectCategory.matematikaSaintek,
      completedTopics: 15,
      totalTopics: 20,
      averageScore: 82.5,
      weakTopics: ['Integral', 'Trigonometri'],
      strongTopics: ['Aljabar', 'Fungsi'],
    ),
    SubjectCategory.fisika: SubjectProgress(
      subject: SubjectCategory.fisika,
      completedTopics: 12,
      totalTopics: 18,
      averageScore: 75.3,
      weakTopics: ['Gelombang'],
      strongTopics: ['Mekanika'],
    ),
  },
  completedMaterials: ['mat1', 'mat2'],
  completedTryOuts: [],
  averageScore: 78.9,
  studyStreak: 7,
  lastStudyDate: DateTime.now(),
  totalStudyHours: 45,
  achievements: [
    Achievement(
      id: 'ach1',
      title: 'Streak 7 Hari',
      description: 'Belajar 7 hari berturut-turut',
      icon: '🔥',
      unlockedAt: DateTime.now(),
    ),
  ],
);

final _mockLeaderboard = [
  LeaderboardEntry(
    userId: 'user2',
    userName: 'Ani Wijaya',
    avatar: '👩‍🎓',
    totalScore: 850,
    tryOutsCompleted: 5,
    averageScore: 85.0,
    rank: 1,
  ),
  LeaderboardEntry(
    userId: 'user1',
    userName: 'Budi Santoso',
    avatar: '👨‍🎓',
    totalScore: 789,
    tryOutsCompleted: 4,
    averageScore: 78.9,
    rank: 2,
  ),
  LeaderboardEntry(
    userId: 'user3',
    userName: 'Citra Dewi',
    avatar: '👩‍🎓',
    totalScore: 756,
    tryOutsCompleted: 4,
    averageScore: 75.6,
    rank: 3,
  ),
];

final _mockDiscussions = [
  DiscussionThread(
    id: 'disc1',
    title: 'Cara cepat mengerjakan soal integral?',
    content: 'Ada yang punya tips untuk integral substitusi?',
    authorId: 'user1',
    authorName: 'Budi Santoso',
    subject: SubjectCategory.matematikaSaintek,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    likes: 12,
    replies: 5,
    replyList: [
      DiscussionReply(
        id: 'rep1',
        content: 'Coba pelajari pola substitusi dasar dulu',
        authorId: 'user2',
        authorName: 'Ani Wijaya',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likes: 3,
      ),
    ],
  ),
];

// ==================== PROVIDERS ====================

final authStateProvider = StateProvider<User?>((ref) => _mockUser);

final tryOutsProvider = StateProvider<List<TryOutSession>>(
  (ref) => _mockTryOuts,
);

final activeTryOutProvider = StateProvider<TryOutSession?>((ref) => null);

final tryOutSubmissionProvider = StateProvider<TryOutSubmission?>(
  (ref) => null,
);

final liveClassesProvider = StateProvider<List<LiveClass>>(
  (ref) => _mockLiveClasses,
);

final studentProgressProvider = StateProvider<StudentProgress>(
  (ref) => _mockProgress,
);

final leaderboardProvider = StateProvider<List<LeaderboardEntry>>(
  (ref) => _mockLeaderboard,
);

final discussionsProvider = StateProvider<List<DiscussionThread>>(
  (ref) => _mockDiscussions,
);

final selectedSubjectFilterProvider = StateProvider<SubjectCategory?>(
  (ref) => null,
);

// ==================== MAIN APP ====================

void main() {
  runApp(const ProviderScope(child: BimbelApp()));
}

class BimbelApp extends ConsumerWidget {
  const BimbelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Bimbel Pro - Persiapan SNBT & PTN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const MainScreen(),
    );
  }
}

// ==================== MAIN SCREEN WITH BOTTOM NAV ====================

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final _screens = const [
    BimbelDashboardScreen(),
    TryOutListScreen(),
    StudyMaterialsScreen(),
    LeaderboardScreen(),
    DiscussionForumScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected:
            (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: 'Try Out',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Materi',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard),
            label: 'Peringkat',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Forum',
          ),
        ],
      ),
    );
  }
}

// ==================== DASHBOARD ====================

class BimbelDashboardScreen extends ConsumerWidget {
  const BimbelDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final progress = ref.watch(studentProgressProvider);
    final tryOuts = ref.watch(tryOutsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(context, user!),
              const SizedBox(height: 20),
              _buildStreakCard(context, progress),
              const SizedBox(height: 20),
              _buildProgressOverview(context, progress),
              const SizedBox(height: 20),
              _buildQuickStats(context, progress),
              const SizedBox(height: 20),
              _buildUpcomingTryOuts(context, tryOuts, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, User user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(user.avatar, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat Datang Kembali!',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Target: ${user.targetUniversities.join(", ")}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, StudentProgress progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: const Text('🔥', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Streak Belajar',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  '${progress.studyStreak} hari berturut-turut!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            '${progress.studyStreak}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(
    BuildContext context,
    StudentProgress progress,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress Belajar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${progress.averageScore.toStringAsFixed(1)}%',
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getSubjectName(entry.key),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${entry.value.averageScore.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(entry.value.averageScore),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: entry.value.averageScore / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(
                        _getScoreColor(entry.value.averageScore),
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

  Widget _buildQuickStats(BuildContext context, StudentProgress progress) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            '${progress.totalStudyHours}',
            'Jam Belajar',
            Icons.access_time,
            const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            '${progress.completedTryOuts.length}',
            'Try Out Selesai',
            Icons.quiz,
            const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            '${progress.achievements.length}',
            'Achievement',
            Icons.emoji_events,
            const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTryOuts(
    BuildContext context,
    List<TryOutSession> tryOuts,
    WidgetRef ref,
  ) {
    final upcoming =
        tryOuts
            .where((to) => to.status == TryOutStatus.upcoming)
            .take(2)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Try Out Mendatang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: () {}, child: const Text('Lihat Semua')),
          ],
        ),
        const SizedBox(height: 12),
        ...upcoming.map((to) => TryOutCard(tryOut: to, ref: ref)),
      ],
    );
  }

  String _getSubjectName(SubjectCategory category) {
    const names = {
      SubjectCategory.matematikaSaintek: 'Matematika Saintek',
      SubjectCategory.fisika: 'Fisika',
      SubjectCategory.kimia: 'Kimia',
      SubjectCategory.biologi: 'Biologi',
    };
    return names[category] ?? category.name;
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
