import 'package:flutter/material.dart';

class Collaborator {
  final String id;
  final String name;
  final String email;
  final Color color;
  final bool isActive;

  Collaborator({
    required this.id,
    required this.name,
    required this.email,
    required this.color,
    this.isActive = true,
  });
}
