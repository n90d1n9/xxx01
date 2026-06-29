import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/boq_category.dart';
import '../models/project.dart';
import '../states/boq_provider.dart';
import '../utils/format_helper.dart';

class BudgetTab extends ConsumerWidget {
  final Project project;

  const BudgetTab({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBoQ = ref.watch(boqProvider);
    final projectBoQ =
        allBoQ.where((item) => item.projectId == project.id).toList();

    final categoryTotals = <BoQCategory, double>{};
    for (final item in projectBoQ) {
      categoryTotals[item.kategori] =
          (categoryTotals[item.kategori] ?? 0) + item.totalHarga;
    }

    final totalBoQ = categoryTotals.values.fold<double>(
      0,
      (sum, val) => sum + val,
    );
    final variance = project.totalBudget - totalBoQ;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.indigo[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildBudgetRow(
                  'Total Budget Proyek',
                  project.totalBudget,
                  isBold: true,
                ),
                const Divider(height: 24),
                _buildBudgetRow('Total BoQ', totalBoQ),
                const SizedBox(height: 8),
                _buildBudgetRow(
                  'Selisih',
                  variance,
                  color: variance >= 0 ? Colors.green : Colors.red,
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Rincian per Kategori',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...BoQCategory.values.map((category) {
          final total = categoryTotals[category] ?? 0;
          final percentage = totalBoQ > 0 ? (total / totalBoQ * 100) : 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          FormatHelper.getCategoryText(category),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        FormatHelper.currencyFormat.format(total),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    minHeight: 8,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${percentage.toStringAsFixed(1)}% dari total',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBudgetRow(
    String label,
    double amount, {
    Color? color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          FormatHelper.currencyFormat.format(amount),
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 18 : 14,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
