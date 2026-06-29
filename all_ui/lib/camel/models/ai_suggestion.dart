// AI Suggestions (Enhanced)
import 'package:flutter/material.dart';

class AISuggestion {
  final String id;
  final String title;
  final String description;
  final String
  category; // 'performance', 'reliability', 'security', 'best-practice'
  final VoidCallback action;
  final IconData icon;
  final int priority; // 1-5, 5 being highest

  AISuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.action,
    required this.icon,
    this.priority = 3,
  });
}
