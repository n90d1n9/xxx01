/// Formats and resolves date-only survey answers for response UI and exports.
class SurveyDateAnswerFormatter {
  const SurveyDateAnswerFormatter();

  String formatAnswer(dynamic answer) {
    final date = parseAnswer(answer);
    if (date == null) {
      return '';
    }

    return formatDate(date);
  }

  String formatDate(DateTime date) {
    final normalized = _dateOnly(date);
    return [
      normalized.year.toString().padLeft(4, '0'),
      normalized.month.toString().padLeft(2, '0'),
      normalized.day.toString().padLeft(2, '0'),
    ].join('-');
  }

  DateTime? parseAnswer(dynamic answer) {
    if (answer is DateTime) {
      return _dateOnly(answer);
    }

    if (answer is String) {
      final trimmed = answer.trim();
      if (trimmed.isEmpty) {
        return null;
      }

      final parsed = DateTime.tryParse(trimmed);
      if (parsed == null) {
        return null;
      }

      return _dateOnly(parsed);
    }

    return null;
  }

  DateTime resolveInitialDate({
    required dynamic answer,
    required DateTime fallbackDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    final parsed = parseAnswer(answer) ?? _dateOnly(fallbackDate);
    return _clampDate(
      parsed,
      firstDate: _dateOnly(firstDate),
      lastDate: _dateOnly(lastDate),
    );
  }

  DateTime _clampDate(
    DateTime date, {
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    if (firstDate.isAfter(lastDate)) {
      return firstDate;
    }

    if (date.isBefore(firstDate)) {
      return firstDate;
    }

    if (date.isAfter(lastDate)) {
      return lastDate;
    }

    return date;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
