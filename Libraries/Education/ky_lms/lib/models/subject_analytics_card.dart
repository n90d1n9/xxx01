import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'subject_analytics.dart';
import 'subject_category.dart';

class SubjectAnalyticsCard extends StatelessWidget {
  final SubjectAnalytics analytics;
  const SubjectAnalyticsCard({super.key, required this.analytics});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Text(
                _getSubjectName(analytics.subject),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getTrendColor(analytics.trend).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      analytics.trend > 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 16,
                      color: _getTrendColor(analytics.trend),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${analytics.trend > 0 ? '+' : ''}${analytics.trend.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getTrendColor(analytics.trend),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStat(
                'Rata-rata',
                '${analytics.averageScore.toStringAsFixed(1)}%',
              ),
              const SizedBox(width: 32),
              _buildStat(
                'Akurasi',
                '${(analytics.accuracy * 100).toStringAsFixed(0)}%',
              ),
              const SizedBox(width: 32),
              _buildStat('Soal', '${analytics.questionsAttempted}'),
            ],
          ),
          const SizedBox(height: 16),
          if (analytics.weakTopics.isNotEmpty) ...[
            const Text(
              'Perlu Ditingkatkan:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: analytics.weakTopics.map((topic) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        size: 14,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        topic,
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          if (analytics.strongTopics.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Sudah Dikuasai:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: analytics.strongTopics.map((topic) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        topic,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getTrendColor(double trend) {
    return trend > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444);
  }

  String _getSubjectName(SubjectCategory category) {
    const names = {
      SubjectCategory.matematikaSaintek: 'Matematika Saintek',
      SubjectCategory.fisika: 'Fisika',
    };
    return names[category] ?? category.name;
  }
}
