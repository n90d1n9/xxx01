import '../states/gantt_chart_display_provider.dart';
import '../states/gantt_chart_interaction_provider.dart';
import 'gantt_timeline_range_preset_service.dart';

class GanttChartWorkspacePreferences {
  const GanttChartWorkspacePreferences({
    this.displayPreferences = GanttChartDisplayPreferences.initial,
    this.interactionPreferences = GanttChartInteractionPreferences.initial,
    this.rangePreset = GanttTimelineRangePreset.planningWindow,
    this.controlsExpanded = true,
  });

  static const initial = GanttChartWorkspacePreferences();

  final GanttChartDisplayPreferences displayPreferences;
  final GanttChartInteractionPreferences interactionPreferences;
  final GanttTimelineRangePreset rangePreset;
  final bool controlsExpanded;

  factory GanttChartWorkspacePreferences.fromJson(Map<String, Object?>? json) {
    if (json == null) return initial;

    return GanttChartWorkspacePreferences(
      displayPreferences: GanttChartDisplayPreferences.fromJson(
        _asJsonMap(json['displayPreferences']),
      ),
      interactionPreferences: GanttChartInteractionPreferences.fromJson(
        _asJsonMap(json['interactionPreferences']),
      ),
      rangePreset: _rangePresetFromJson(json['rangePreset']),
      controlsExpanded: _boolValue(
        json['controlsExpanded'],
        initial.controlsExpanded,
      ),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'displayPreferences': displayPreferences.toJson(),
      'interactionPreferences': interactionPreferences.toJson(),
      'rangePreset': rangePreset.name,
      'controlsExpanded': controlsExpanded,
    };
  }

  GanttChartWorkspacePreferences copyWith({
    GanttChartDisplayPreferences? displayPreferences,
    GanttChartInteractionPreferences? interactionPreferences,
    GanttTimelineRangePreset? rangePreset,
    bool? controlsExpanded,
  }) {
    return GanttChartWorkspacePreferences(
      displayPreferences: displayPreferences ?? this.displayPreferences,
      interactionPreferences:
          interactionPreferences ?? this.interactionPreferences,
      rangePreset: rangePreset ?? this.rangePreset,
      controlsExpanded: controlsExpanded ?? this.controlsExpanded,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is GanttChartWorkspacePreferences &&
            displayPreferences == other.displayPreferences &&
            interactionPreferences == other.interactionPreferences &&
            rangePreset == other.rangePreset &&
            controlsExpanded == other.controlsExpanded;
  }

  @override
  int get hashCode {
    return Object.hash(
      displayPreferences,
      interactionPreferences,
      rangePreset,
      controlsExpanded,
    );
  }
}

bool _boolValue(Object? value, bool fallback) {
  return value is bool ? value : fallback;
}

Map<String, Object?>? _asJsonMap(Object? value) {
  if (value == null) return null;
  if (value is Map<String, Object?>) return value;
  if (value is Map) return Map<String, Object?>.from(value);

  return null;
}

GanttTimelineRangePreset _rangePresetFromJson(Object? value) {
  if (value is String) {
    for (final preset in GanttTimelineRangePreset.values) {
      if (preset.name == value) return preset;
    }
  }

  return GanttTimelineRangePreset.planningWindow;
}
