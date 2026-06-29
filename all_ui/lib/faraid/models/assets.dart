import 'dart:math';

class Asset {
  final String id;
  final String name;
  final String description;
  final double value;
  final String category;
  final DateTime? acquisitionDate;
  final bool isLiquid;
  final double appreciationRate; // Annual appreciation rate

  Asset({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.category,
    this.acquisitionDate,
    this.isLiquid = true,
    this.appreciationRate = 0.0,
  });

  // Calculate current value with appreciation
  double get currentValue {
    if (acquisitionDate == null || appreciationRate == 0.0) return value;

    final now = DateTime.now();
    final years = now.difference(acquisitionDate!).inDays / 365.25;
    return value * pow(1 + appreciationRate, years);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'value': value,
    'category': category,
    'acquisitionDate': acquisitionDate?.toIso8601String(),
    'isLiquid': isLiquid,
    'appreciationRate': appreciationRate,
  };

  factory Asset.fromJson(Map<String, dynamic> json) => Asset(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    value: json['value'],
    category: json['category'],
    acquisitionDate:
        json['acquisitionDate'] != null
            ? DateTime.parse(json['acquisitionDate'])
            : null,
    isLiquid: json['isLiquid'] ?? true,
    appreciationRate: json['appreciationRate'] ?? 0.0,
  );

  Asset copyWith({
    String? id,
    String? name,
    String? description,
    double? value,
    String? category,
    DateTime? acquisitionDate,
    bool? isLiquid,
    double? appreciationRate,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      value: value ?? this.value,
      category: category ?? this.category,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      isLiquid: isLiquid ?? this.isLiquid,
      appreciationRate: appreciationRate ?? this.appreciationRate,
    );
  }
}
