import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_close_command_center.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_period_close_execution.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_close_readiness.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_owner_summary.dart';
import 'package:kaysir/features/finance/accounting/services/accounting_workspace_period_close_execution_service.dart';

void main() {
  group('AccountingWorkspacePeriodCloseExecutionService', () {
    const service = AccountingWorkspacePeriodCloseExecutionService();

    test('maps blocked close gates into a blocked lock execution', () {
      final execution = service.summarize(
        commandCenter: _commandCenter(
          state: AccountingWorkspaceCloseCommandCenterState.blocked,
          gateChecks: const [
            AccountingWorkspaceCloseCommandCenterGateCheck(
              id: 'blockers',
              label: 'Blockers',
              status: AccountingWorkspaceCloseCommandCenterGateStatus.blocked,
              statusLabel: 'Blocked',
              detailLabel: '5 blockers before lock',
            ),
            AccountingWorkspaceCloseCommandCenterGateCheck(
              id: 'evidence',
              label: 'Evidence',
              status: AccountingWorkspaceCloseCommandCenterGateStatus.watch,
              statusLabel: 'Watch',
              detailLabel: '2 owner follow-ups',
            ),
            AccountingWorkspaceCloseCommandCenterGateCheck(
              id: 'posting',
              label: 'Posting',
              status: AccountingWorkspaceCloseCommandCenterGateStatus.clear,
              statusLabel: 'Clear',
              detailLabel: 'No posting gate',
            ),
          ],
        ),
        closeReadiness: _closeReadiness(releaseBlockerItems: 5),
        ownerSummary: _ownerSummary(),
      );

      expect(execution.statusLabel, 'Lock blocked');
      expect(execution.primaryActionLabel, 'Open blocker workflow');
      expect(execution.reviewActionLabel, 'Review next close gate');
      expect(execution.attentionLabel, 'Blockers: 5 blockers before lock');
      expect(execution.ownerHandoff?.ownerLabel, 'Audit liaison');
      expect(execution.ownerHandoff?.riskLabel, '4 critical');
      expect(execution.ownerHandoff?.loadLabel, '2 queues · 8 items');
      expect(
        execution.ownerHandoff?.handoffBrief,
        contains('Close owner handoff: Audit liaison'),
      );
      expect(
        execution.ownerHandoff?.handoffBrief,
        contains('Requested action: Review owner queue before period lock.'),
      );
      expect(execution.progressLabel, '78% ready');
      expect(
        execution.steps.firstWhere((step) => step.id == 'blockers').status,
        AccountingWorkspacePeriodCloseExecutionStepStatus.blocked,
      );
      expect(
        execution.steps.firstWhere((step) => step.id == 'posting').status,
        AccountingWorkspacePeriodCloseExecutionStepStatus.complete,
      );
      expect(
        execution.executionBrief,
        contains('Period close execution: Lock blocked (78% ready)'),
      );
      expect(
        execution.executionBrief,
        contains(
          'Owner handoff: Audit liaison - 4 critical - 2 queues · 8 items',
        ),
      );
    });

    test('marks lock approval active when the command center is ready', () {
      final execution = service.summarize(
        commandCenter: _commandCenter(
          state: AccountingWorkspaceCloseCommandCenterState.ready,
          decisionLabel: 'Ready for lock review',
          decisionDetailLabel: 'No active blockers',
          gateChecks: const [
            AccountingWorkspaceCloseCommandCenterGateCheck(
              id: 'blockers',
              label: 'Blockers',
              status: AccountingWorkspaceCloseCommandCenterGateStatus.clear,
              statusLabel: 'Clear',
              detailLabel: 'No release blockers',
            ),
            AccountingWorkspaceCloseCommandCenterGateCheck(
              id: 'evidence',
              label: 'Evidence',
              status: AccountingWorkspaceCloseCommandCenterGateStatus.clear,
              statusLabel: 'Clear',
              detailLabel: 'Evidence clear',
            ),
            AccountingWorkspaceCloseCommandCenterGateCheck(
              id: 'posting',
              label: 'Posting',
              status: AccountingWorkspaceCloseCommandCenterGateStatus.clear,
              statusLabel: 'Clear',
              detailLabel: 'No posting gate',
            ),
          ],
        ),
        closeReadiness: _closeReadiness(),
        ownerSummary: const AccountingWorkspaceWorkQueueOwnerSummary(
          owners: [],
        ),
      );

      expect(execution.statusLabel, 'Ready for lock workflow');
      expect(execution.primaryActionLabel, 'Open lock workflow');
      expect(
        execution.attentionLabel,
        'No active gate blockers in workspace queues',
      );
      expect(execution.ownerHandoff, isNull);
      expect(execution.stepSummaryLabel, '3/4 steps');
      expect(
        execution.steps.firstWhere((step) => step.id == 'lock-approval').status,
        AccountingWorkspacePeriodCloseExecutionStepStatus.active,
      );
    });
  });
}

AccountingWorkspaceWorkQueueOwnerSummary _ownerSummary() {
  return const AccountingWorkspaceWorkQueueOwnerSummary(
    owners: [
      AccountingWorkspaceWorkQueueOwnerLoad(
        ownerLabel: 'Audit liaison',
        queueCount: 2,
        totalItems: 8,
        overdueItems: 3,
        dueTodayItems: 1,
        onTrackItems: 4,
        criticalItems: 4,
        worstOverdueDays: 2,
      ),
    ],
  );
}

AccountingWorkspaceCloseCommandCenter _commandCenter({
  required AccountingWorkspaceCloseCommandCenterState state,
  String decisionLabel = 'Lock blocked',
  String decisionDetailLabel = '5 blockers before lock',
  List<AccountingWorkspaceCloseCommandCenterGateCheck> gateChecks = const [],
}) {
  return AccountingWorkspaceCloseCommandCenter(
    state: state,
    hasQueues: true,
    decisionLabel: decisionLabel,
    readinessLabel: '78% ready',
    decisionDetailLabel: decisionDetailLabel,
    primaryActionLabel: 'Clear release blockers before close',
    openValueLabel: '12',
    openDetailLabel: '5 blocked',
    evidenceValueLabel: '2',
    evidenceDetailLabel: '2 owner follow-ups',
    postingValueLabel: '0',
    postingDetailLabel: 'No posting gate',
    ownerValueLabel: 'Audit liaison',
    ownerDetailLabel: '5 overdue',
    nextActionLabel: '#1 Critical overdue',
    nextActionQueueId: 'controller-close-blockers',
    gateChecks: gateChecks,
  );
}

AccountingWorkspaceWorkQueueCloseReadiness _closeReadiness({
  int releaseBlockerItems = 0,
  int evidenceRequestItems = 0,
  int postingGateItems = 0,
}) {
  return AccountingWorkspaceWorkQueueCloseReadiness(
    queueCount: 3,
    totalItems: 10,
    releaseBlockerItems: releaseBlockerItems,
    evidenceRequestItems: evidenceRequestItems,
    postingGateItems: postingGateItems,
  );
}
