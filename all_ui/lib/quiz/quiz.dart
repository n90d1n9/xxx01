import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// Quiz Models
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final String? imageUrl;
  final QuestionType type;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.imageUrl,
    this.type = QuestionType.multipleChoice,
  });
}

enum QuestionType { multipleChoice, trueFalse, fillInBlank }

class QuizSession {
  final String id;
  final String title;
  final List<QuizQuestion> questions;
  int currentQuestionIndex;
  int score;
  final Map<String, String> userAnswers;
  final bool isTimeLimited;
  final int? timePerQuestionInSeconds;

  QuizSession({
    required this.id,
    required this.title,
    required this.questions,
    this.currentQuestionIndex = 0,
    this.score = 0,
    Map<String, String>? userAnswers,
    this.isTimeLimited = false,
    this.timePerQuestionInSeconds,
  }) : userAnswers = userAnswers ?? {};

  QuizSession copyWith({
    String? id,
    String? title,
    List<QuizQuestion>? questions,
    int? currentQuestionIndex,
    int? score,
    Map<String, String>? userAnswers,
    bool? isTimeLimited,
    int? timePerQuestionInSeconds,
  }) {
    return QuizSession(
      id: id ?? this.id,
      title: title ?? this.title,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      userAnswers: userAnswers ?? this.userAnswers,
      isTimeLimited: isTimeLimited ?? this.isTimeLimited,
      timePerQuestionInSeconds:
          timePerQuestionInSeconds ?? this.timePerQuestionInSeconds,
    );
  }

  bool get isCompleted => currentQuestionIndex >= questions.length;
  QuizQuestion get currentQuestion => questions[currentQuestionIndex];
  int get totalQuestions => questions.length;
  double get progressPercentage =>
      totalQuestions > 0 ? (currentQuestionIndex + 1) / totalQuestions : 0;
}

// Providers
final quizSessionProvider = StateNotifierProvider<
  QuizSessionNotifier,
  QuizSession
>((ref) {
  // Sample quiz for demonstration
  final sampleQuiz = QuizSession(
    id: 'quiz-1',
    title: 'General Knowledge Quiz',
    questions: [
      QuizQuestion(
        id: 'q1',
        question: 'What is the capital of France?',
        options: ['London', 'Berlin', 'Paris', 'Madrid'],
        correctAnswer: 'Paris',
        explanation: 'Paris is the capital and most populous city of France.',
      ),
      QuizQuestion(
        id: 'q2',
        question: 'Is the Earth flat?',
        options: ['True', 'False'],
        correctAnswer: 'False',
        type: QuestionType.trueFalse,
        explanation: 'The Earth is approximately spherical in shape.',
      ),
      QuizQuestion(
        id: 'q3',
        question: 'Which planet is known as the Red Planet?',
        options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
        correctAnswer: 'Mars',
        imageUrl: 'assets/mars.jpg',
      ),
      QuizQuestion(
        id: 'q4',
        question:
            'Complete the sentence: Water boils at ___ degrees Celsius at sea level.',
        options: ['50', '100', '150', '200'],
        correctAnswer: '100',
        type: QuestionType.fillInBlank,
      ),
    ],
    isTimeLimited: true,
    timePerQuestionInSeconds: 15,
  );

  return QuizSessionNotifier(sampleQuiz);
});

final timerProvider = StateNotifierProvider<TimerNotifier, int>((ref) {
  final quizSession = ref.watch(quizSessionProvider);
  return TimerNotifier(quizSession.timePerQuestionInSeconds ?? 0);
});

// Notifiers
class QuizSessionNotifier extends StateNotifier<QuizSession> {
  QuizSessionNotifier(QuizSession initialState) : super(initialState);

  void answerQuestion(String answer) {
    final question = state.currentQuestion;
    final isCorrect = question.correctAnswer == answer;

    final newUserAnswers = Map<String, String>.from(state.userAnswers);
    newUserAnswers[question.id] = answer;

    state = state.copyWith(
      userAnswers: newUserAnswers,
      score: isCorrect ? state.score + 1 : state.score,
    );
  }

  void nextQuestion() {
    if (!state.isCompleted) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }

  void restartQuiz() {
    state = state.copyWith(currentQuestionIndex: 0, score: 0, userAnswers: {});
  }

  void loadNewQuiz(QuizSession newQuiz) {
    state = newQuiz;
  }
}

class TimerNotifier extends StateNotifier<int> {
  Timer? _timer;

  TimerNotifier(int seconds) : super(seconds) {
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();

    if (state > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state > 0) {
          state--;
        } else {
          _timer?.cancel();
        }
      });
    }
  }

  void resetTimer(int seconds) {
    _timer?.cancel();
    state = seconds;
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// UI Components
class QuizScreen extends ConsumerWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizSession = ref.watch(quizSessionProvider);

    return Scaffold(
      body: SafeArea(
        child: quizSession.isCompleted ? QuizResultsView() : QuizQuestionView(),
      ),
    );
  }
}

class QuizQuestionView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizSession = ref.watch(quizSessionProvider);
    final currentQuestion = quizSession.currentQuestion;
    final timeRemaining = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);
    final quizNotifier = ref.read(quizSessionProvider.notifier);

    ref.listen<QuizSession>(quizSessionProvider, (previous, next) {
      if (previous?.currentQuestionIndex != next.currentQuestionIndex &&
          next.isTimeLimited) {
        timerNotifier.resetTimer(next.timePerQuestionInSeconds ?? 30);
      }
    });

    ref.listen<int>(timerProvider, (previous, next) {
      if (next == 0 && quizSession.isTimeLimited) {
        // Auto-advance if time runs out
        quizNotifier.nextQuestion();
      }
    });

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Quiz Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                quizSession.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (quizSession.isTimeLimited)
                TimerWidget(timeRemaining: timeRemaining),
            ],
          ),

          // Progress Bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            height: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: quizSession.progressPercentage,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ),

          // Question Counter
          Text(
            'Question ${quizSession.currentQuestionIndex + 1}/${quizSession.totalQuestions}',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Question Card
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question image if available
                    if (currentQuestion.imageUrl != null)
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[200],
                          ),
                          width: double.infinity,
                          child: Center(
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Question text
                    Text(
                      currentQuestion.question,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Answer options
                    Expanded(
                      flex: 5,
                      child: _buildAnswerOptions(
                        context,
                        currentQuestion,
                        quizSession,
                        quizNotifier,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Navigation buttons
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
              onPressed: () => quizNotifier.nextQuestion(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Next Question'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(
    BuildContext context,
    QuizQuestion question,
    QuizSession session,
    QuizSessionNotifier notifier,
  ) {
    final userAnswerForQuestion = session.userAnswers[question.id];

    switch (question.type) {
      case QuestionType.trueFalse:
        return Row(
          children: [
            Expanded(
              child: _answerButton(
                context,
                'True',
                userAnswerForQuestion == 'True',
                () => notifier.answerQuestion('True'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _answerButton(
                context,
                'False',
                userAnswerForQuestion == 'False',
                () => notifier.answerQuestion('False'),
              ),
            ),
          ],
        );

      case QuestionType.fillInBlank:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Type your answer here',
              ),
              onSubmitted: (value) => notifier.answerQuestion(value),
            ),
          ],
        );

      case QuestionType.multipleChoice:
      default:
        return ListView.builder(
          itemCount: question.options.length,
          itemBuilder: (context, index) {
            final option = question.options[index];
            final isSelected = userAnswerForQuestion == option;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _answerButton(
                context,
                option,
                isSelected,
                () => notifier.answerQuestion(option),
              ),
            );
          },
        );
    }
  }

  Widget _answerButton(
    BuildContext context,
    String text,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: isSelected ? 4 : 1,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class TimerWidget extends StatelessWidget {
  final int timeRemaining;

  const TimerWidget({Key? key, required this.timeRemaining}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLowTime = timeRemaining <= 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isLowTime ? Colors.red.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isLowTime ? Colors.red.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer,
            size: 18,
            color: isLowTime ? Colors.red : Colors.grey.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            timeRemaining.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isLowTime ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class QuizResultsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizSession = ref.watch(quizSessionProvider);
    final quizNotifier = ref.read(quizSessionProvider.notifier);

    final int totalCorrect = quizSession.score;
    final int totalQuestions = quizSession.totalQuestions;
    final double percentage = (totalCorrect / totalQuestions) * 100;

    String resultMessage;
    Color resultColor;

    if (percentage >= 80) {
      resultMessage = 'Excellent!';
      resultColor = Colors.green;
    } else if (percentage >= 60) {
      resultMessage = 'Good job!';
      resultColor = Colors.blue;
    } else if (percentage >= 40) {
      resultMessage = 'Keep practicing!';
      resultColor = Colors.orange;
    } else {
      resultMessage = 'Try again!';
      resultColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Quiz Results',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Score Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Score Circle
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[100],
                      border: Border.all(color: resultColor, width: 8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$totalCorrect/$totalQuestions',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Result Message
                  Text(
                    resultMessage,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: resultColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Time taken (if applicable)
                  if (quizSession.isTimeLimited)
                    Text(
                      'Time taken: ${_formatTime(quizSession)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Answer Review Section
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Answer Review',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        itemCount: quizSession.questions.length,
                        separatorBuilder: (_, __) => Divider(),
                        itemBuilder: (context, index) {
                          final question = quizSession.questions[index];
                          final userAnswer =
                              quizSession.userAnswers[question.id] ??
                              'No answer';
                          final isCorrect =
                              userAnswer == question.correctAnswer;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  isCorrect ? Colors.green[50] : Colors.red[50],
                              child: Icon(
                                isCorrect ? Icons.check : Icons.close,
                                color: isCorrect ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(
                              question.question,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your answer: $userAnswer',
                                  style: TextStyle(
                                    color:
                                        isCorrect ? Colors.green : Colors.red,
                                  ),
                                ),
                                if (!isCorrect)
                                  Text(
                                    'Correct answer: ${question.correctAnswer}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                if (question.explanation != null)
                                  Text(
                                    question.explanation!,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            isThreeLine: true,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => quizNotifier.restartQuiz(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Try Again'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to quiz selection screen (not implemented)
                      // Navigator.of(context).pushReplacement(...);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('New Quiz'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(QuizSession session) {
    // Simple time calculation example
    final int totalSeconds =
        (session.timePerQuestionInSeconds ?? 0) * session.totalQuestions;
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// Main App
class QuizApp extends StatelessWidget {
  const QuizApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Modern Quiz App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          fontFamily: 'Poppins',
          cardTheme: CardThemeData(
            color: Colors.white,
            surfaceTintColor: Colors.white,
          ),
        ),
        home: const QuizScreen(),
      ),
    );
  }
}

// Dashboard for Quiz Selection (extra feature)
class QuizDashboard extends ConsumerWidget {
  const QuizDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizNotifier = ref.read(quizSessionProvider.notifier);

    // Sample quiz categories
    final quizCategories = [
      {
        'name': 'General Knowledge',
        'color': Colors.blue,
        'icon': Icons.lightbulb_outline,
      },
      {
        'name': 'Science',
        'color': Colors.green,
        'icon': Icons.science_outlined,
      },
      {'name': 'History', 'color': Colors.amber, 'icon': Icons.history_edu},
      {
        'name': 'Mathematics',
        'color': Colors.red,
        'icon': Icons.calculate_outlined,
      },
      {'name': 'Geography', 'color': Colors.purple, 'icon': Icons.public},
      {'name': 'Sports', 'color': Colors.orange, 'icon': Icons.sports_soccer},
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, Quizzer!',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Let\'s test your knowledge',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(context, '12', 'Quizzes Taken'),
                      _buildStatItem(context, '84%', 'Average Score'),
                      _buildStatItem(context, '8', 'Perfect Scores'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quiz Categories
              Text(
                'Quiz Categories',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: quizCategories.length,
                  itemBuilder: (context, index) {
                    final category = quizCategories[index];
                    return _buildCategoryCard(
                      context,
                      category['name'] as String,
                      category['color'] as Color,
                      category['icon'] as IconData,
                      () {
                        // Load quiz for selected category (sample function)
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const QuizScreen()),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String name,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(
                name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '10 Quizzes',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const QuizApp());
}
