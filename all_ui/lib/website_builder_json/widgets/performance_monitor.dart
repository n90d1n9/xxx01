import 'package:flutter/material.dart';

import '../models/performance_metrics.dart';
import '../models/schema/website_document.dart';

class PerformanceMonitor extends StatelessWidget {
  final WebsiteDocument website;

  const PerformanceMonitor({super.key, required this.website});

  @override
  Widget build(BuildContext context) {
    final metrics = _analyzePerformance();

    return Dialog(
      child: Container(
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed, size: 28, color: Colors.blue),
                const SizedBox(width: 12),
                const Text(
                  'Performance Report',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Overall score
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getScoreColor(metrics.score).withOpacity(0.1),
                    _getScoreColor(metrics.score).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _getScoreColor(metrics.score),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${metrics.score}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Performance Score',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Based on ${metrics.metrics.length} metrics',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Metrics
            Expanded(
              child: ListView(
                children:
                    metrics.metrics.entries.map((entry) {
                      return _MetricCard(
                        title: entry.key,
                        value: entry.value['value'],
                        score: entry.value['score'],
                        description: entry.value['description'],
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Export report
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Export Report'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Optimize
                    },
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Optimize'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PerformanceMetrics _analyzePerformance() {
    // Simulate performance analysis
    return PerformanceMetrics(
      score: 87,
      metrics: {
        'Page Size': {
          'value': '1.2 MB',
          'score': 85,
          'description': 'Total size of all resources',
        },
        'Load Time': {
          'value': '2.1s',
          'score': 90,
          'description': 'Time to fully load the page',
        },
        'Components': {
          'value': '${_countComponents()}',
          'score': 95,
          'description': 'Number of components on the page',
        },
        'Images': {
          'value': '${_countImages()}',
          'score': 80,
          'description': 'Number of images (some could be optimized)',
        },
        'Scripts': {
          'value': '3',
          'score': 90,
          'description': 'Number of JavaScript files',
        },
      },
    );
  }

  int _countComponents() {
    var count = 0;
    for (final page in website.pages) {
      for (final section in page.sections) {
        count += section.components.length;
      }
    }
    return count;
  }

  int _countImages() {
    var count = 0;
    for (final page in website.pages) {
      for (final section in page.sections) {
        for (final component in section.components) {
          if (component.type == 'image') count++;
        }
      }
    }
    return count;
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final int score;
  final String description;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.score,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        value,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getScoreColor(score).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(score),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}
