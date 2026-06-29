import '../../question/models/question.dart';
import 'section_logic.dart';

class SurveySection {
  final String id;
  final String title;
  final String? description;
  final List<Question> questions;
  final SectionLogic? logic;
  final bool isOptional;
  final int orderIndex;

  SurveySection({
    required this.id,
    required this.title,
    this.description,
    required this.questions,
    this.logic,
    required this.orderIndex,
    this.isOptional = false,
  });

  factory SurveySection.fromJson(Map<String, dynamic> json) {
    return SurveySection(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      questions: (json['questions'] as List<dynamic>)
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
      logic:
          json['logic'] != null ? SectionLogic.fromJson(json['logic']) : null,
      isOptional: json['isOptional'] as bool,
      orderIndex: json['orderIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'logic': logic?.toJson(),
      'isOptional': isOptional,
      'orderIndex': orderIndex,
    };
  }
}
