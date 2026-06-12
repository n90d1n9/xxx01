import 'package:flutter/material.dart';

class ReportType {
  final String name;
  final String description;
  final IconData icon;

  const ReportType({
    required this.name,
    required this.description,
    required this.icon,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReportType &&
            other.name == name &&
            other.description == description &&
            other.icon == icon;
  }

  @override
  int get hashCode => Object.hash(name, description, icon);
}
