import '../models/financial_close_checklist.dart';
import '../models/financial_period_close.dart';
import '../models/financial_period_close_audit.dart';
import '../models/financial_period_close_workflow.dart';
import '../models/period_closing_entry.dart';

class FinancialPeriodCloseWorkflowService {
  const FinancialPeriodCloseWorkflowService();

  FinancialPeriodCloseWorkflowSnapshot build({
    required String periodLabel,
    required DateTime? periodStart,
    required DateTime? periodEnd,
    required FinancialCloseChecklist checklist,
    required PeriodClosingEntryPreview closingEntryPreview,
    required bool closingEntryPosted,
    required FinancialPeriodCloseRecord? closeRecord,
    required List<FinancialPeriodCloseAuditEvent> auditTrail,
  }) {
    final hasBoundedPeriod = periodStart != null && periodEnd != null;
    final isClosed = closeRecord?.status == FinancialPeriodCloseStatus.closed;
    final isReopened =
        closeRecord?.status == FinancialPeriodCloseStatus.reopened;
    final closingEntryRequired = closingEntryPreview.hasNominalActivity;
    final canPostClosingEntry =
        hasBoundedPeriod &&
        !isClosed &&
        closingEntryRequired &&
        !closingEntryPosted &&
        closingEntryPreview.canPost;
    final canClosePeriod =
        hasBoundedPeriod &&
        !isClosed &&
        !checklist.hasBlockers &&
        (!closingEntryRequired || closingEntryPosted);

    final steps = [
      _periodStep(hasBoundedPeriod),
      _checklistStep(checklist, hasBoundedPeriod, isClosed),
      _closingEntryStep(
        hasBoundedPeriod: hasBoundedPeriod,
        isClosed: isClosed,
        closingEntryRequired: closingEntryRequired,
        closingEntryPosted: closingEntryPosted,
        closingEntryPreview: closingEntryPreview,
      ),
      _closeStep(
        hasBoundedPeriod: hasBoundedPeriod,
        isClosed: isClosed,
        checklist: checklist,
        closingEntryRequired: closingEntryRequired,
        closingEntryPosted: closingEntryPosted,
      ),
      _archiveStep(isClosed, auditTrail),
    ];

    return FinancialPeriodCloseWorkflowSnapshot(
      periodLabel: periodLabel,
      hasBoundedPeriod: hasBoundedPeriod,
      isClosed: isClosed,
      isReopened: isReopened,
      closingEntryRequired: closingEntryRequired,
      closingEntryPosted: closingEntryPosted,
      canPostClosingEntry: canPostClosingEntry,
      canClosePeriod: canClosePeriod,
      canReopenPeriod: isClosed,
      readinessRatio: checklist.readinessRatio,
      blockerCount: checklist.blockedCount,
      reviewCount: checklist.reviewCount,
      auditEventCount: auditTrail.length,
      steps: steps,
      attentionItems: _attentionItems(
        hasBoundedPeriod: hasBoundedPeriod,
        isClosed: isClosed,
        isReopened: isReopened,
        checklist: checklist,
        closingEntryRequired: closingEntryRequired,
        closingEntryPosted: closingEntryPosted,
        closingEntryPreview: closingEntryPreview,
        canPostClosingEntry: canPostClosingEntry,
        canClosePeriod: canClosePeriod,
        auditTrail: auditTrail,
      ),
    );
  }

  FinancialPeriodCloseWorkflowStep _periodStep(bool hasBoundedPeriod) {
    return FinancialPeriodCloseWorkflowStep(
      id: 'period',
      title: 'Select bounded period',
      description:
          hasBoundedPeriod
              ? 'The close run has a fixed start and end date.'
              : 'Choose a month, quarter, year, or custom range before closing.',
      status:
          hasBoundedPeriod
              ? FinancialPeriodCloseWorkflowStepStatus.complete
              : FinancialPeriodCloseWorkflowStepStatus.blocked,
      reference: 'Period',
      isBlocking: !hasBoundedPeriod,
    );
  }

  FinancialPeriodCloseWorkflowStep _checklistStep(
    FinancialCloseChecklist checklist,
    bool hasBoundedPeriod,
    bool isClosed,
  ) {
    if (isClosed) {
      return const FinancialPeriodCloseWorkflowStep(
        id: 'checklist',
        title: 'Resolve close checklist',
        description: 'Checklist was accepted when the period was closed.',
        status: FinancialPeriodCloseWorkflowStepStatus.complete,
        reference: 'Checklist',
      );
    }

    if (!hasBoundedPeriod) {
      return const FinancialPeriodCloseWorkflowStep(
        id: 'checklist',
        title: 'Resolve close checklist',
        description:
            'Checklist review starts after a bounded period is chosen.',
        status: FinancialPeriodCloseWorkflowStepStatus.queued,
        reference: 'Checklist',
      );
    }

    if (checklist.hasBlockers) {
      return FinancialPeriodCloseWorkflowStep(
        id: 'checklist',
        title: 'Resolve close checklist',
        description:
            '${checklist.blockedCount} blocker(s) remain before final close.',
        status: FinancialPeriodCloseWorkflowStepStatus.blocked,
        reference: 'Checklist',
        isBlocking: true,
      );
    }

    if (checklist.reviewCount > 0) {
      return FinancialPeriodCloseWorkflowStep(
        id: 'checklist',
        title: 'Resolve close checklist',
        description:
            '${checklist.reviewCount} review item(s) remain, but no hard blockers are open.',
        status: FinancialPeriodCloseWorkflowStepStatus.active,
        reference: 'Checklist',
      );
    }

    return const FinancialPeriodCloseWorkflowStep(
      id: 'checklist',
      title: 'Resolve close checklist',
      description: 'All close checks are ready.',
      status: FinancialPeriodCloseWorkflowStepStatus.complete,
      reference: 'Checklist',
    );
  }

  FinancialPeriodCloseWorkflowStep _closingEntryStep({
    required bool hasBoundedPeriod,
    required bool isClosed,
    required bool closingEntryRequired,
    required bool closingEntryPosted,
    required PeriodClosingEntryPreview closingEntryPreview,
  }) {
    if (!closingEntryRequired) {
      return const FinancialPeriodCloseWorkflowStep(
        id: 'closing-entry',
        title: 'Post closing entry',
        description: 'No nominal account activity requires a closing entry.',
        status: FinancialPeriodCloseWorkflowStepStatus.complete,
        reference: 'Closing entry',
      );
    }

    if (closingEntryPosted || isClosed) {
      return const FinancialPeriodCloseWorkflowStep(
        id: 'closing-entry',
        title: 'Post closing entry',
        description: 'Closing entry is posted and linked as close evidence.',
        status: FinancialPeriodCloseWorkflowStepStatus.complete,
        reference: 'Closing entry',
      );
    }

    if (!hasBoundedPeriod) {
      return const FinancialPeriodCloseWorkflowStep(
        id: 'closing-entry',
        title: 'Post closing entry',
        description: 'Closing entry preview waits for a bounded period.',
        status: FinancialPeriodCloseWorkflowStepStatus.queued,
        reference: 'Closing entry',
      );
    }

    if (closingEntryPreview.canPost) {
      return const FinancialPeriodCloseWorkflowStep(
        id: 'closing-entry',
        title: 'Post closing entry',
        description: 'Draft closing entry is balanced and ready to post.',
        status: FinancialPeriodCloseWorkflowStepStatus.active,
        reference: 'Closing entry',
      );
    }

    return FinancialPeriodCloseWorkflowStep(
      id: 'closing-entry',
      title: 'Post closing entry',
      description:
          closingEntryPreview.warnings.isEmpty
              ? 'Closing entry draft is not balanced yet.'
              : closingEntryPreview.warnings.first,
      status: FinancialPeriodCloseWorkflowStepStatus.blocked,
      reference: 'Closing entry',
      isBlocking: true,
    );
  }

  FinancialPeriodCloseWorkflowStep _closeStep({
    required bool hasBoundedPeriod,
    required bool isClosed,
    required FinancialCloseChecklist checklist,
    required bool closingEntryRequired,
    required bool closingEntryPosted,
  }) {
    if (isClosed) {
      return const FinancialPeriodCloseWorkflowStep(
        id: 'close',
        title: 'Lock period',
        description: 'Period is closed and guarded from further postings.',
        status: FinancialPeriodCloseWorkflowStepStatus.complete,
        reference: 'Close',
      );
    }

    final closingEntryMissing = closingEntryRequired && !closingEntryPosted;
    if (!hasBoundedPeriod || checklist.hasBlockers || closingEntryMissing) {
      final reason =
          !hasBoundedPeriod
              ? 'Select a bounded period before locking.'
              : checklist.hasBlockers
              ? 'Clear close blockers before locking.'
              : 'Post the closing entry before locking.';
      return FinancialPeriodCloseWorkflowStep(
        id: 'close',
        title: 'Lock period',
        description: reason,
        status: FinancialPeriodCloseWorkflowStepStatus.queued,
        reference: 'Close',
        isBlocking: true,
      );
    }

    return const FinancialPeriodCloseWorkflowStep(
      id: 'close',
      title: 'Lock period',
      description: 'Checklist and closing entry are ready for period close.',
      status: FinancialPeriodCloseWorkflowStepStatus.active,
      reference: 'Close',
    );
  }

  FinancialPeriodCloseWorkflowStep _archiveStep(
    bool isClosed,
    List<FinancialPeriodCloseAuditEvent> auditTrail,
  ) {
    return FinancialPeriodCloseWorkflowStep(
      id: 'archive',
      title: 'Archive evidence trail',
      description:
          isClosed
              ? 'Close record and ${auditTrail.length} audit event(s) are retained.'
              : 'Archive is completed when the period is locked.',
      status:
          isClosed
              ? FinancialPeriodCloseWorkflowStepStatus.complete
              : FinancialPeriodCloseWorkflowStepStatus.queued,
      reference: 'Audit',
    );
  }

  List<String> _attentionItems({
    required bool hasBoundedPeriod,
    required bool isClosed,
    required bool isReopened,
    required FinancialCloseChecklist checklist,
    required bool closingEntryRequired,
    required bool closingEntryPosted,
    required PeriodClosingEntryPreview closingEntryPreview,
    required bool canPostClosingEntry,
    required bool canClosePeriod,
    required List<FinancialPeriodCloseAuditEvent> auditTrail,
  }) {
    final items = <String>[];

    if (!hasBoundedPeriod) {
      items.add('Select a bounded period before posting or locking the close.');
    }
    if (isClosed) {
      items.add('Period is locked. Reopen with a reason before changing data.');
    }
    if (isReopened) {
      items.add('Period was reopened. Re-close after late adjustments finish.');
    }
    if (checklist.hasBlockers) {
      items.add('${checklist.blockedCount} close blocker(s) require action.');
    }
    if (closingEntryRequired && !closingEntryPosted) {
      items.add(
        canPostClosingEntry
            ? 'Balanced closing entry is ready to post.'
            : 'Closing entry is required before the period can be locked.',
      );
    }
    items.addAll(closingEntryPreview.warnings);
    if (canClosePeriod) {
      items.add('Period is ready for final close approval.');
    }
    if (auditTrail.isNotEmpty) {
      items.add('${auditTrail.length} close audit event(s) are available.');
    }

    if (items.isEmpty) {
      items.add('No close workflow issues detected for this period.');
    }

    return items;
  }
}
