import 'question.dart';

extension QuestionTypeDetails on QuestionType {
  String get label {
    switch (this) {
      case QuestionType.singleChoice:
        return 'Single Choice';
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.singleLineText:
        return 'Short Answer';
      case QuestionType.multiLineText:
        return 'Long Answer';
      case QuestionType.number:
        return 'Number';
      case QuestionType.date:
        return 'Date';
      case QuestionType.rating:
        return 'Rating';
    }
  }

  String get builderDescription {
    switch (this) {
      case QuestionType.singleChoice:
        return 'One answer from a controlled list.';
      case QuestionType.multipleChoice:
        return 'Several answers from a controlled list.';
      case QuestionType.singleLineText:
        return 'A short free-text answer.';
      case QuestionType.multiLineText:
        return 'A longer comment or explanation.';
      case QuestionType.number:
        return 'Numeric entry for counts or amounts.';
      case QuestionType.date:
        return 'Calendar date selection.';
      case QuestionType.rating:
        return 'Scaled score with min and max values.';
    }
  }

  bool get usesOptions {
    switch (this) {
      case QuestionType.singleChoice:
      case QuestionType.multipleChoice:
        return true;
      case QuestionType.singleLineText:
      case QuestionType.multiLineText:
      case QuestionType.number:
      case QuestionType.date:
      case QuestionType.rating:
        return false;
    }
  }

  bool get usesTextSettings {
    switch (this) {
      case QuestionType.singleLineText:
      case QuestionType.multiLineText:
        return true;
      case QuestionType.singleChoice:
      case QuestionType.multipleChoice:
      case QuestionType.number:
      case QuestionType.date:
      case QuestionType.rating:
        return false;
    }
  }

  bool get usesRatingSettings => this == QuestionType.rating;
}
