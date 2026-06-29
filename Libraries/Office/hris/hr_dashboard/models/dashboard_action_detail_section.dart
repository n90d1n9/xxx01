import 'package:flutter/material.dart';

import 'dashboard_action_detail_section_progress.dart';

enum DashboardActionDetailSection {
  overview(
    label: 'Overview',
    icon: Icons.dashboard_customize_outlined,
    ownerActionCue: 'Confirm the owner, due window, and risk level',
  ),
  evidence(
    label: 'Evidence',
    icon: Icons.timeline_outlined,
    ownerActionCue: 'Share the evidence timeline with the accountable owner',
  ),
  handoff(
    label: 'Handoff',
    icon: Icons.ios_share_outlined,
    ownerActionCue: 'Copy the handoff brief into the owner follow-up',
  ),
  impact(
    label: 'Impact',
    icon: Icons.insights_outlined,
    ownerActionCue: 'Confirm the impact target before closing the loop',
  ),
  playbook(
    label: 'Playbook',
    icon: Icons.account_tree_outlined,
    ownerActionCue: 'Finish the active playbook step and capture the outcome',
  );

  final String label;
  final IconData icon;
  final String ownerActionCue;

  const DashboardActionDetailSection({
    required this.label,
    required this.icon,
    required this.ownerActionCue,
  });

  DashboardActionDetailSection? get previous {
    final previousIndex = index - 1;
    if (previousIndex < 0) {
      return null;
    }

    return DashboardActionDetailSection.values[previousIndex];
  }

  DashboardActionDetailSection? get next {
    final nextIndex = index + 1;
    if (nextIndex >= DashboardActionDetailSection.values.length) {
      return null;
    }

    return DashboardActionDetailSection.values[nextIndex];
  }

  DashboardActionDetailSectionProgress get progress =>
      DashboardActionDetailSectionProgress(
        sectionLabel: label,
        ownerActionCue: ownerActionCue,
        sectionIndex: index + 1,
        sectionCount: DashboardActionDetailSection.values.length,
      );
}
