import 'package:flutter/material.dart';

// Enhanced BudgetCategory with date tracking
class BudgetCategory {
  final String name;
  final double budget;
  final double spent;
  final IconData icon;
  final Color color;
  final DateTime startDate;
  final DateTime endDate;
  final BudgetPeriod period;

  BudgetCategory({
    required this.name,
    required this.budget,
    required this.spent,
    required this.icon,
    required this.color,
    required this.startDate,
    required this.endDate,
    required this.period,
  });

  double get remaining => budget - spent;
  double get usagePercentage => budget > 0 ? (spent / budget) * 100 : 0;
  bool get isActive =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);

  Map<String, dynamic> toJson() => {
    'name': name,
    'budget': budget,
    'spent': spent,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'period': period.index,
  };

  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    final categoryConfig = _getCategoryConfig(json['name']);
    return BudgetCategory(
      name: json['name'],
      budget: json['budget'],
      spent: json['spent'],
      icon: categoryConfig['icon'],
      color: categoryConfig['color'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      period: BudgetPeriod.values[json['period']],
    );
  }
  static Map<String, dynamic> _getCategoryConfig(String name) {
    final configs = {
      'Groceries': {'icon': Icons.shopping_basket, 'color': Colors.green},
      'Utilities': {'icon': Icons.electrical_services, 'color': Colors.blue},
      'Entertainment': {'icon': Icons.movie, 'color': Colors.purple},
      'Transportation': {'icon': Icons.directions_car, 'color': Colors.orange},
      'Healthcare': {'icon': Icons.medical_services, 'color': Colors.red},
      'Education': {'icon': Icons.school, 'color': Colors.indigo},
    };
    return configs[name] ?? {'icon': Icons.more_horiz, 'color': Colors.grey};
  }

  BudgetCategory copyWith({
    double? budget,
    double? spent,
    DateTime? startDate,
    DateTime? endDate,
    BudgetPeriod? period,
  }) {
    return BudgetCategory(
      name: name,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      icon: icon,
      color: color,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      period: period ?? this.period,
    );
  }

  // Create new budget period
  BudgetCategory createNextPeriod() {
    DateTime newStartDate;
    DateTime newEndDate;

    switch (period) {
      case BudgetPeriod.monthly:
        newStartDate = DateTime(endDate.year, endDate.month + 1, 1);
        newEndDate = DateTime(newStartDate.year, newStartDate.month + 1, 0);
        break;
      case BudgetPeriod.weekly:
        newStartDate = endDate.add(const Duration(days: 1));
        newEndDate = newStartDate.add(const Duration(days: 6));
        break;
      case BudgetPeriod.yearly:
        newStartDate = DateTime(endDate.year + 1, 1, 1);
        newEndDate = DateTime(newStartDate.year + 1, 1, 0);
        break;
      case BudgetPeriod.custom:
        final duration = endDate.difference(startDate);
        newStartDate = endDate.add(const Duration(days: 1));
        newEndDate = newStartDate.add(duration);
        break;
    }

    return copyWith(spent: 0, startDate: newStartDate, endDate: newEndDate);
  }
}

enum BudgetPeriod { weekly, monthly, yearly, custom }

// Enhanced BudgetNotifier
