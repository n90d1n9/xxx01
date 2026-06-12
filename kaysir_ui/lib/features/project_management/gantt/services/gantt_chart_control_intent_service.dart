/// Result for focusing the timeline search from the full-screen chart.
class GanttChartSearchFocusIntentResult {
  const GanttChartSearchFocusIntentResult({
    required this.shouldExpandControls,
    required this.shouldSelectSearchText,
  });

  final bool shouldExpandControls;
  final bool shouldSelectSearchText;
}

/// Applies chart control intents through caller-owned UI callbacks.
class GanttChartControlIntentDispatcher {
  const GanttChartControlIntentDispatcher();

  void dispatchSearchFocus({
    required GanttChartSearchFocusIntentResult intent,
    required void Function() onExpandControls,
    required void Function({required bool selectText}) onScheduleSearchFocus,
  }) {
    if (intent.shouldExpandControls) {
      onExpandControls();
    }

    onScheduleSearchFocus(selectText: intent.shouldSelectSearchText);
  }
}

/// Centralizes keyboard and header control intent rules for the Gantt chart.
class GanttChartControlIntentService {
  const GanttChartControlIntentService();

  bool nextControlsExpanded({required bool controlsExpanded}) {
    return !controlsExpanded;
  }

  GanttChartSearchFocusIntentResult focusSearch({
    required bool controlsExpanded,
  }) {
    return GanttChartSearchFocusIntentResult(
      shouldExpandControls: !controlsExpanded,
      shouldSelectSearchText: true,
    );
  }
}
