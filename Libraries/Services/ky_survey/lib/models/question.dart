import 'option.dart';
import 'question_visibility_rule.dart';

// lib/models/question.dart
enum QuestionType {
  singleChoice,
  multipleChoice,
  singleLineText,
  multiLineText,
  number,
  date,
  rating,
}

class Question {
  final String id;
  final String text;
  final QuestionType type;
  final bool required;
  final List<Option>? options;
  final dynamic answer;
  final String? hint;
  final int? maxLength;
  final int? minRating;
  final int? maxRating;
  final String? sectionId;
  final List<QuestionVisibilityRule> visibilityRules;

  Question({
    required this.id,
    required this.text,
    required this.type,
    required this.required,
    this.options,
    this.answer,
    this.hint,
    this.maxLength,
    this.minRating,
    this.maxRating,
    this.sectionId,
    this.visibilityRules = const [],
  });

  Question copyWith({
    String? id,
    String? text,
    QuestionType? type,
    bool? required,
    List<Option>? options,
    dynamic answer,
    String? hint,
    int? maxLength,
    int? minRating,
    int? maxRating,
    String? sectionId,
    bool clearSectionId = false,
    List<QuestionVisibilityRule>? visibilityRules,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      required: required ?? this.required,
      options: options ?? this.options,
      answer: answer ?? this.answer,
      hint: hint ?? this.hint,
      maxLength: maxLength ?? this.maxLength,
      minRating: minRating ?? this.minRating,
      maxRating: maxRating ?? this.maxRating,
      sectionId: clearSectionId ? null : sectionId ?? this.sectionId,
      visibilityRules: visibilityRules ?? this.visibilityRules,
    );
  }

  Question withAnswer(dynamic answer) {
    return Question(
      id: id,
      text: text,
      type: type,
      required: required,
      options: options,
      answer: answer,
      hint: hint,
      maxLength: maxLength,
      minRating: minRating,
      maxRating: maxRating,
      sectionId: sectionId,
      visibilityRules: visibilityRules,
    );
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      type: QuestionType.values.byName(json['type']),
      required: json['required'],
      options: json['options'] != null
          ? (json['options'] as List).map((o) => Option.fromJson(o)).toList()
          : null,
      answer: json['answer'],
      hint: json['hint'],
      maxLength: json['maxLength'],
      minRating: json['minRating'],
      maxRating: json['maxRating'],
      sectionId: json['sectionId'] as String?,
      visibilityRules: (json['visibilityRules'] as List? ?? const [])
          .map(
            (rule) => QuestionVisibilityRule.fromJson(
              Map<String, dynamic>.from(rule as Map),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.name,
      'required': required,
      'options': options?.map((o) => o.toJson()).toList(),
      'answer': answer,
      'hint': hint,
      'maxLength': maxLength,
      'minRating': minRating,
      'maxRating': maxRating,
      'sectionId': sectionId,
      'visibilityRules': visibilityRules.map((rule) => rule.toJson()).toList(),
    };
  }
}
