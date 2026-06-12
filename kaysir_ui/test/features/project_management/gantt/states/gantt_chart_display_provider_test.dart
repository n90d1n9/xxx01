import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  group('GanttChartDisplayPreferences', () {
    test('maps taskbar depth into package shadow options', () {
      final subtle =
          GanttChartDisplayPreferences.initial
              .copyWith(taskBarDepth: GanttTaskBarDepth.subtle)
              .kyOptions
              .taskBarShadow;
      final balanced =
          GanttChartDisplayPreferences.initial.kyOptions.taskBarShadow;
      final elevated =
          GanttChartDisplayPreferences.initial
              .copyWith(taskBarDepth: GanttTaskBarDepth.elevated)
              .kyOptions
              .taskBarShadow;

      expect(subtle.opacityScale, 0.62);
      expect(subtle.blurScale, 0.78);
      expect(subtle.offsetScale, 0.72);

      expect(balanced.opacityScale, 1);
      expect(balanced.blurScale, 1);
      expect(balanced.offsetScale, 1);

      expect(elevated.opacityScale, 1.28);
      expect(elevated.blurScale, 1.24);
      expect(elevated.offsetScale, 1.18);
    });

    test('maps team avatar style into package avatar options', () {
      final compact =
          GanttChartDisplayPreferences.initial
              .copyWith(teamAvatarStyle: GanttTeamAvatarStyle.compact)
              .kyOptions
              .taskBarAvatar;
      final balanced =
          GanttChartDisplayPreferences.initial.kyOptions.taskBarAvatar;
      final prominent =
          GanttChartDisplayPreferences.initial
              .copyWith(teamAvatarStyle: GanttTeamAvatarStyle.prominent)
              .kyOptions
              .taskBarAvatar;

      expect(compact.size, 18);
      expect(compact.overlap, 7);
      expect(compact.minTaskBarWidth, 96);

      expect(balanced.size, 22);
      expect(balanced.overlap, 8);
      expect(balanced.minTaskBarWidth, 112);

      expect(prominent.size, 26);
      expect(prominent.overlap, 10);
      expect(prominent.minTaskBarWidth, 128);
    });

    test('maps timeline accent intensity into package timeline options', () {
      final subtle =
          GanttChartDisplayPreferences.initial
              .copyWith(
                timelineAccentIntensity: GanttTimelineAccentIntensity.subtle,
              )
              .kyOptions;
      final balanced = GanttChartDisplayPreferences.initial.kyOptions;
      final strong =
          GanttChartDisplayPreferences.initial
              .copyWith(
                timelineAccentIntensity: GanttTimelineAccentIntensity.strong,
              )
              .kyOptions;

      expect(subtle.weekendBandOpacity, 0.24);
      expect(subtle.todayIndicatorOpacity, 0.08);
      expect(subtle.todayMarkerOpacity, 0.56);

      expect(balanced.weekendBandOpacity, 0.5);
      expect(balanced.todayIndicatorOpacity, 0.14);
      expect(balanced.todayMarkerOpacity, 1);

      expect(strong.weekendBandOpacity, 0.72);
      expect(strong.todayIndicatorOpacity, 0.22);
      expect(strong.todayMarkerOpacity, 1);
    });

    test('maps selected row emphasis into package highlight opacity', () {
      final subtle =
          GanttChartDisplayPreferences.initial
              .copyWith(
                showSelectedTaskRowHighlight: false,
                selectedTaskRowEmphasis: GanttSelectedTaskRowEmphasis.subtle,
              )
              .kyOptions;
      final balanced = GanttChartDisplayPreferences.initial.kyOptions;
      final strong =
          GanttChartDisplayPreferences.initial
              .copyWith(
                selectedTaskRowEmphasis: GanttSelectedTaskRowEmphasis.strong,
              )
              .kyOptions;

      expect(subtle.showSelectedTaskRowHighlight, isFalse);
      expect(subtle.selectedTaskRowHighlightOpacity, 0.04);
      expect(balanced.selectedTaskRowHighlightOpacity, 0.08);
      expect(strong.selectedTaskRowHighlightOpacity, 0.14);
    });

    test('maps dependency line intensity into package line options', () {
      final subtle =
          GanttChartDisplayPreferences.initial
              .copyWith(
                showDependencyLines: false,
                highlightSelectedDependencies: false,
                showTaskBarDependencyConflictBadges: false,
                dependencyFocusScope: KyGanttDependencyLineFocusScope.direct,
                dependencyLineIntensity: GanttDependencyLineIntensity.subtle,
              )
              .kyOptions
              .dependencyLines;
      final balanced =
          GanttChartDisplayPreferences.initial.kyOptions.dependencyLines;
      final strong =
          GanttChartDisplayPreferences.initial
              .copyWith(
                dependencyFocusScope: KyGanttDependencyLineFocusScope.upstream,
                dependencyLineIntensity: GanttDependencyLineIntensity.strong,
              )
              .kyOptions
              .dependencyLines;

      expect(subtle.visible, isFalse);
      expect(subtle.highlightSelectedTask, isFalse);
      expect(subtle.highlightRelatedTaskBars, isFalse);
      expect(subtle.highlightConflictedDependencies, isFalse);
      expect(subtle.focusScope, KyGanttDependencyLineFocusScope.direct);
      expect(subtle.lineOpacity, 0.38);
      expect(subtle.inactiveLineOpacity, 0.08);
      expect(subtle.strokeWidth, 1.2);
      expect(subtle.highlightStrokeWidth, 1.8);

      expect(balanced.visible, isTrue);
      expect(balanced.highlightSelectedTask, isTrue);
      expect(balanced.focusScope, KyGanttDependencyLineFocusScope.chain);
      expect(balanced.lineOpacity, 0.62);
      expect(balanced.strokeWidth, 1.6);

      expect(strong.lineOpacity, 0.78);
      expect(strong.focusScope, KyGanttDependencyLineFocusScope.upstream);
      expect(strong.inactiveLineOpacity, 0.22);
      expect(strong.highlightLineOpacity, 1);
      expect(strong.conflictLineOpacity, 1);
      expect(strong.strokeWidth, 2);
      expect(strong.highlightStrokeWidth, 3);
      expect(strong.conflictStrokeWidth, 2.8);
    });

    test('maps schedule badge style into package badge options', () {
      final full =
          GanttChartDisplayPreferences.initial.kyOptions.taskBarScheduleBadge;
      final marker =
          GanttChartDisplayPreferences.initial
              .copyWith(
                taskBarScheduleBadgeStyle:
                    GanttTaskBarScheduleBadgeStyle.marker,
              )
              .kyOptions
              .taskBarScheduleBadge;
      final text =
          GanttChartDisplayPreferences.initial
              .copyWith(
                taskBarScheduleBadgeStyle: GanttTaskBarScheduleBadgeStyle.text,
              )
              .kyOptions
              .taskBarScheduleBadge;
      final hidden =
          GanttChartDisplayPreferences.initial
              .copyWith(
                showTaskBarScheduleBadges: false,
                taskBarScheduleBadgeStyle: GanttTaskBarScheduleBadgeStyle.full,
              )
              .kyOptions
              .taskBarScheduleBadge;

      expect(full.visible, isTrue);
      expect(full.showAccent, isTrue);
      expect(full.showLabel, isTrue);

      expect(marker.visible, isTrue);
      expect(marker.showAccent, isTrue);
      expect(marker.showLabel, isFalse);

      expect(text.visible, isTrue);
      expect(text.showAccent, isFalse);
      expect(text.showLabel, isTrue);

      expect(hidden.visible, isFalse);
      expect(hidden.showAccent, isTrue);
      expect(hidden.showLabel, isTrue);
    });

    test('maps tooltip detail into package tooltip options', () {
      final rich =
          GanttChartDisplayPreferences.initial.kyOptions.taskBarTooltip;
      final lean =
          GanttChartDisplayPreferences.initial
              .copyWith(taskBarTooltipDetail: GanttTaskBarTooltipDetail.lean)
              .kyOptions
              .taskBarTooltip;
      final minimal =
          GanttChartDisplayPreferences.initial
              .copyWith(taskBarTooltipDetail: GanttTaskBarTooltipDetail.minimal)
              .kyOptions
              .taskBarTooltip;
      final hidden =
          GanttChartDisplayPreferences.initial
              .copyWith(
                showTaskBarTooltips: false,
                taskBarTooltipDetail: GanttTaskBarTooltipDetail.rich,
              )
              .kyOptions
              .taskBarTooltip;

      expect(rich.visible, isTrue);
      expect(rich.showDuration, isTrue);
      expect(rich.showAssignees, isTrue);
      expect(rich.showClipHints, isTrue);

      expect(lean.visible, isTrue);
      expect(lean.showStatus, isTrue);
      expect(lean.showProgress, isTrue);
      expect(lean.showDateRange, isTrue);
      expect(lean.showDependency, isTrue);
      expect(lean.showAssignees, isTrue);
      expect(lean.showDuration, isFalse);
      expect(lean.showClipHints, isFalse);

      expect(minimal.visible, isTrue);
      expect(minimal.showProgress, isTrue);
      expect(minimal.showDateRange, isTrue);
      expect(minimal.showStatus, isFalse);
      expect(minimal.showDuration, isFalse);
      expect(minimal.showDependency, isFalse);
      expect(minimal.showAssignees, isFalse);
      expect(minimal.showClipHints, isFalse);

      expect(hidden.visible, isFalse);
      expect(hidden.showDuration, isTrue);
    });
  });
}
