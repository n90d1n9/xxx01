import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'university.dart';
import 'major.dart';

class MajorDetailScreen extends StatelessWidget {
  final Major major;
  final University university;
  const MajorDetailScreen({
    super.key,
    required this.major,
    required this.university,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(major.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
                    university.shortName,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    major.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Passing Grade',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPassingGradeChart(),
            const SizedBox(height: 24),
            const Text(
              'Informasi Program Studi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoCard('Deskripsi', major.description),
            _buildInfoCard('Daya Tampung', '${major.capacity} mahasiswa'),
            _buildInfoCard('Peminat', '${major.applicants} pendaftar'),
            _buildInfoCard(
              'Rasio Persaingan',
              '1 : ${major.competitionRatio.toStringAsFixed(1)}',
            ),
            const SizedBox(height: 24),
            const Text(
              'Prospek Karir',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...major.careerProspects.map((career) => _buildCareerItem(career)),
          ],
        ),
      ),
    );
  }

  Widget _buildPassingGradeChart() {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildScoreItem(
                'Terendah',
                major.passingGrade.lowestScore,
                Colors.orange,
              ),
              _buildScoreItem(
                'Rata-rata',
                major.passingGrade.averageScore,
                Colors.blue,
              ),
              _buildScoreItem(
                'Tertinggi',
                major.passingGrade.highestScore,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.purple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Prediksi 2025: ${major.passingGrade.predictedScore.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, double score, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          score.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCareerItem(String career) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.work_outline, color: Color(0xFF6366F1)),
          const SizedBox(width: 12),
          Text(career),
        ],
      ),
    );
  }
}
