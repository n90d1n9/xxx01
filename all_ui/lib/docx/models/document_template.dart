import 'package:flutter/material.dart';

class DocumentTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final IconData icon;
  final String content;
  const DocumentTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.content,
  });
}
