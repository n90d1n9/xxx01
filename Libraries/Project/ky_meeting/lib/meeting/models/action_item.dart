import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActionItem {
  final String id;
  final String title;
  final String? assignedTo;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  ActionItem({
    required this.id,
    required this.title,
    this.assignedTo,
    this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'assignedTo': assignedTo,
    'dueDate': dueDate?.toIso8601String(),
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
  };
  factory ActionItem.fromJson(Map<String, dynamic> json) => ActionItem(
    id: json['id'],
    title: json['title'],
    assignedTo: json['assignedTo'],
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    isCompleted: json['isCompleted'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
  );
  ActionItem copyWith({
    String? title,
    String? assignedTo,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return ActionItem(
      id: id,
      title: title ?? this.title,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}
