import '../models/option.dart';
import '../models/question.dart';
import '../models/question_type_details.dart';

class QuestionValidationResult {
  final List<String> errors;

  const QuestionValidationResult(this.errors);

  bool get isValid => errors.isEmpty;

  String? get firstError => errors.isEmpty ? null : errors.first;
}

class QuestionValidator {
  const QuestionValidator._();

  static QuestionValidationResult validateDraft({
    required String text,
    required QuestionType type,
    required List<Option> options,
    required String maxLengthText,
    required String minRatingText,
    required String maxRatingText,
  }) {
    final errors = <String>[];

    if (text.trim().isEmpty) {
      errors.add('Question text cannot be empty');
    }

    if (type.usesOptions) {
      final optionLabels = options
          .map((option) => option.text.trim())
          .where((label) => label.isNotEmpty)
          .toList();

      if (optionLabels.length < 2) {
        errors.add('Add at least 2 filled options for choice questions');
      }

      if (optionLabels.toSet().length != optionLabels.length) {
        errors.add('Option labels must be unique');
      }
    }

    if (type.usesTextSettings && maxLengthText.trim().isNotEmpty) {
      final maxLength = int.tryParse(maxLengthText);
      if (maxLength == null || maxLength <= 0) {
        errors.add('Maximum length must be a positive number');
      }
    }

    if (type.usesRatingSettings) {
      final minRating = int.tryParse(minRatingText) ?? 1;
      final maxRating = int.tryParse(maxRatingText) ?? 5;

      if (minRating >= maxRating) {
        errors.add('Max rating must be greater than min rating');
      }
    }

    return QuestionValidationResult(errors);
  }
}
