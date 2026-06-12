/// Resolves rating question bounds, selected value, and visible scale markers.
class SurveyRatingScale {
  final int minRating;
  final int maxRating;
  final int value;

  const SurveyRatingScale._({
    required this.minRating,
    required this.maxRating,
    required this.value,
  });

  factory SurveyRatingScale.resolve({
    int? minRating,
    int? maxRating,
    dynamic answer,
  }) {
    final min = minRating ?? 1;
    final configuredMax = maxRating ?? 5;
    final max = configuredMax > min ? configuredMax : min + 1;
    final parsedValue = parseAnswer(answer) ?? min;

    final value = parsedValue.clamp(min, max).toInt();

    return SurveyRatingScale._(minRating: min, maxRating: max, value: value);
  }

  int get divisions => maxRating - minRating;

  int get ratingCount => divisions + 1;

  String get valueLabel => value.toString();

  List<int> get markerValues {
    return List.generate(ratingCount, (index) => minRating + index);
  }

  static int? parseAnswer(dynamic answer) {
    if (answer is int) {
      return answer;
    }

    if (answer is num) {
      return answer.round();
    }

    if (answer is String) {
      final parsed = num.tryParse(answer.trim());
      return parsed?.round();
    }

    return null;
  }
}
