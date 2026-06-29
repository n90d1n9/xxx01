import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'university_choice.dart';

class TargetChoiceCard extends StatelessWidget {
  final UniversityChoice choice;
  final WidgetRef ref;
  const TargetChoiceCard({super.key, required this.choice, required this.ref});
  @override
  Widget build(BuildContext context) {
    final universities = ref.watch(universitiesProvider);
    final university = universities.firstWhere(
      (u) => u.id == choice.universityId,
    );
    final major = university.faculties
        .expand((f) => f.majors)
        .firstWhere((m) => m.id == choice.majorId);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              choice.priority == 1
                  ? const Color(0xFF6366F1)
                  : Colors.grey[200]!,
          width: choice.priority == 1 ? 2 : 1,
        ),
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
                  color: _getPriorityColor(choice.priority).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Pilihan ${choice.priority}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getPriorityColor(choice.priority),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getProbabilityColor(
                    choice.admissionProbability,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      size: 14,
                      color: _getProbabilityColor(choice.admissionProbability),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(choice.admissionProbability * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getProbabilityColor(
                          choice.admissionProbability,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            university.shortName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(major.name, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Target Score',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    choice.requiredScore.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Gap',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '+${choice.gapFromCurrent.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFF6366F1);
      case 2:
        return const Color(0xFF10B981);
      case 3:
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }

  Color _getProbabilityColor(double probability) {
    if (probability >= 0.7) return const Color(0xFF10B981);
    if (probability >= 0.4) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
