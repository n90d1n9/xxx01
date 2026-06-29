import 'package:flutter/material.dart';

class HumanApprovalOption {
  final String id;
  final String label;
  final String? description;
  final IconData? icon;
  final Color? color;

  HumanApprovalOption({
    required this.id,
    required this.label,
    this.description,
    this.icon,
    this.color,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'description': description,
  };

  factory HumanApprovalOption.fromJson(Map<String, dynamic> json) =>
      HumanApprovalOption(
        id: json['id'],
        label: json['label'],
        description: json['description'],
      );
}
