import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_detail_section.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_detail_section_progress.dart';

void main() {
  test('dashboard action detail sections define workflow metadata', () {
    expect(
      DashboardActionDetailSection.values.map((section) => section.label),
      ['Overview', 'Evidence', 'Handoff', 'Impact', 'Playbook'],
    );
    expect(
      DashboardActionDetailSection.overview.icon,
      Icons.dashboard_customize_outlined,
    );
    expect(DashboardActionDetailSection.overview.previous, isNull);
    expect(
      DashboardActionDetailSection.overview.next,
      DashboardActionDetailSection.evidence,
    );
    expect(
      DashboardActionDetailSection.handoff.previous,
      DashboardActionDetailSection.evidence,
    );
    expect(
      DashboardActionDetailSection.handoff.next,
      DashboardActionDetailSection.impact,
    );
    expect(DashboardActionDetailSection.playbook.next, isNull);

    final progress = DashboardActionDetailSection.impact.progress;

    expect(progress.sectionLabel, 'Impact');
    expect(
      progress.ownerActionCue,
      'Confirm the impact target before closing the loop',
    );
    expect(progress.positionLabel, 'Section 4 of 5');
    expect(
      progress.actionLabel,
      'Do next: Confirm the impact target before closing the loop',
    );
    expect(
      DashboardActionDetailSection.overview.progress,
      DashboardActionDetailSectionProgress.initial,
    );
  });
}
