import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_identity_presentation_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';

void main() {
  group('GanttIdentityPresentationService', () {
    test('describes taskbar tooltip detail choices', () {
      final rich = ganttTaskBarTooltipDetailPresentation(
        GanttTaskBarTooltipDetail.rich,
      );
      final lean = ganttTaskBarTooltipDetailPresentation(
        GanttTaskBarTooltipDetail.lean,
      );
      final minimal = ganttTaskBarTooltipDetailPresentation(
        GanttTaskBarTooltipDetail.minimal,
      );

      expect(rich.label, 'Rich');
      expect(rich.summaryLabel, 'Rich shows full context');
      expect(rich.tooltip, contains('dependencies'));

      expect(lean.label, 'Lean');
      expect(lean.summaryLabel, 'Lean trims extras');
      expect(lean.tooltip, contains('duration and clip hints'));

      expect(minimal.label, 'Minimal');
      expect(minimal.summaryLabel, 'Minimal keeps it compact');
      expect(minimal.tooltip, contains('core task identity'));
      expect(
        ganttTaskBarTooltipDetailSettingsSubtitle(),
        'Rich shows full context, Lean trims extras, Minimal keeps it compact',
      );
    });

    test('describes avatar count choices', () {
      expect(ganttTeamAvatarCountPresentation(1).label, '1');
      expect(
        ganttTeamAvatarCountPresentation(1).tooltip,
        'Show only the first assigned teammate on each taskbar.',
      );
      expect(ganttTeamAvatarCountPresentation(5).label, '5');
      expect(
        ganttTeamAvatarCountPresentation(5).tooltip,
        'Show up to five assigned teammates on each taskbar.',
      );
      expect(
        ganttTeamAvatarCountSettingsSubtitle(),
        'Limit visible avatars from 1 to 5 teammates',
      );
    });

    test('describes avatar style choices', () {
      final compact = ganttTeamAvatarStylePresentation(
        GanttTeamAvatarStyle.compact,
      );
      final balanced = ganttTeamAvatarStylePresentation(
        GanttTeamAvatarStyle.balanced,
      );
      final prominent = ganttTeamAvatarStylePresentation(
        GanttTeamAvatarStyle.prominent,
      );

      expect(compact.label, 'Compact');
      expect(compact.summaryLabel, 'Compact saves space');
      expect(compact.tooltip, contains('narrower bars'));

      expect(balanced.label, 'Balanced');
      expect(balanced.summaryLabel, 'Balanced is standard');
      expect(balanced.tooltip, contains('without crowding'));

      expect(prominent.label, 'Prominent');
      expect(prominent.summaryLabel, 'Prominent highlights ownership');
      expect(prominent.tooltip, contains('team-first views'));
      expect(
        ganttTeamAvatarStyleSettingsSubtitle(),
        'Compact saves space, Balanced is standard, '
        'Prominent highlights ownership',
      );
    });
  });
}
