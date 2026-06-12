import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_detail_snapshot.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_evidence_timeline.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_handoff_brief.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_status.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_urgency.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  test('dashboard action detail derives rationale and evidence signals', () {
    final detail = hrisDashboardCriticalDetail(
      status: DashboardActionStatus.inProgress,
    );

    expect(detail.action.id, hrisDashboardCriticalActionId);
    expect(detail.status, DashboardActionStatus.inProgress);
    expect(detail.rationale, contains('Critical risk and total-risk pressure'));
    expect(detail.nextStep, contains('Open the linked workspace'));
    expect(detail.signals.map((signal) => signal.label), [
      'Critical',
      'Owner',
      'Due',
      'Priority',
    ]);
    expect(detail.signals.first.value, '5');
    expect(detail.impactEstimate.title, 'Critical risk exposure');
    expect(detail.impactEstimate.targetValue, 'Lower critical workspace count');
    expect(detail.impactEstimate.timeframe, hrisDashboardCriticalDueLabel);
    expect(detail.playbookSteps.map((step) => step.title), [
      'Confirm risk owner',
      'Sequence stabilization work',
      'Set review checkpoint',
    ]);
  });

  test('dashboard action detail snapshot summarizes decision context', () {
    final detail = hrisDashboardCriticalDetail(
      status: DashboardActionStatus.inProgress,
    );

    final snapshot = DashboardActionDetailSnapshot.fromDetail(detail);

    expect(snapshot.items.map((item) => item.kind), [
      DashboardActionDetailSnapshotKind.owner,
      DashboardActionDetailSnapshotKind.urgency,
      DashboardActionDetailSnapshotKind.status,
      DashboardActionDetailSnapshotKind.signal,
    ]);
    expect(snapshot.items[0].value, hrisDashboardCriticalOwnerLabel);
    expect(snapshot.items[1].value, 'Due now');
    expect(snapshot.items[1].urgency, DashboardActionUrgencyTier.now);
    expect(snapshot.items[2].value, 'In progress');
    expect(snapshot.items[2].helper, 'Work is moving');
    expect(snapshot.items[3].label, 'Critical');
    expect(snapshot.items[3].helper, 'Leadership escalation');
  });

  test('dashboard action evidence timeline derives checkpoints', () {
    final detail = hrisDashboardCriticalDetail(
      status: DashboardActionStatus.inProgress,
    );

    final timeline = DashboardActionEvidenceTimeline.fromDetail(detail);

    expect(timeline.events.map((event) => event.title), [
      'Signal captured',
      'Owner accountable',
      'Current playbook step',
      'Outcome check',
    ]);
    expect(timeline.events[0].state, DashboardActionEvidenceState.complete);
    expect(timeline.events[0].value, '5 Critical');
    expect(timeline.events[1].value, hrisDashboardCriticalOwnerLabel);
    expect(timeline.events[2].state, DashboardActionEvidenceState.current);
    expect(timeline.events[2].value, 'Sequence stabilization work');
    expect(timeline.events[3].state, DashboardActionEvidenceState.next);
    expect(timeline.events[3].value, 'Lower critical workspace count');
  });

  test('dashboard action handoff brief derives owner-ready lines', () {
    final detail = hrisDashboardCriticalDetail(
      status: DashboardActionStatus.inProgress,
    );

    final brief = DashboardActionHandoffBrief.fromDetail(detail);

    expect(brief.title, hrisDashboardCriticalActionTitle);
    expect(brief.lines.map((line) => line.kind), [
      DashboardActionHandoffKind.ownerAsk,
      DashboardActionHandoffKind.evidence,
      DashboardActionHandoffKind.review,
    ]);
    expect(brief.lines[0].value, hrisDashboardCriticalOwnerLabel);
    expect(brief.lines[0].description, contains('Open the linked workspace'));
    expect(brief.lines[1].value, '5 Critical');
    expect(brief.lines[1].description, contains('Keep attention'));
    expect(brief.lines[2].value, hrisDashboardCriticalDueLabel);
    expect(
      brief.lines[2].description,
      'Look for Lower critical workspace count.',
    );
    expect(
      brief.lines[0].clipboardText,
      contains('Owner ask: $hrisDashboardCriticalOwnerLabel'),
    );
    expect(
      brief.clipboardText,
      contains('Handoff: $hrisDashboardCriticalActionTitle'),
    );
    expect(brief.clipboardText, contains('Evidence to share: 5 Critical'));
  });
}
