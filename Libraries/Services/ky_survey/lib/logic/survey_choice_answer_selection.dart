/// Normalizes choice answers against the options currently shown by a question.
class SurveyChoiceAnswerSelection {
  final List<String> optionIds;
  final List<String> selectedIds;

  const SurveyChoiceAnswerSelection._({
    required this.optionIds,
    required this.selectedIds,
  });

  factory SurveyChoiceAnswerSelection.single({
    required Iterable<String> optionIds,
    required dynamic answer,
  }) {
    final knownIds = _uniqueIds(optionIds);
    final answerIds = _answerIds(answer).toSet();
    final selectedId = knownIds.where(answerIds.contains).take(1).toList();

    return SurveyChoiceAnswerSelection._(
      optionIds: knownIds,
      selectedIds: selectedId,
    );
  }

  factory SurveyChoiceAnswerSelection.multiple({
    required Iterable<String> optionIds,
    required dynamic answer,
  }) {
    final knownIds = _uniqueIds(optionIds);
    final answerIds = _answerIds(answer).toSet();

    return SurveyChoiceAnswerSelection._(
      optionIds: knownIds,
      selectedIds: [
        for (final optionId in knownIds)
          if (answerIds.contains(optionId)) optionId,
      ],
    );
  }

  String? get selectedId {
    if (selectedIds.isEmpty) {
      return null;
    }

    return selectedIds.first;
  }

  bool isSelected(String optionId) {
    return selectedIds.contains(optionId);
  }

  List<String> toggle(String optionId, {required bool selected}) {
    if (!optionIds.contains(optionId)) {
      return selectedIds;
    }

    final nextIds = selectedIds.toSet();
    if (selected) {
      nextIds.add(optionId);
    } else {
      nextIds.remove(optionId);
    }

    return [
      for (final knownId in optionIds)
        if (nextIds.contains(knownId)) knownId,
    ];
  }

  static List<String> _answerIds(dynamic answer) {
    if (answer == null) {
      return const [];
    }

    if (answer is String) {
      return answer.isEmpty ? const [] : [answer];
    }

    if (answer is Iterable) {
      return [
        for (final value in answer)
          if (value != null && value.toString().isNotEmpty) value.toString(),
      ];
    }

    final value = answer.toString();
    return value.isEmpty ? const [] : [value];
  }

  static List<String> _uniqueIds(Iterable<String> optionIds) {
    return {
      for (final optionId in optionIds)
        if (optionId.isNotEmpty) optionId,
    }.toList(growable: false);
  }
}
