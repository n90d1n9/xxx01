import 'package:flutter/material.dart';

class ResponseVisualization extends StatelessWidget {
  final List<SurveyResponse> responses;
  final String questionId;

  const ResponseVisualization({
    super.key,
    required this.responses,
    required this.questionId,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate statistics for the question
    final answers = responses
        .map((r) => r.answers[questionId])
        .where((a) => a != null)
        .toList();

    if (answers.isEmpty) {
      return const Center(child: Text('No responses yet'));
    }

    // For multiple choice questions, show pie chart
    if (answers.first is String) {
      final Map<String, int> frequency = {};
      for (var answer in answers) {
        frequency[answer] = (frequency[answer] ?? 0) + 1;
      }

      return SizedBox(
        height: 300,
        child: PieChart(
          PieChartData(
            sections: frequency.entries.map((entry) {
              return PieChartSectionData(
                value: entry.value.toDouble(),
                title: '${entry.key}\n${entry.value}',
                color: Colors.primaries[
                    frequency.keys.toList().indexOf(entry.key) %
                        Colors.primaries.length],
              );
            }).toList(),
          ),
        ),
      );
    }

    // For scale questions, show bar chart
    if (answers.first is num) {
      final List<num> numericAnswers = answers.cast<num>();
      final Map<num, int> frequency = {};
      for (var answer in numericAnswers) {
        frequency[answer] = (frequency[answer] ?? 0) + 1;
      }

      return SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: frequency.values.reduce((a, b) => a > b ? a : b).toDouble(),
            barGroups: frequency.entries.map((entry) {
              return BarChartGroupData(
                x: entry.key.toInt(),
                barRods: [
                  BarChartRodData(
                    toY: entry.value.toDouble(),
                    color: Colors.blue,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      );
    }

    return const Center(child: Text('Unsupported question type for visualization'));
  }
}
