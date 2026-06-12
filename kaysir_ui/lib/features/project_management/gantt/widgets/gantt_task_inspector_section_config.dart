import 'package:flutter/foundation.dart';

enum GanttTaskInspectorSection {
  summary,
  editing,
  readiness,
  relationships,
  actions,
}

@immutable
class GanttTaskInspectorSectionConfig {
  const GanttTaskInspectorSectionConfig({
    this.showSummary = true,
    this.showEditing = true,
    this.showReadiness = true,
    this.showRelationships = true,
    this.showActions = true,
    this.collapsibleSections = const <GanttTaskInspectorSection>{},
    this.initiallyCollapsedSections = const <GanttTaskInspectorSection>{},
  });

  static const all = GanttTaskInspectorSectionConfig();

  final bool showSummary;
  final bool showEditing;
  final bool showReadiness;
  final bool showRelationships;
  final bool showActions;
  final Set<GanttTaskInspectorSection> collapsibleSections;
  final Set<GanttTaskInspectorSection> initiallyCollapsedSections;

  bool get hasVisibleSections =>
      showSummary ||
      showEditing ||
      showReadiness ||
      showRelationships ||
      showActions;

  bool isVisible(GanttTaskInspectorSection section) {
    switch (section) {
      case GanttTaskInspectorSection.summary:
        return showSummary;
      case GanttTaskInspectorSection.editing:
        return showEditing;
      case GanttTaskInspectorSection.readiness:
        return showReadiness;
      case GanttTaskInspectorSection.relationships:
        return showRelationships;
      case GanttTaskInspectorSection.actions:
        return showActions;
    }
  }

  bool isCollapsible(GanttTaskInspectorSection section) {
    return collapsibleSections.contains(section);
  }

  bool isInitiallyCollapsed(GanttTaskInspectorSection section) {
    return initiallyCollapsedSections.contains(section);
  }

  GanttTaskInspectorSectionConfig copyWith({
    bool? showSummary,
    bool? showEditing,
    bool? showReadiness,
    bool? showRelationships,
    bool? showActions,
    Set<GanttTaskInspectorSection>? collapsibleSections,
    Set<GanttTaskInspectorSection>? initiallyCollapsedSections,
  }) {
    return GanttTaskInspectorSectionConfig(
      showSummary: showSummary ?? this.showSummary,
      showEditing: showEditing ?? this.showEditing,
      showReadiness: showReadiness ?? this.showReadiness,
      showRelationships: showRelationships ?? this.showRelationships,
      showActions: showActions ?? this.showActions,
      collapsibleSections: collapsibleSections ?? this.collapsibleSections,
      initiallyCollapsedSections:
          initiallyCollapsedSections ?? this.initiallyCollapsedSections,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is GanttTaskInspectorSectionConfig &&
            other.showSummary == showSummary &&
            other.showEditing == showEditing &&
            other.showReadiness == showReadiness &&
            other.showRelationships == showRelationships &&
            other.showActions == showActions &&
            setEquals(other.collapsibleSections, collapsibleSections) &&
            setEquals(
              other.initiallyCollapsedSections,
              initiallyCollapsedSections,
            );
  }

  @override
  int get hashCode => Object.hash(
    showSummary,
    showEditing,
    showReadiness,
    showRelationships,
    showActions,
    Object.hashAllUnordered(collapsibleSections),
    Object.hashAllUnordered(initiallyCollapsedSections),
  );
}
