import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/user_profile_provider.dart';

class QuizDialog extends ConsumerStatefulWidget {
  const QuizDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends ConsumerState<QuizDialog> {
  int currentQuestion = 0;
  int score = 0;
  bool answered = false;
  int? selectedAnswer;

  final questions = [
    {
      'question': 'When did humans first land on the Moon?',
      'answers': ['1965', '1969', '1972', '1975'],
      'correct': 1,
    },
    {
      'question': 'What year did World War II begin?',
      'answers': ['1935', '1937', '1939', '1941'],
      'correct': 2,
    },
    {
      'question': 'Who painted the Mona Lisa?',
      'answers': ['Michelangelo', 'Raphael', 'Leonardo da Vinci', 'Donatello'],
      'correct': 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];
    final isLastQuestion = currentQuestion == questions.length - 1;

    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'History Quiz',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Question ${currentQuestion + 1}/${questions.length}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              question['question'] as String,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ...(question['answers'] as List<String>).asMap().entries.map((
              entry,
            ) {
              final index = entry.key;
              final answer = entry.value;
              final isCorrect = index == question['correct'];
              final isSelected = selectedAnswer == index;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap:
                      answered
                          ? null
                          : () {
                            setState(() {
                              selectedAnswer = index;
                              answered = true;
                              if (isCorrect) score++;
                            });
                          },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          answered
                              ? (isCorrect
                                  ? Colors.green.withOpacity(0.2)
                                  : (isSelected
                                      ? Colors.red.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.05)))
                              : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            answered
                                ? (isCorrect
                                    ? Colors.green
                                    : (isSelected
                                        ? Colors.red
                                        : Colors.white24))
                                : Colors.white24,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            answer,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (answered && (isCorrect || isSelected))
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            if (answered) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLastQuestion) {
                      ref
                          .read(userProfileProvider.notifier)
                          .addPoints(score * 20);
                      if (score == questions.length) {
                        ref
                            .read(userProfileProvider.notifier)
                            .unlockAchievement('quiz_master');
                      }
                      _showResults();
                    } else {
                      setState(() {
                        currentQuestion++;
                        answered = false;
                        selectedAnswer = null;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isLastQuestion ? 'See Results' : 'Next Question',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showResults() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
                  const SizedBox(height: 16),
                  const Text(
                    'Quiz Complete!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Score: $score/${questions.length}',
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Earned ${score * 20} points!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Close',
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
          ),
    );
  }
}
