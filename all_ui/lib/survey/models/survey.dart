// lib/models/survey.dart
import 'question.dart';

class Survey {
  final String id;
  final String title;
  final String description;
  final List<Question> questions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.createdAt,
    this.updatedAt,
  });

  Survey copyWith({
    String? id,
    String? title,
    String? description,
    List<Question>? questions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Survey(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      questions:
          (json['questions'] as List).map((q) => Question.fromJson(q)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
