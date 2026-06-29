import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'target_choice_card.dart';
import 'personal_target.dart';
import 'subject_category.dart';

class PersonalTargetScreen extends ConsumerWidget {
  const PersonalTargetScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.watch(personalTargetProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Target & Rencana Belajar'),
        actions: [IconButton(icon: const Icon(Icons.edit), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentScoreCard(context, target),
            const SizedBox(height: 20),
            const Text(
              'Pilihan Universitas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...target.choices.map(
              (choice) => TargetChoiceCard(choice: choice, ref: ref),
            ),
            const SizedBox(height: 24),
            const Text(
              'Gap Analysis Per Mata Pelajaran',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...target.subjectGaps.entries.map(
              (entry) => _buildGapCard(context, entry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScoreCard(BuildContext context, PersonalTarget target) {
    return Container(
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
          const Text(
            'Skor Kamu Saat Ini',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            target.currentScore.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                '${target.daysUntilExam} hari menuju ujian',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGapCard(
    BuildContext context,
    MapEntry<SubjectCategory, double> entry,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getSubjectName(entry.key),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '+${entry.value.toStringAsFixed(1)} poin',
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 1 - (entry.value / 100),
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
            ),
          ),
        ],
      ),
    );
  }

  String _getSubjectName(SubjectCategory category) {
    const names = {
      SubjectCategory.matematikaSaintek: 'Matematika Saintek',
      SubjectCategory.fisika: 'Fisika',
      SubjectCategory.kimia: 'Kimia',
    };
    return names[category] ?? category.name;
  }
}
