enum KyGanttViewMode { day, week, month, quarter }

extension KyGanttViewModeMetrics on KyGanttViewMode {
  double get defaultDayWidth {
    switch (this) {
      case KyGanttViewMode.day:
        return 72;
      case KyGanttViewMode.week:
        return 42;
      case KyGanttViewMode.month:
        return 26;
      case KyGanttViewMode.quarter:
        return 18;
    }
  }

  int get labelIntervalDays {
    switch (this) {
      case KyGanttViewMode.day:
        return 1;
      case KyGanttViewMode.week:
        return 7;
      case KyGanttViewMode.month:
        return 14;
      case KyGanttViewMode.quarter:
        return 30;
    }
  }
}
