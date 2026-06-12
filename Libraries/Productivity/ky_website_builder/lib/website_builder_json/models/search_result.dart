import 'package:flutter/material.dart';

class SearchResult {
  final String title;
  final String subtitle;
  final String type;
  final IconData icon;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
  });
}
