import 'option.dart';

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
    );
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      type: QuestionType.values.byName(json['type']),
      required: json['required'],
      options:
          json['options'] != null
              ? (json['options'] as List)
                  .map((o) => Option.fromJson(o))
                  .toList()
              : null,
      answer: json['answer'],
      hint: json['hint'],
      maxLength: json['maxLength'],
      minRating: json['minRating'],
      maxRating: json['maxRating'],
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
    };
  }
}
