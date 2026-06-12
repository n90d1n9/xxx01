import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_exception_event.dart';
import 'package:kaysir/features/finance/billing/models/exception_relief_plan.dart';
import 'package:kaysir/features/finance/billing/models/relief_application_packet.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';
import 'package:kaysir/features/finance/billing/utils/exception_relief_planner.dart';
import 'package:kaysir/features/finance/billing/utils/relief_application_packet_builder.dart';

void main() {
  test('buildBillingExceptionReliefApplicationPacket builds ready packets', () {
    final packet = buildBillingExceptionReliefApplicationPacket(
      plan: _readyReliefPlan(),
      requestedBy: 'Ops lead',
      requestedAt: DateTime.utc(2026, 1, 15, 9),
    );

    expect(packet.isReady, isTrue);
    expect(packet.statusLabel, 'Ready');
    expect(packet.commandCount, 4);
    expect(packet.auditFactCount, 6);
    expect(packet.summaryLabel, '4 relief commands ready for force majeure.');
    expect(
      packet.commands.map((command) => command.actionKind),
      contains(BillingExceptionReliefActionKind.pauseDueDates),
    );
    expect(packet.packetKey, 'forceMajeure:12:42600.00:21:4:ops lead');
  });

  test('buildBillingExceptionReliefApplicationPacket normalizes requester', () {
    final packet = buildBillingExceptionReliefApplicationPacket(
      plan: _readyReliefPlan(),
      requestedBy: '   ',
      requestedAt: DateTime.utc(2026, 1, 15, 9),
    );

    expect(packet.requestedBy, 'System');
  });

  test(
    'buildBillingExceptionReliefApplicationPacket blocks unresolved plans',
    () {
      final packet = buildBillingExceptionReliefApplicationPacket(
        plan: planBillingExceptionRelief(
          config: constructionBillingPolicyConfig(),
          kind: BillingExceptionEventKind.forceMajeure,
          affectedInvoiceCount: 12,
          openAmount: 42600,
          reliefDurationDays: 21,
          evidenceCaptured: true,
        ),
        requestedBy: 'Ops lead',
        requestedAt: DateTime.utc(2026, 1, 15, 9),
      );

      expect(packet.isReady, isFalse);
      expect(packet.statusLabel, 'Blocked');
      expect(packet.commands, isEmpty);
      expect(
        packet.hasIssueKind(
          BillingExceptionReliefApplicationIssueKind.planNotActionable,
        ),
        isTrue,
      );
      expect(
        packet.issues.map((issue) => issue.message),
        contains('Approval must be granted before relief is applied.'),
      );
    },
  );

  test(
    'buildBillingExceptionReliefApplicationPacket exposes command payloads',
    () {
      final packet = buildBillingExceptionReliefApplicationPacket(
        plan: _readyReliefPlan(),
        requestedBy: 'Ops lead',
        requestedAt: DateTime.utc(2026, 1, 15, 9),
      );
      final command = packet.commands.firstWhere(
        (command) =>
            command.actionKind ==
            BillingExceptionReliefActionKind.pauseDueDates,
      );

      expect(command.id, 'forceMajeure-pauseDueDates');
      expect(command.payload['exceptionKind'], 'forceMajeure');
      expect(command.payload['affectedInvoiceCount'], 12);
      expect(command.payload['openAmount'], 42600);
      expect(command.payload['reliefDurationDays'], 21);
      expect(command.payload['approvalGranted'], isTrue);
      expect(command.payload['evidenceCaptured'], isTrue);
    },
  );
}

BillingExceptionReliefPlan _readyReliefPlan() {
  return planBillingExceptionRelief(
    config: constructionBillingPolicyConfig(),
    kind: BillingExceptionEventKind.forceMajeure,
    affectedInvoiceCount: 12,
    openAmount: 42600,
    reliefDurationDays: 21,
    approvalGranted: true,
    evidenceCaptured: true,
  );
}
