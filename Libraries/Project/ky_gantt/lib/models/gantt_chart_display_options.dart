import 'package:flutter/material.dart';

import 'gantt_task.dart';

typedef KyGanttTaskAvatarsBuilder = List<KyGanttTaskAvatar> Function(
    GanttTask task);

enum KyGanttDependencyLineFocusScope { direct, upstream, downstream, chain }

class KyGanttChartDisplayOptions {
  const KyGanttChartDisplayOptions({
    this.showTaskBarShadows = true,
    this.showSelectedTaskFocus = true,
    this.showSelectedTaskRowHighlight = true,
    this.showTaskBarDateLabels = false,
    this.showTaskBarDurationLabels = false,
    this.showTaskBarDependencyBadges = false,
    this.showTaskBarDependencyConflictBadges = false,
    this.showTaskBarProgressLabels = false,
    this.showTaskBarStatusLabels = false,
    this.showMilestoneLabels = false,
    this.showMilestoneDateLabels = false,
    this.showTaskBarAvatars = false,
    this.maxTaskBarAvatars = 3,
    this.taskBarAvatar = const KyGanttTaskBarAvatarOptions(),
    this.showTodayMarker = true,
    this.showWeekendBands = true,
    this.weekendBandColor,
    this.weekendBandOpacity = 0.5,
    this.todayIndicatorOpacity = 0.14,
    this.todayMarkerOpacity = 1,
    this.selectedTaskRowHighlightColor,
    this.selectedTaskRowHighlightOpacity = 0.08,
    this.taskBarShadow = const KyGanttTaskBarShadowOptions(),
    this.taskBarScheduleBadge = const KyGanttTaskBarScheduleBadgeOptions(),
    this.taskBarTooltip = const KyGanttTaskBarTooltipOptions(),
    this.dependencyLines = const KyGanttDependencyLineOptions(),
  });

  final bool showTaskBarShadows;
  final bool showSelectedTaskFocus;
  final bool showSelectedTaskRowHighlight;
  final bool showTaskBarDateLabels;
  final bool showTaskBarDurationLabels;
  final bool showTaskBarDependencyBadges;
  final bool showTaskBarDependencyConflictBadges;
  final bool showTaskBarProgressLabels;
  final bool showTaskBarStatusLabels;
  final bool showMilestoneLabels;
  final bool showMilestoneDateLabels;
  final bool showTaskBarAvatars;
  final int maxTaskBarAvatars;
  final KyGanttTaskBarAvatarOptions taskBarAvatar;
  final bool showTodayMarker;
  final bool showWeekendBands;
  final Color? weekendBandColor;
  final double weekendBandOpacity;
  final double todayIndicatorOpacity;
  final double todayMarkerOpacity;
  final Color? selectedTaskRowHighlightColor;
  final double selectedTaskRowHighlightOpacity;
  final KyGanttTaskBarShadowOptions taskBarShadow;
  final KyGanttTaskBarScheduleBadgeOptions taskBarScheduleBadge;
  final KyGanttTaskBarTooltipOptions taskBarTooltip;
  final KyGanttDependencyLineOptions dependencyLines;

  KyGanttChartDisplayOptions copyWith({
    bool? showTaskBarShadows,
    bool? showSelectedTaskFocus,
    bool? showSelectedTaskRowHighlight,
    bool? showTaskBarDateLabels,
    bool? showTaskBarDurationLabels,
    bool? showTaskBarDependencyBadges,
    bool? showTaskBarDependencyConflictBadges,
    bool? showTaskBarProgressLabels,
    bool? showTaskBarStatusLabels,
    bool? showMilestoneLabels,
    bool? showMilestoneDateLabels,
    bool? showTaskBarAvatars,
    int? maxTaskBarAvatars,
    KyGanttTaskBarAvatarOptions? taskBarAvatar,
    bool? showTodayMarker,
    bool? showWeekendBands,
    Color? weekendBandColor,
    double? weekendBandOpacity,
    double? todayIndicatorOpacity,
    double? todayMarkerOpacity,
    Color? selectedTaskRowHighlightColor,
    double? selectedTaskRowHighlightOpacity,
    KyGanttTaskBarShadowOptions? taskBarShadow,
    KyGanttTaskBarScheduleBadgeOptions? taskBarScheduleBadge,
    KyGanttTaskBarTooltipOptions? taskBarTooltip,
    KyGanttDependencyLineOptions? dependencyLines,
  }) {
    return KyGanttChartDisplayOptions(
      showTaskBarShadows: showTaskBarShadows ?? this.showTaskBarShadows,
      showSelectedTaskFocus:
          showSelectedTaskFocus ?? this.showSelectedTaskFocus,
      showSelectedTaskRowHighlight:
          showSelectedTaskRowHighlight ?? this.showSelectedTaskRowHighlight,
      showTaskBarDateLabels:
          showTaskBarDateLabels ?? this.showTaskBarDateLabels,
      showTaskBarDurationLabels:
          showTaskBarDurationLabels ?? this.showTaskBarDurationLabels,
      showTaskBarDependencyBadges:
          showTaskBarDependencyBadges ?? this.showTaskBarDependencyBadges,
      showTaskBarDependencyConflictBadges:
          showTaskBarDependencyConflictBadges ??
              this.showTaskBarDependencyConflictBadges,
      showTaskBarProgressLabels:
          showTaskBarProgressLabels ?? this.showTaskBarProgressLabels,
      showTaskBarStatusLabels:
          showTaskBarStatusLabels ?? this.showTaskBarStatusLabels,
      showMilestoneLabels: showMilestoneLabels ?? this.showMilestoneLabels,
      showMilestoneDateLabels:
          showMilestoneDateLabels ?? this.showMilestoneDateLabels,
      showTaskBarAvatars: showTaskBarAvatars ?? this.showTaskBarAvatars,
      maxTaskBarAvatars: maxTaskBarAvatars ?? this.maxTaskBarAvatars,
      taskBarAvatar: taskBarAvatar ?? this.taskBarAvatar,
      showTodayMarker: showTodayMarker ?? this.showTodayMarker,
      showWeekendBands: showWeekendBands ?? this.showWeekendBands,
      weekendBandColor: weekendBandColor ?? this.weekendBandColor,
      weekendBandOpacity: weekendBandOpacity ?? this.weekendBandOpacity,
      todayIndicatorOpacity:
          todayIndicatorOpacity ?? this.todayIndicatorOpacity,
      todayMarkerOpacity: todayMarkerOpacity ?? this.todayMarkerOpacity,
      selectedTaskRowHighlightColor:
          selectedTaskRowHighlightColor ?? this.selectedTaskRowHighlightColor,
      selectedTaskRowHighlightOpacity: selectedTaskRowHighlightOpacity ??
          this.selectedTaskRowHighlightOpacity,
      taskBarShadow: taskBarShadow ?? this.taskBarShadow,
      taskBarScheduleBadge: taskBarScheduleBadge ?? this.taskBarScheduleBadge,
      taskBarTooltip: taskBarTooltip ?? this.taskBarTooltip,
      dependencyLines: dependencyLines ?? this.dependencyLines,
    );
  }
}

class KyGanttTaskBarAvatarOptions {
  const KyGanttTaskBarAvatarOptions({
    this.size = 22,
    this.overlap = 8,
    this.minTaskBarWidth = 112,
  });

  final double size;
  final double overlap;
  final double minTaskBarWidth;

  double get normalizedSize => size.clamp(16, 32).toDouble();
  double get normalizedOverlap => overlap.clamp(0, 18).toDouble();
  double get normalizedMinTaskBarWidth =>
      minTaskBarWidth.clamp(72, 220).toDouble();

  KyGanttTaskBarAvatarOptions copyWith({
    double? size,
    double? overlap,
    double? minTaskBarWidth,
  }) {
    return KyGanttTaskBarAvatarOptions(
      size: size ?? this.size,
      overlap: overlap ?? this.overlap,
      minTaskBarWidth: minTaskBarWidth ?? this.minTaskBarWidth,
    );
  }
}

class KyGanttTaskBarShadowOptions {
  const KyGanttTaskBarShadowOptions({
    this.opacityScale = 1,
    this.blurScale = 1,
    this.offsetScale = 1,
  });

  final double opacityScale;
  final double blurScale;
  final double offsetScale;

  KyGanttTaskBarShadowOptions copyWith({
    double? opacityScale,
    double? blurScale,
    double? offsetScale,
  }) {
    return KyGanttTaskBarShadowOptions(
      opacityScale: opacityScale ?? this.opacityScale,
      blurScale: blurScale ?? this.blurScale,
      offsetScale: offsetScale ?? this.offsetScale,
    );
  }
}

class KyGanttTaskBarScheduleBadgeOptions {
  const KyGanttTaskBarScheduleBadgeOptions({
    this.visible = false,
    this.showAccent = true,
    this.showLabel = true,
    this.plannedColor,
    this.inProgressColor,
    this.dueTodayColor,
    this.overdueColor,
    this.completeColor,
  });

  final bool visible;
  final bool showAccent;
  final bool showLabel;
  final Color? plannedColor;
  final Color? inProgressColor;
  final Color? dueTodayColor;
  final Color? overdueColor;
  final Color? completeColor;

  KyGanttTaskBarScheduleBadgeOptions copyWith({
    bool? visible,
    bool? showAccent,
    bool? showLabel,
    Color? plannedColor,
    Color? inProgressColor,
    Color? dueTodayColor,
    Color? overdueColor,
    Color? completeColor,
  }) {
    return KyGanttTaskBarScheduleBadgeOptions(
      visible: visible ?? this.visible,
      showAccent: showAccent ?? this.showAccent,
      showLabel: showLabel ?? this.showLabel,
      plannedColor: plannedColor ?? this.plannedColor,
      inProgressColor: inProgressColor ?? this.inProgressColor,
      dueTodayColor: dueTodayColor ?? this.dueTodayColor,
      overdueColor: overdueColor ?? this.overdueColor,
      completeColor: completeColor ?? this.completeColor,
    );
  }
}

class KyGanttTaskBarTooltipOptions {
  const KyGanttTaskBarTooltipOptions({
    this.visible = true,
    this.showStatus = true,
    this.showDateRange = true,
    this.showDuration = true,
    this.showProgress = true,
    this.showDependency = true,
    this.showAssignees = true,
    this.showClipHints = true,
  });

  final bool visible;
  final bool showStatus;
  final bool showDateRange;
  final bool showDuration;
  final bool showProgress;
  final bool showDependency;
  final bool showAssignees;
  final bool showClipHints;

  KyGanttTaskBarTooltipOptions copyWith({
    bool? visible,
    bool? showStatus,
    bool? showDateRange,
    bool? showDuration,
    bool? showProgress,
    bool? showDependency,
    bool? showAssignees,
    bool? showClipHints,
  }) {
    return KyGanttTaskBarTooltipOptions(
      visible: visible ?? this.visible,
      showStatus: showStatus ?? this.showStatus,
      showDateRange: showDateRange ?? this.showDateRange,
      showDuration: showDuration ?? this.showDuration,
      showProgress: showProgress ?? this.showProgress,
      showDependency: showDependency ?? this.showDependency,
      showAssignees: showAssignees ?? this.showAssignees,
      showClipHints: showClipHints ?? this.showClipHints,
    );
  }
}

class KyGanttDependencyLineOptions {
  const KyGanttDependencyLineOptions({
    this.visible = true,
    this.highlightSelectedTask = true,
    this.highlightRelatedTaskBars = true,
    this.highlightConflictedDependencies = true,
    this.focusScope = KyGanttDependencyLineFocusScope.direct,
    this.color,
    this.highlightColor,
    this.conflictColor,
    this.lineOpacity = 0.62,
    this.inactiveLineOpacity = 0.16,
    this.highlightLineOpacity = 0.9,
    this.conflictLineOpacity = 0.92,
    this.strokeWidth = 1.6,
    this.highlightStrokeWidth = 2.4,
    this.conflictStrokeWidth = 2.2,
  });

  final bool visible;
  final bool highlightSelectedTask;
  final bool highlightRelatedTaskBars;
  final bool highlightConflictedDependencies;
  final KyGanttDependencyLineFocusScope focusScope;
  final Color? color;
  final Color? highlightColor;
  final Color? conflictColor;
  final double lineOpacity;
  final double inactiveLineOpacity;
  final double highlightLineOpacity;
  final double conflictLineOpacity;
  final double strokeWidth;
  final double highlightStrokeWidth;
  final double conflictStrokeWidth;

  KyGanttDependencyLineOptions copyWith({
    bool? visible,
    bool? highlightSelectedTask,
    bool? highlightRelatedTaskBars,
    bool? highlightConflictedDependencies,
    KyGanttDependencyLineFocusScope? focusScope,
    Color? color,
    Color? highlightColor,
    Color? conflictColor,
    double? lineOpacity,
    double? inactiveLineOpacity,
    double? highlightLineOpacity,
    double? conflictLineOpacity,
    double? strokeWidth,
    double? highlightStrokeWidth,
    double? conflictStrokeWidth,
  }) {
    return KyGanttDependencyLineOptions(
      visible: visible ?? this.visible,
      highlightSelectedTask:
          highlightSelectedTask ?? this.highlightSelectedTask,
      highlightRelatedTaskBars:
          highlightRelatedTaskBars ?? this.highlightRelatedTaskBars,
      highlightConflictedDependencies: highlightConflictedDependencies ??
          this.highlightConflictedDependencies,
      focusScope: focusScope ?? this.focusScope,
      color: color ?? this.color,
      highlightColor: highlightColor ?? this.highlightColor,
      conflictColor: conflictColor ?? this.conflictColor,
      lineOpacity: lineOpacity ?? this.lineOpacity,
      inactiveLineOpacity: inactiveLineOpacity ?? this.inactiveLineOpacity,
      highlightLineOpacity: highlightLineOpacity ?? this.highlightLineOpacity,
      conflictLineOpacity: conflictLineOpacity ?? this.conflictLineOpacity,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      highlightStrokeWidth: highlightStrokeWidth ?? this.highlightStrokeWidth,
      conflictStrokeWidth: conflictStrokeWidth ?? this.conflictStrokeWidth,
    );
  }
}

class KyGanttTaskAvatar {
  const KyGanttTaskAvatar({
    required this.id,
    required this.label,
    this.initials,
    this.tooltip,
    this.color,
  });

  final String id;
  final String label;
  final String? initials;
  final String? tooltip;
  final Color? color;

  String get displayInitials {
    final explicit = initials?.trim();
    if (explicit != null && explicit.isNotEmpty) {
      return explicit.characters.take(2).toString().toUpperCase();
    }

    final parts = label
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }

    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}
