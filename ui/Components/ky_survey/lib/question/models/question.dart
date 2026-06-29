import 'question_logic.dart';
import 'question_options.dart';
import 'question_validation.dart';

enum QuestionType {
  multipleChoice,
  shortAnswer,
  scale,
  fileUpload,
  shortText,
  longText,
  singleChoice,
  dropdown,
  rating,
  linearScale,
  matrix,
  ranking,
  date,
  time,
  location,
  email,
  phone,
  number,
  grid,
  signature,
  nps,
  slider,
}


class Question {
  final String id;
  final String text;
  final QuestionType type;
  final bool isRequired;
  final Map<String, dynamic>? conditions;
  final String? description;
  final QuestionValidation? validation;
  final QuestionOptions? options;
  final QuestionLogic? logic;
  final Map<String, dynamic>? metadata;
  final int orderIndex;

  Question({this.conditions, 
    required this.id,
    required this.text,
    this.description,
    required this.type,
    required this.isRequired,
    this.validation,
    this.options,
    this.logic,
    this.metadata,
    required this.orderIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      description: json['description'] as String?,
      type: json['type'] as QuestionType,
      isRequired: json['isRequired'] as bool,
      validation: json['validation'] != null
          ? QuestionValidation.fromJson(json['validation'])
          : null,
      options: json['options'] != null
          ? QuestionOptions.fromJson(json['options'])
          : null,
      logic: json['logic'] != null
          ? QuestionLogic.fromJson(json['logic'])
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      orderIndex: json['orderIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'description': description,
      'type': type,
      'isRequired': isRequired,
      'validation': validation?.toJson(),
      'options': options?.toJson(),
      'logic': logic?.toJson(),
      'metadata': metadata,
      'orderIndex': orderIndex,
    };
  }
}