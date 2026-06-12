import 'package:ky_gantt/ky_gantt.dart' as ky;

enum GanttTaskInspectorPlacement { adaptive, side, bottom }

enum GanttDragPreviewDetail {
  lean(showMetadataPills: false, showGhostBar: false, showDeltaStrip: false),
  balanced(showMetadataPills: true, showGhostBar: true, showDeltaStrip: false),
  detailed(showMetadataPills: true, showGhostBar: true, showDeltaStrip: true);

  const GanttDragPreviewDetail({
    required this.showMetadataPills,
    required this.showGhostBar,
    required this.showDeltaStrip,
  });

  final bool showMetadataPills;
  final bool showGhostBar;
  final bool showDeltaStrip;
}

enum GanttInteractionFeedbackDepth {
  subtle(opacityScale: 0.72, blurScale: 0.78, offsetScale: 0.72),
  balanced(opacityScale: 1, blurScale: 1, offsetScale: 1),
  elevated(opacityScale: 1.22, blurScale: 1.18, offsetScale: 1.14);

  const GanttInteractionFeedbackDepth({
    required this.opacityScale,
    required this.blurScale,
    required this.offsetScale,
  });

  final double opacityScale;
  final double blurScale;
  final double offsetScale;

  ky.KyGanttTaskBarInteractionFeedbackOptions get kyOptions {
    return ky.KyGanttTaskBarInteractionFeedbackOptions(
      opacityScale: opacityScale,
      blurScale: blurScale,
      offsetScale: offsetScale,
    );
  }
}

class GanttChartInteractionPreferences {
  const GanttChartInteractionPreferences({
    this.enableTaskBarDrag = true,
    this.enableTaskBarResize = true,
    this.dragSnap = ky.KyGanttTaskDragSnap.day,
    this.showDragPreview = true,
    this.showDragImpactSummary = true,
    this.dragPreviewDetail = GanttDragPreviewDetail.detailed,
    this.showDragGuides = true,
    this.showDragGuideLabels = true,
    this.showDragValidationBadge = true,
    this.showDropTarget = true,
    this.showBlockedDropPattern = true,
    this.showInteractionLift = true,
    this.showInteractionGhost = true,
    this.showHoverFocusRing = true,
    this.showDragHandle = true,
    this.interactionFeedbackDepth = GanttInteractionFeedbackDepth.balanced,
    this.resizeHandleVisibility = ky.KyGanttTaskResizeHandleVisibility.focused,
    this.enableScheduleGuard = true,
    this.showScheduleEditFeedback = true,
    this.inspectorPlacement = GanttTaskInspectorPlacement.adaptive,
  });

  static const initial = GanttChartInteractionPreferences();

  final bool enableTaskBarDrag;
  final bool enableTaskBarResize;
  final ky.KyGanttTaskDragSnap dragSnap;
  final bool showDragPreview;
  final bool showDragImpactSummary;
  final GanttDragPreviewDetail dragPreviewDetail;
  final bool showDragGuides;
  final bool showDragGuideLabels;
  final bool showDragValidationBadge;
  final bool showDropTarget;
  final bool showBlockedDropPattern;
  final bool showInteractionLift;
  final bool showInteractionGhost;
  final bool showHoverFocusRing;
  final bool showDragHandle;
  final GanttInteractionFeedbackDepth interactionFeedbackDepth;
  final ky.KyGanttTaskResizeHandleVisibility resizeHandleVisibility;
  final bool enableScheduleGuard;
  final bool showScheduleEditFeedback;
  final GanttTaskInspectorPlacement inspectorPlacement;

  factory GanttChartInteractionPreferences.fromJson(
    Map<String, Object?>? json,
  ) {
    if (json == null) return initial;

    return GanttChartInteractionPreferences(
      enableTaskBarDrag: _boolValue(
        json['enableTaskBarDrag'],
        initial.enableTaskBarDrag,
      ),
      enableTaskBarResize: _boolValue(
        json['enableTaskBarResize'],
        initial.enableTaskBarResize,
      ),
      dragSnap: _enumValue(
        json['dragSnap'],
        ky.KyGanttTaskDragSnap.values,
        initial.dragSnap,
      ),
      showDragPreview: _boolValue(
        json['showDragPreview'],
        initial.showDragPreview,
      ),
      showDragImpactSummary: _boolValue(
        json['showDragImpactSummary'],
        initial.showDragImpactSummary,
      ),
      dragPreviewDetail: _enumValue(
        json['dragPreviewDetail'],
        GanttDragPreviewDetail.values,
        initial.dragPreviewDetail,
      ),
      showDragGuides: _boolValue(
        json['showDragGuides'],
        initial.showDragGuides,
      ),
      showDragGuideLabels: _boolValue(
        json['showDragGuideLabels'],
        initial.showDragGuideLabels,
      ),
      showDragValidationBadge: _boolValue(
        json['showDragValidationBadge'],
        initial.showDragValidationBadge,
      ),
      showDropTarget: _boolValue(
        json['showDropTarget'],
        initial.showDropTarget,
      ),
      showBlockedDropPattern: _boolValue(
        json['showBlockedDropPattern'],
        initial.showBlockedDropPattern,
      ),
      showInteractionLift: _boolValue(
        json['showInteractionLift'],
        initial.showInteractionLift,
      ),
      showInteractionGhost: _boolValue(
        json['showInteractionGhost'],
        initial.showInteractionGhost,
      ),
      showHoverFocusRing: _boolValue(
        json['showHoverFocusRing'],
        initial.showHoverFocusRing,
      ),
      showDragHandle: _boolValue(
        json['showDragHandle'],
        initial.showDragHandle,
      ),
      interactionFeedbackDepth: _enumValue(
        json['interactionFeedbackDepth'],
        GanttInteractionFeedbackDepth.values,
        initial.interactionFeedbackDepth,
      ),
      resizeHandleVisibility: _enumValue(
        json['resizeHandleVisibility'],
        ky.KyGanttTaskResizeHandleVisibility.values,
        initial.resizeHandleVisibility,
      ),
      enableScheduleGuard: _boolValue(
        json['enableScheduleGuard'],
        initial.enableScheduleGuard,
      ),
      showScheduleEditFeedback: _boolValue(
        json['showScheduleEditFeedback'],
        initial.showScheduleEditFeedback,
      ),
      inspectorPlacement: _enumValue(
        json['inspectorPlacement'],
        GanttTaskInspectorPlacement.values,
        initial.inspectorPlacement,
      ),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'enableTaskBarDrag': enableTaskBarDrag,
      'enableTaskBarResize': enableTaskBarResize,
      'dragSnap': dragSnap.name,
      'showDragPreview': showDragPreview,
      'showDragImpactSummary': showDragImpactSummary,
      'dragPreviewDetail': dragPreviewDetail.name,
      'showDragGuides': showDragGuides,
      'showDragGuideLabels': showDragGuideLabels,
      'showDragValidationBadge': showDragValidationBadge,
      'showDropTarget': showDropTarget,
      'showBlockedDropPattern': showBlockedDropPattern,
      'showInteractionLift': showInteractionLift,
      'showInteractionGhost': showInteractionGhost,
      'showHoverFocusRing': showHoverFocusRing,
      'showDragHandle': showDragHandle,
      'interactionFeedbackDepth': interactionFeedbackDepth.name,
      'resizeHandleVisibility': resizeHandleVisibility.name,
      'enableScheduleGuard': enableScheduleGuard,
      'showScheduleEditFeedback': showScheduleEditFeedback,
      'inspectorPlacement': inspectorPlacement.name,
    };
  }

  ky.KyGanttChartInteractionOptions get kyOptions {
    return ky.KyGanttChartInteractionOptions(
      enableTaskBarDrag: enableTaskBarDrag,
      enableTaskBarResize: enableTaskBarResize,
      dragSnap: dragSnap,
      showTaskBarDragPreview: showDragPreview,
      showTaskBarDragGuides: showDragGuides,
      showTaskBarDragGuideLabels: showDragGuideLabels,
      showTaskBarDragValidationBadge: showDragValidationBadge,
      showTaskBarDropTarget: showDropTarget,
      showTaskBarBlockedDropPattern: showBlockedDropPattern,
      showTaskBarInteractionLift: showInteractionLift,
      showTaskBarInteractionGhost: showInteractionGhost,
      showTaskBarHoverFocusRing: showHoverFocusRing,
      showTaskBarDragHandle: showDragHandle,
      taskBarInteractionFeedback: interactionFeedbackDepth.kyOptions,
      resizeHandleVisibility: resizeHandleVisibility,
    );
  }

  GanttChartInteractionPreferences copyWith({
    bool? enableTaskBarDrag,
    bool? enableTaskBarResize,
    ky.KyGanttTaskDragSnap? dragSnap,
    bool? showDragPreview,
    bool? showDragImpactSummary,
    GanttDragPreviewDetail? dragPreviewDetail,
    bool? showDragGuides,
    bool? showDragGuideLabels,
    bool? showDragValidationBadge,
    bool? showDropTarget,
    bool? showBlockedDropPattern,
    bool? showInteractionLift,
    bool? showInteractionGhost,
    bool? showHoverFocusRing,
    bool? showDragHandle,
    GanttInteractionFeedbackDepth? interactionFeedbackDepth,
    ky.KyGanttTaskResizeHandleVisibility? resizeHandleVisibility,
    bool? enableScheduleGuard,
    bool? showScheduleEditFeedback,
    GanttTaskInspectorPlacement? inspectorPlacement,
  }) {
    return GanttChartInteractionPreferences(
      enableTaskBarDrag: enableTaskBarDrag ?? this.enableTaskBarDrag,
      enableTaskBarResize: enableTaskBarResize ?? this.enableTaskBarResize,
      dragSnap: dragSnap ?? this.dragSnap,
      showDragPreview: showDragPreview ?? this.showDragPreview,
      showDragImpactSummary:
          showDragImpactSummary ?? this.showDragImpactSummary,
      dragPreviewDetail: dragPreviewDetail ?? this.dragPreviewDetail,
      showDragGuides: showDragGuides ?? this.showDragGuides,
      showDragGuideLabels: showDragGuideLabels ?? this.showDragGuideLabels,
      showDragValidationBadge:
          showDragValidationBadge ?? this.showDragValidationBadge,
      showDropTarget: showDropTarget ?? this.showDropTarget,
      showBlockedDropPattern:
          showBlockedDropPattern ?? this.showBlockedDropPattern,
      showInteractionLift: showInteractionLift ?? this.showInteractionLift,
      showInteractionGhost: showInteractionGhost ?? this.showInteractionGhost,
      showHoverFocusRing: showHoverFocusRing ?? this.showHoverFocusRing,
      showDragHandle: showDragHandle ?? this.showDragHandle,
      interactionFeedbackDepth:
          interactionFeedbackDepth ?? this.interactionFeedbackDepth,
      resizeHandleVisibility:
          resizeHandleVisibility ?? this.resizeHandleVisibility,
      enableScheduleGuard: enableScheduleGuard ?? this.enableScheduleGuard,
      showScheduleEditFeedback:
          showScheduleEditFeedback ?? this.showScheduleEditFeedback,
      inspectorPlacement: inspectorPlacement ?? this.inspectorPlacement,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is GanttChartInteractionPreferences &&
            enableTaskBarDrag == other.enableTaskBarDrag &&
            enableTaskBarResize == other.enableTaskBarResize &&
            dragSnap == other.dragSnap &&
            showDragPreview == other.showDragPreview &&
            showDragImpactSummary == other.showDragImpactSummary &&
            dragPreviewDetail == other.dragPreviewDetail &&
            showDragGuides == other.showDragGuides &&
            showDragGuideLabels == other.showDragGuideLabels &&
            showDragValidationBadge == other.showDragValidationBadge &&
            showDropTarget == other.showDropTarget &&
            showBlockedDropPattern == other.showBlockedDropPattern &&
            showInteractionLift == other.showInteractionLift &&
            showInteractionGhost == other.showInteractionGhost &&
            showHoverFocusRing == other.showHoverFocusRing &&
            showDragHandle == other.showDragHandle &&
            interactionFeedbackDepth == other.interactionFeedbackDepth &&
            resizeHandleVisibility == other.resizeHandleVisibility &&
            enableScheduleGuard == other.enableScheduleGuard &&
            showScheduleEditFeedback == other.showScheduleEditFeedback &&
            inspectorPlacement == other.inspectorPlacement;
  }

  @override
  int get hashCode {
    return Object.hash(
      enableTaskBarDrag,
      enableTaskBarResize,
      dragSnap,
      showDragPreview,
      showDragImpactSummary,
      dragPreviewDetail,
      showDragGuides,
      showDragGuideLabels,
      showDragValidationBadge,
      showDropTarget,
      showBlockedDropPattern,
      showInteractionLift,
      showInteractionGhost,
      showHoverFocusRing,
      showDragHandle,
      interactionFeedbackDepth,
      resizeHandleVisibility,
      enableScheduleGuard,
      showScheduleEditFeedback,
      inspectorPlacement,
    );
  }
}

bool _boolValue(Object? value, bool fallback) {
  return value is bool ? value : fallback;
}

T _enumValue<T extends Enum>(Object? value, List<T> values, T fallback) {
  if (value is! String || value.isEmpty) return fallback;

  for (final enumValue in values) {
    if (enumValue.name == value) return enumValue;
  }

  return fallback;
}
