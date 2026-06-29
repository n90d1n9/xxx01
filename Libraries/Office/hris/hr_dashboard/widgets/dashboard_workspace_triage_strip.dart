import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_analytics.dart';
import '../models/dashboard_workspace_triage_summary.dart';
import 'dashboard_risk_severity_summary.dart' show dashboardRiskSeverityColor;
import 'dashboard_workspace_triage_tile.dart';

class DashboardWorkspaceTriageStrip extends StatelessWidget {
  final DashboardWorkspaceTriageSummary summary;
  final VoidCallback? onRiskPressureTap;
  final VoidCallback? onTimeSensitiveTap;
  final VoidCallback? onNextFocusTap;

  const DashboardWorkspaceTriageStrip({
    super.key,
    required this.summary,
    this.onRiskPressureTap,
    this.onTimeSensitiveTap,
    this.onNextFocusTap,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = _tiles();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HrisColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 760) {
            return Column(
              children:
                  tiles
                      .map(
                        (tile) => Padding(
                          padding: EdgeInsets.only(
                            bottom: tile == tiles.last ? 0 : 12,
                          ),
                          child: tile,
                        ),
                      )
                      .toList(),
            );
          }

          return IntrinsicHeight(
            child: Row(
              children:
                  tiles
                      .expand(
                        (tile) => [
                          Expanded(child: tile),
                          if (tile != tiles.last)
                            const VerticalDivider(
                              width: 20,
                              color: HrisColors.border,
                            ),
                        ],
                      )
                      .toList(),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _tiles() {
    final criticalColor = dashboardRiskSeverityColor(
      DashboardRiskSeverity.critical,
    );
    final elevatedColor = dashboardRiskSeverityColor(
      DashboardRiskSeverity.elevated,
    );
    final timeColor =
        summary.timeSensitiveRisks > 0 ? elevatedColor : Colors.green[700]!;
    final focusColor = summary.nextFocus?.color ?? Colors.green[700]!;

    return [
      DashboardWorkspaceTriageTile(
        icon: Icons.dashboard_customize_outlined,
        label: 'In view',
        value: '${summary.workspaceCount}',
        detail: summary.attentionLabel,
        color: HrisColors.primary,
      ),
      DashboardWorkspaceTriageTile(
        icon: Icons.priority_high_rounded,
        label: 'Risk pressure',
        value: summary.criticalLabel,
        detail: summary.elevatedLabel,
        color: criticalColor,
        tooltip: 'Show highest risk pressure',
        onTap: onRiskPressureTap,
      ),
      DashboardWorkspaceTriageTile(
        icon: Icons.schedule_outlined,
        label: 'Time-sensitive',
        value: summary.timeSensitiveLabel,
        detail: summary.totalRiskLabel,
        color: timeColor,
        tooltip: 'Show attention queue',
        onTap: onTimeSensitiveTap,
      ),
      DashboardWorkspaceTriageTile(
        icon: Icons.track_changes_outlined,
        label: 'Next focus',
        value: 'Next focus: ${summary.nextFocusLabel}',
        detail: summary.nextFocusDetail,
        color: focusColor,
        tooltip: 'Show next focus queue',
        onTap: onNextFocusTap,
      ),
    ];
  }
}
