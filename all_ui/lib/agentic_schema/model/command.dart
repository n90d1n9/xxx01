import 'package:flutter/material.dart';

class Command {
  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<String> keywords;
  final VoidCallback action;
  final String? shortcut;

  Command({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.keywords,
    required this.action,
    this.shortcut,
  });

  bool matches(String query) {
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        (subtitle?.toLowerCase().contains(q) ?? false) ||
        keywords.any((k) => k.toLowerCase().contains(q));
  }
}
