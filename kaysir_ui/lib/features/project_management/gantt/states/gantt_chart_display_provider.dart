import 'package:ky_gantt/ky_gantt.dart' as ky;

enum GanttChartDensity {
  airy,
  cozy,
  dense;

  double get rowHeight {
    switch (this) {
      case GanttChartDensity.airy:
        return 58;
      case GanttChartDensity.cozy:
        return 50;
      case GanttChartDensity.dense:
        return 44;
    }
  }

  double get headerHeight {
    switch (this) {
      case GanttChartDensity.airy:
        return 62;
      case GanttChartDensity.cozy:
        return 58;
      case GanttChartDensity.dense:
        return 52;
    }
  }
}

enum GanttChartTimelineZoom {
  compact(0.82),
  balanced(1),
  wide(1.24);

  const GanttChartTimelineZoom(this.scale);

  final double scale;
}

enum GanttTimelineAccentIntensity {
  subtle(
    weekendBandOpacity: 0.24,
    todayIndicatorOpacity: 0.08,
    todayMarkerOpacity: 0.56,
  ),
  balanced(
    weekendBandOpacity: 0.5,
    todayIndicatorOpacity: 0.14,
    todayMarkerOpacity: 1,
  ),
  strong(
    weekendBandOpacity: 0.72,
    todayIndicatorOpacity: 0.22,
    todayMarkerOpacity: 1,
  );

  const GanttTimelineAccentIntensity({
    required this.weekendBandOpacity,
    required this.todayIndicatorOpacity,
    required this.todayMarkerOpacity,
  });

  final double weekendBandOpacity;
  final double todayIndicatorOpacity;
  final double todayMarkerOpacity;
}

enum GanttTaskBarTooltipDetail {
  rich,
  lean,
  minimal;

  ky.KyGanttTaskBarTooltipOptions kyOptions({required bool visible}) {
    switch (this) {
      case GanttTaskBarTooltipDetail.rich:
        return ky.KyGanttTaskBarTooltipOptions(visible: visible);
      case GanttTaskBarTooltipDetail.lean:
        return ky.KyGanttTaskBarTooltipOptions(
          visible: visible,
          showDuration: false,
          showClipHints: false,
        );
      case GanttTaskBarTooltipDetail.minimal:
        return ky.KyGanttTaskBarTooltipOptions(
          visible: visible,
          showStatus: false,
          showDuration: false,
          showDependency: false,
          showAssignees: false,
          showClipHints: false,
        );
    }
  }
}

enum GanttTaskBarScheduleBadgeStyle {
  full,
  marker,
  text;

  ky.KyGanttTaskBarScheduleBadgeOptions kyOptions({required bool visible}) {
    switch (this) {
      case GanttTaskBarScheduleBadgeStyle.full:
        return ky.KyGanttTaskBarScheduleBadgeOptions(visible: visible);
      case GanttTaskBarScheduleBadgeStyle.marker:
        return ky.KyGanttTaskBarScheduleBadgeOptions(
          visible: visible,
          showLabel: false,
        );
      case GanttTaskBarScheduleBadgeStyle.text:
        return ky.KyGanttTaskBarScheduleBadgeOptions(
          visible: visible,
          showAccent: false,
        );
    }
  }
}

enum GanttDependencyLineIntensity {
  subtle,
  balanced,
  strong;

  ky.KyGanttDependencyLineOptions kyOptions({
    required bool visible,
    required bool highlightSelectedTask,
    required bool highlightRelatedTaskBars,
    required bool highlightConflictedDependencies,
    required ky.KyGanttDependencyLineFocusScope focusScope,
  }) {
    switch (this) {
      case GanttDependencyLineIntensity.subtle:
        return ky.KyGanttDependencyLineOptions(
          visible: visible,
          highlightSelectedTask: highlightSelectedTask,
          highlightRelatedTaskBars: highlightRelatedTaskBars,
          highlightConflictedDependencies: highlightConflictedDependencies,
          focusScope: focusScope,
          lineOpacity: 0.38,
          inactiveLineOpacity: 0.08,
          highlightLineOpacity: 0.72,
          conflictLineOpacity: 0.8,
          strokeWidth: 1.2,
          highlightStrokeWidth: 1.8,
          conflictStrokeWidth: 1.8,
        );
      case GanttDependencyLineIntensity.balanced:
        return ky.KyGanttDependencyLineOptions(
          visible: visible,
          highlightSelectedTask: highlightSelectedTask,
          highlightRelatedTaskBars: highlightRelatedTaskBars,
          highlightConflictedDependencies: highlightConflictedDependencies,
          focusScope: focusScope,
        );
      case GanttDependencyLineIntensity.strong:
        return ky.KyGanttDependencyLineOptions(
          visible: visible,
          highlightSelectedTask: highlightSelectedTask,
          highlightRelatedTaskBars: highlightRelatedTaskBars,
          highlightConflictedDependencies: highlightConflictedDependencies,
          focusScope: focusScope,
          lineOpacity: 0.78,
          inactiveLineOpacity: 0.22,
          highlightLineOpacity: 1,
          conflictLineOpacity: 1,
          strokeWidth: 2,
          highlightStrokeWidth: 3,
          conflictStrokeWidth: 2.8,
        );
    }
  }
}

enum GanttSelectedTaskRowEmphasis {
  subtle(0.04),
  balanced(0.08),
  strong(0.14);

  const GanttSelectedTaskRowEmphasis(this.opacity);

  final double opacity;
}

enum GanttTaskBarDepth {
  subtle(opacityScale: 0.62, blurScale: 0.78, offsetScale: 0.72),
  balanced(opacityScale: 1, blurScale: 1, offsetScale: 1),
  elevated(opacityScale: 1.28, blurScale: 1.24, offsetScale: 1.18);

  const GanttTaskBarDepth({
    required this.opacityScale,
    required this.blurScale,
    required this.offsetScale,
  });

  final double opacityScale;
  final double blurScale;
  final double offsetScale;

  ky.KyGanttTaskBarShadowOptions get kyOptions {
    return ky.KyGanttTaskBarShadowOptions(
      opacityScale: opacityScale,
      blurScale: blurScale,
      offsetScale: offsetScale,
    );
  }
}

enum GanttTeamAvatarStyle {
  compact(size: 18, overlap: 7, minTaskBarWidth: 96),
  balanced(size: 22, overlap: 8, minTaskBarWidth: 112),
  prominent(size: 26, overlap: 10, minTaskBarWidth: 128);

  const GanttTeamAvatarStyle({
    required this.size,
    required this.overlap,
    required this.minTaskBarWidth,
  });

  final double size;
  final double overlap;
  final double minTaskBarWidth;

  ky.KyGanttTaskBarAvatarOptions get kyOptions {
    return ky.KyGanttTaskBarAvatarOptions(
      size: size,
      overlap: overlap,
      minTaskBarWidth: minTaskBarWidth,
    );
  }
}

class GanttChartDisplayPreferences {
  const GanttChartDisplayPreferences({
    this.showTaskBarShadows = true,
    this.taskBarDepth = GanttTaskBarDepth.balanced,
    this.showSelectedTaskFocus = true,
    this.showSelectedTaskRowHighlight = true,
    this.selectedTaskRowEmphasis = GanttSelectedTaskRowEmphasis.balanced,
    this.showTaskBarDateLabels = true,
    this.showTaskBarDurationLabels = true,
    this.showTaskBarDependencyBadges = true,
    this.showTaskBarDependencyConflictBadges = true,
    this.showTaskBarProgressLabels = true,
    this.showTaskBarStatusLabels = true,
    this.showTaskBarScheduleBadges = true,
    this.taskBarScheduleBadgeStyle = GanttTaskBarScheduleBadgeStyle.full,
    this.showMilestoneLabels = true,
    this.showMilestoneDateLabels = true,
    this.showTaskBarTooltips = true,
    this.taskBarTooltipDetail = GanttTaskBarTooltipDetail.rich,
    this.showTeamAvatars = false,
    this.teamAvatarStyle = GanttTeamAvatarStyle.balanced,
    this.maxTeamAvatars = 3,
    this.showTodayMarker = true,
    this.showWeekendBands = true,
    this.timelineAccentIntensity = GanttTimelineAccentIntensity.balanced,
    this.showDependencyLines = true,
    this.highlightSelectedDependencies = true,
    this.dependencyFocusScope = ky.KyGanttDependencyLineFocusScope.chain,
    this.dependencyLineIntensity = GanttDependencyLineIntensity.balanced,
    this.density = GanttChartDensity.airy,
    this.timelineZoom = GanttChartTimelineZoom.balanced,
  });

  static const initial = GanttChartDisplayPreferences();

  final bool showTaskBarShadows;
  final GanttTaskBarDepth taskBarDepth;
  final bool showSelectedTaskFocus;
  final bool showSelectedTaskRowHighlight;
  final GanttSelectedTaskRowEmphasis selectedTaskRowEmphasis;
  final bool showTaskBarDateLabels;
  final bool showTaskBarDurationLabels;
  final bool showTaskBarDependencyBadges;
  final bool showTaskBarDependencyConflictBadges;
  final bool showTaskBarProgressLabels;
  final bool showTaskBarStatusLabels;
  final bool showTaskBarScheduleBadges;
  final GanttTaskBarScheduleBadgeStyle taskBarScheduleBadgeStyle;
  final bool showMilestoneLabels;
  final bool showMilestoneDateLabels;
  final bool showTaskBarTooltips;
  final GanttTaskBarTooltipDetail taskBarTooltipDetail;
  final bool showTeamAvatars;
  final GanttTeamAvatarStyle teamAvatarStyle;
  final int maxTeamAvatars;
  final bool showTodayMarker;
  final bool showWeekendBands;
  final GanttTimelineAccentIntensity timelineAccentIntensity;
  final bool showDependencyLines;
  final bool highlightSelectedDependencies;
  final ky.KyGanttDependencyLineFocusScope dependencyFocusScope;
  final GanttDependencyLineIntensity dependencyLineIntensity;
  final GanttChartDensity density;
  final GanttChartTimelineZoom timelineZoom;

  int get visibleTeamAvatarLimit => maxTeamAvatars.clamp(1, 5).toInt();

  factory GanttChartDisplayPreferences.fromJson(Map<String, Object?>? json) {
    if (json == null) return initial;

    return GanttChartDisplayPreferences(
      showTaskBarShadows: _boolValue(
        json['showTaskBarShadows'],
        initial.showTaskBarShadows,
      ),
      taskBarDepth: _enumValue(
        json['taskBarDepth'],
        GanttTaskBarDepth.values,
        initial.taskBarDepth,
      ),
      showSelectedTaskFocus: _boolValue(
        json['showSelectedTaskFocus'],
        initial.showSelectedTaskFocus,
      ),
      showSelectedTaskRowHighlight: _boolValue(
        json['showSelectedTaskRowHighlight'],
        initial.showSelectedTaskRowHighlight,
      ),
      selectedTaskRowEmphasis: _enumValue(
        json['selectedTaskRowEmphasis'],
        GanttSelectedTaskRowEmphasis.values,
        initial.selectedTaskRowEmphasis,
      ),
      showTaskBarDateLabels: _boolValue(
        json['showTaskBarDateLabels'],
        initial.showTaskBarDateLabels,
      ),
      showTaskBarDurationLabels: _boolValue(
        json['showTaskBarDurationLabels'],
        initial.showTaskBarDurationLabels,
      ),
      showTaskBarDependencyBadges: _boolValue(
        json['showTaskBarDependencyBadges'],
        initial.showTaskBarDependencyBadges,
      ),
      showTaskBarDependencyConflictBadges: _boolValue(
        json['showTaskBarDependencyConflictBadges'],
        initial.showTaskBarDependencyConflictBadges,
      ),
      showTaskBarProgressLabels: _boolValue(
        json['showTaskBarProgressLabels'],
        initial.showTaskBarProgressLabels,
      ),
      showTaskBarStatusLabels: _boolValue(
        json['showTaskBarStatusLabels'],
        initial.showTaskBarStatusLabels,
      ),
      showTaskBarScheduleBadges: _boolValue(
        json['showTaskBarScheduleBadges'],
        initial.showTaskBarScheduleBadges,
      ),
      taskBarScheduleBadgeStyle: _enumValue(
        json['taskBarScheduleBadgeStyle'],
        GanttTaskBarScheduleBadgeStyle.values,
        initial.taskBarScheduleBadgeStyle,
      ),
      showMilestoneLabels: _boolValue(
        json['showMilestoneLabels'],
        initial.showMilestoneLabels,
      ),
      showMilestoneDateLabels: _boolValue(
        json['showMilestoneDateLabels'],
        initial.showMilestoneDateLabels,
      ),
      showTaskBarTooltips: _boolValue(
        json['showTaskBarTooltips'],
        initial.showTaskBarTooltips,
      ),
      taskBarTooltipDetail: _enumValue(
        json['taskBarTooltipDetail'],
        GanttTaskBarTooltipDetail.values,
        initial.taskBarTooltipDetail,
      ),
      showTeamAvatars: _boolValue(
        json['showTeamAvatars'],
        initial.showTeamAvatars,
      ),
      teamAvatarStyle: _enumValue(
        json['teamAvatarStyle'],
        GanttTeamAvatarStyle.values,
        initial.teamAvatarStyle,
      ),
      maxTeamAvatars:
          _intValue(
            json['maxTeamAvatars'],
            initial.maxTeamAvatars,
          ).clamp(1, 5).toInt(),
      showTodayMarker: _boolValue(
        json['showTodayMarker'],
        initial.showTodayMarker,
      ),
      showWeekendBands: _boolValue(
        json['showWeekendBands'],
        initial.showWeekendBands,
      ),
      timelineAccentIntensity: _enumValue(
        json['timelineAccentIntensity'],
        GanttTimelineAccentIntensity.values,
        initial.timelineAccentIntensity,
      ),
      showDependencyLines: _boolValue(
        json['showDependencyLines'],
        initial.showDependencyLines,
      ),
      highlightSelectedDependencies: _boolValue(
        json['highlightSelectedDependencies'],
        initial.highlightSelectedDependencies,
      ),
      dependencyFocusScope: _enumValue(
        json['dependencyFocusScope'],
        ky.KyGanttDependencyLineFocusScope.values,
        initial.dependencyFocusScope,
      ),
      dependencyLineIntensity: _enumValue(
        json['dependencyLineIntensity'],
        GanttDependencyLineIntensity.values,
        initial.dependencyLineIntensity,
      ),
      density: _enumValue(
        json['density'],
        GanttChartDensity.values,
        initial.density,
      ),
      timelineZoom: _enumValue(
        json['timelineZoom'],
        GanttChartTimelineZoom.values,
        initial.timelineZoom,
      ),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'showTaskBarShadows': showTaskBarShadows,
      'taskBarDepth': taskBarDepth.name,
      'showSelectedTaskFocus': showSelectedTaskFocus,
      'showSelectedTaskRowHighlight': showSelectedTaskRowHighlight,
      'selectedTaskRowEmphasis': selectedTaskRowEmphasis.name,
      'showTaskBarDateLabels': showTaskBarDateLabels,
      'showTaskBarDurationLabels': showTaskBarDurationLabels,
      'showTaskBarDependencyBadges': showTaskBarDependencyBadges,
      'showTaskBarDependencyConflictBadges':
          showTaskBarDependencyConflictBadges,
      'showTaskBarProgressLabels': showTaskBarProgressLabels,
      'showTaskBarStatusLabels': showTaskBarStatusLabels,
      'showTaskBarScheduleBadges': showTaskBarScheduleBadges,
      'taskBarScheduleBadgeStyle': taskBarScheduleBadgeStyle.name,
      'showMilestoneLabels': showMilestoneLabels,
      'showMilestoneDateLabels': showMilestoneDateLabels,
      'showTaskBarTooltips': showTaskBarTooltips,
      'taskBarTooltipDetail': taskBarTooltipDetail.name,
      'showTeamAvatars': showTeamAvatars,
      'teamAvatarStyle': teamAvatarStyle.name,
      'maxTeamAvatars': visibleTeamAvatarLimit,
      'showTodayMarker': showTodayMarker,
      'showWeekendBands': showWeekendBands,
      'timelineAccentIntensity': timelineAccentIntensity.name,
      'showDependencyLines': showDependencyLines,
      'highlightSelectedDependencies': highlightSelectedDependencies,
      'dependencyFocusScope': dependencyFocusScope.name,
      'dependencyLineIntensity': dependencyLineIntensity.name,
      'density': density.name,
      'timelineZoom': timelineZoom.name,
    };
  }

  ky.KyGanttChartDisplayOptions get kyOptions {
    return ky.KyGanttChartDisplayOptions(
      showTaskBarShadows: showTaskBarShadows,
      showSelectedTaskFocus: showSelectedTaskFocus,
      showSelectedTaskRowHighlight: showSelectedTaskRowHighlight,
      selectedTaskRowHighlightOpacity: selectedTaskRowEmphasis.opacity,
      taskBarShadow: taskBarDepth.kyOptions,
      showTaskBarDateLabels: showTaskBarDateLabels,
      showTaskBarDurationLabels: showTaskBarDurationLabels,
      showTaskBarDependencyBadges: showTaskBarDependencyBadges,
      showTaskBarDependencyConflictBadges: showTaskBarDependencyConflictBadges,
      showTaskBarProgressLabels: showTaskBarProgressLabels,
      showTaskBarStatusLabels: showTaskBarStatusLabels,
      taskBarScheduleBadge: taskBarScheduleBadgeStyle.kyOptions(
        visible: showTaskBarScheduleBadges,
      ),
      showMilestoneLabels: showMilestoneLabels,
      showMilestoneDateLabels: showMilestoneDateLabels,
      taskBarTooltip: taskBarTooltipDetail.kyOptions(
        visible: showTaskBarTooltips,
      ),
      showTaskBarAvatars: showTeamAvatars,
      taskBarAvatar: teamAvatarStyle.kyOptions,
      maxTaskBarAvatars: visibleTeamAvatarLimit,
      showTodayMarker: showTodayMarker,
      showWeekendBands: showWeekendBands,
      weekendBandOpacity: timelineAccentIntensity.weekendBandOpacity,
      todayIndicatorOpacity: timelineAccentIntensity.todayIndicatorOpacity,
      todayMarkerOpacity: timelineAccentIntensity.todayMarkerOpacity,
      dependencyLines: dependencyLineIntensity.kyOptions(
        visible: showDependencyLines,
        highlightSelectedTask: highlightSelectedDependencies,
        highlightRelatedTaskBars: highlightSelectedDependencies,
        highlightConflictedDependencies: showTaskBarDependencyConflictBadges,
        focusScope: dependencyFocusScope,
      ),
    );
  }

  GanttChartDisplayPreferences copyWith({
    bool? showTaskBarShadows,
    GanttTaskBarDepth? taskBarDepth,
    bool? showSelectedTaskFocus,
    bool? showSelectedTaskRowHighlight,
    GanttSelectedTaskRowEmphasis? selectedTaskRowEmphasis,
    bool? showTaskBarDateLabels,
    bool? showTaskBarDurationLabels,
    bool? showTaskBarDependencyBadges,
    bool? showTaskBarDependencyConflictBadges,
    bool? showTaskBarProgressLabels,
    bool? showTaskBarStatusLabels,
    bool? showTaskBarScheduleBadges,
    GanttTaskBarScheduleBadgeStyle? taskBarScheduleBadgeStyle,
    bool? showMilestoneLabels,
    bool? showMilestoneDateLabels,
    bool? showTaskBarTooltips,
    GanttTaskBarTooltipDetail? taskBarTooltipDetail,
    bool? showTeamAvatars,
    GanttTeamAvatarStyle? teamAvatarStyle,
    int? maxTeamAvatars,
    bool? showTodayMarker,
    bool? showWeekendBands,
    GanttTimelineAccentIntensity? timelineAccentIntensity,
    bool? showDependencyLines,
    bool? highlightSelectedDependencies,
    ky.KyGanttDependencyLineFocusScope? dependencyFocusScope,
    GanttDependencyLineIntensity? dependencyLineIntensity,
    GanttChartDensity? density,
    GanttChartTimelineZoom? timelineZoom,
  }) {
    return GanttChartDisplayPreferences(
      showTaskBarShadows: showTaskBarShadows ?? this.showTaskBarShadows,
      taskBarDepth: taskBarDepth ?? this.taskBarDepth,
      showSelectedTaskFocus:
          showSelectedTaskFocus ?? this.showSelectedTaskFocus,
      showSelectedTaskRowHighlight:
          showSelectedTaskRowHighlight ?? this.showSelectedTaskRowHighlight,
      selectedTaskRowEmphasis:
          selectedTaskRowEmphasis ?? this.selectedTaskRowEmphasis,
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
      showTaskBarScheduleBadges:
          showTaskBarScheduleBadges ?? this.showTaskBarScheduleBadges,
      taskBarScheduleBadgeStyle:
          taskBarScheduleBadgeStyle ?? this.taskBarScheduleBadgeStyle,
      showMilestoneLabels: showMilestoneLabels ?? this.showMilestoneLabels,
      showMilestoneDateLabels:
          showMilestoneDateLabels ?? this.showMilestoneDateLabels,
      showTaskBarTooltips: showTaskBarTooltips ?? this.showTaskBarTooltips,
      taskBarTooltipDetail: taskBarTooltipDetail ?? this.taskBarTooltipDetail,
      showTeamAvatars: showTeamAvatars ?? this.showTeamAvatars,
      teamAvatarStyle: teamAvatarStyle ?? this.teamAvatarStyle,
      maxTeamAvatars: maxTeamAvatars ?? this.maxTeamAvatars,
      showTodayMarker: showTodayMarker ?? this.showTodayMarker,
      showWeekendBands: showWeekendBands ?? this.showWeekendBands,
      timelineAccentIntensity:
          timelineAccentIntensity ?? this.timelineAccentIntensity,
      showDependencyLines: showDependencyLines ?? this.showDependencyLines,
      highlightSelectedDependencies:
          highlightSelectedDependencies ?? this.highlightSelectedDependencies,
      dependencyFocusScope: dependencyFocusScope ?? this.dependencyFocusScope,
      dependencyLineIntensity:
          dependencyLineIntensity ?? this.dependencyLineIntensity,
      density: density ?? this.density,
      timelineZoom: timelineZoom ?? this.timelineZoom,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is GanttChartDisplayPreferences &&
            showTaskBarShadows == other.showTaskBarShadows &&
            taskBarDepth == other.taskBarDepth &&
            showSelectedTaskFocus == other.showSelectedTaskFocus &&
            showSelectedTaskRowHighlight ==
                other.showSelectedTaskRowHighlight &&
            selectedTaskRowEmphasis == other.selectedTaskRowEmphasis &&
            showTaskBarDateLabels == other.showTaskBarDateLabels &&
            showTaskBarDurationLabels == other.showTaskBarDurationLabels &&
            showTaskBarDependencyBadges == other.showTaskBarDependencyBadges &&
            showTaskBarDependencyConflictBadges ==
                other.showTaskBarDependencyConflictBadges &&
            showTaskBarProgressLabels == other.showTaskBarProgressLabels &&
            showTaskBarStatusLabels == other.showTaskBarStatusLabels &&
            showTaskBarScheduleBadges == other.showTaskBarScheduleBadges &&
            taskBarScheduleBadgeStyle == other.taskBarScheduleBadgeStyle &&
            showMilestoneLabels == other.showMilestoneLabels &&
            showMilestoneDateLabels == other.showMilestoneDateLabels &&
            showTaskBarTooltips == other.showTaskBarTooltips &&
            taskBarTooltipDetail == other.taskBarTooltipDetail &&
            showTeamAvatars == other.showTeamAvatars &&
            teamAvatarStyle == other.teamAvatarStyle &&
            maxTeamAvatars == other.maxTeamAvatars &&
            showTodayMarker == other.showTodayMarker &&
            showWeekendBands == other.showWeekendBands &&
            timelineAccentIntensity == other.timelineAccentIntensity &&
            showDependencyLines == other.showDependencyLines &&
            highlightSelectedDependencies ==
                other.highlightSelectedDependencies &&
            dependencyFocusScope == other.dependencyFocusScope &&
            dependencyLineIntensity == other.dependencyLineIntensity &&
            density == other.density &&
            timelineZoom == other.timelineZoom;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      showTaskBarShadows,
      taskBarDepth,
      showSelectedTaskFocus,
      showSelectedTaskRowHighlight,
      selectedTaskRowEmphasis,
      showTaskBarDateLabels,
      showTaskBarDurationLabels,
      showTaskBarDependencyBadges,
      showTaskBarDependencyConflictBadges,
      showTaskBarProgressLabels,
      showTaskBarStatusLabels,
      showTaskBarScheduleBadges,
      taskBarScheduleBadgeStyle,
      showMilestoneLabels,
      showMilestoneDateLabels,
      showTaskBarTooltips,
      taskBarTooltipDetail,
      showTeamAvatars,
      teamAvatarStyle,
      maxTeamAvatars,
      showTodayMarker,
      showWeekendBands,
      timelineAccentIntensity,
      showDependencyLines,
      highlightSelectedDependencies,
      dependencyFocusScope,
      dependencyLineIntensity,
      density,
      timelineZoom,
    ]);
  }
}

bool _boolValue(Object? value, bool fallback) {
  return value is bool ? value : fallback;
}

int _intValue(Object? value, int fallback) {
  return value is int ? value : fallback;
}

T _enumValue<T extends Enum>(Object? value, List<T> values, T fallback) {
  if (value is! String || value.isEmpty) return fallback;

  for (final enumValue in values) {
    if (enumValue.name == value) return enumValue;
  }

  return fallback;
}
