import '../models/accounting_policy_profile.dart';
import '../models/financial_report_pack.dart';
import '../models/financial_report_standard_transition.dart';

class FinancialReportStandardTransitionService {
  static final psak118EffectiveDate = DateTime(2027, 1, 1);
  static const currentStandardReference = 'PSAK 201 / IAS 1';
  static const nextStandardReference = 'PSAK 118 / IFRS 18';

  const FinancialReportStandardTransitionService();

  FinancialReportStandardTransitionSummary summarize({
    required FinancialReportPack pack,
    required AccountingPolicyProfile policy,
    required DateTime asOf,
  }) {
    final daysUntilEffective =
        _dateOnly(psak118EffectiveDate).difference(_dateOnly(asOf)).inDays;
    final inScope = _isInScope(policy.framework);
    final periodEnd = pack.periodEnd;
    final postEffective =
        daysUntilEffective <= 0 ||
        (periodEnd != null && !periodEnd.isBefore(psak118EffectiveDate));

    final items =
        inScope
            ? _inScopeItems(
              pack: pack,
              policy: policy,
              daysUntilEffective: daysUntilEffective,
              postEffective: postEffective,
            )
            : _outOfScopeItems(policy);

    final readyCount = _count(
      items,
      FinancialReportStandardTransitionStatus.ready,
    );
    final monitorCount = _count(
      items,
      FinancialReportStandardTransitionStatus.monitor,
    );
    final actionRequiredCount = _count(
      items,
      FinancialReportStandardTransitionStatus.actionRequired,
    );
    final overdueCount = _count(
      items,
      FinancialReportStandardTransitionStatus.overdue,
    );
    final notApplicableCount = _count(
      items,
      FinancialReportStandardTransitionStatus.notApplicable,
    );
    final applicableCount = items.length - notApplicableCount;

    return FinancialReportStandardTransitionSummary(
      currentStandardReference: currentStandardReference,
      nextStandardReference: nextStandardReference,
      effectiveDate: psak118EffectiveDate,
      daysUntilEffective: daysUntilEffective,
      items: List.unmodifiable(items),
      readyCount: readyCount,
      monitorCount: monitorCount,
      actionRequiredCount: actionRequiredCount,
      overdueCount: overdueCount,
      notApplicableCount: notApplicableCount,
      readinessRatio: applicableCount <= 0 ? 1 : readyCount / applicableCount,
      headline: _headline(
        inScope: inScope,
        monitorCount: monitorCount,
        actionRequiredCount: actionRequiredCount,
        overdueCount: overdueCount,
      ),
      nextAction: _nextAction(items),
    );
  }

  List<FinancialReportStandardTransitionItem> _inScopeItems({
    required FinancialReportPack pack,
    required AccountingPolicyProfile policy,
    required int daysUntilEffective,
    required bool postEffective,
  }) {
    final profitOrLoss = _statement(
      pack,
      FinancialReportStatementKind.profitOrLossAndOci,
    );
    final cashFlows = _statement(pack, FinancialReportStatementKind.cashFlows);
    final hasOperatingProfit = _hasLine(profitOrLoss, 'Operating profit');
    final hasBeforeFinancingAndTax = _hasLine(profitOrLoss, 'before financing');
    final hasFinanceClassification = _hasLine(profitOrLoss, 'Finance costs');
    final hasOperatingClassification = _hasLine(
      profitOrLoss,
      'Operating expenses',
    );
    final hasComparatives =
        pack.hasComparativePeriod &&
        pack.statements.any((statement) => statement.hasComparativeAmounts);
    final hasCashFlowBuckets =
        _hasLine(cashFlows, 'Net cash from operating activities') &&
        _hasLine(cashFlows, 'Net cash from investing activities') &&
        _hasLine(cashFlows, 'Net cash from financing activities');
    final hasPsak118Note = _hasNoteReference(pack, 'PSAK 118');
    final hasManagementPerformanceMeasureNote =
        _hasNoteReference(pack, 'UKTM') ||
        _hasNoteReference(pack, 'management performance') ||
        _hasNoteReference(pack, 'ukuran kinerja tetapan');
    final missingStatus = _missingStatus(
      postEffective: postEffective,
      daysUntilEffective: daysUntilEffective,
    );

    return [
      FinancialReportStandardTransitionItem(
        kind: FinancialReportStandardTransitionKind.effectiveStandard,
        title: 'PSAK 118 effective-date watch',
        status:
            postEffective
                ? FinancialReportStandardTransitionStatus.actionRequired
                : daysUntilEffective <= 365
                ? FinancialReportStandardTransitionStatus.monitor
                : FinancialReportStandardTransitionStatus.ready,
        metric:
            postEffective
                ? 'Effective now'
                : '$daysUntilEffective day(s) remaining',
        owner: 'Reporting lead',
        reference: '$nextStandardReference effective 2027-01-01',
        detail:
            postEffective
                ? 'Use the new presentation basis for reporting periods that start on or after the effective date.'
                : 'Track implementation work before PSAK 118 replaces PSAK 201.',
        evidenceReference: policy.framework.label,
      ),
      FinancialReportStandardTransitionItem(
        kind: FinancialReportStandardTransitionKind.profitLossSubtotals,
        title: 'Required profit or loss subtotals',
        status:
            hasOperatingProfit && hasBeforeFinancingAndTax
                ? FinancialReportStandardTransitionStatus.ready
                : missingStatus,
        metric:
            hasOperatingProfit && hasBeforeFinancingAndTax
                ? 'Subtotals mapped'
                : hasOperatingProfit
                ? 'Operating mapped'
                : 'Subtotal gap',
        owner: 'Reporting accountant',
        reference: nextStandardReference,
        detail:
            hasOperatingProfit && hasBeforeFinancingAndTax
                ? 'Operating and pre-financing/tax subtotal structure is visible.'
                : 'Add the PSAK 118 subtotal for profit before financing and income tax.',
        evidenceReference:
            hasOperatingProfit && hasBeforeFinancingAndTax
                ? 'PSAK 118 subtotals present'
                : hasOperatingProfit
                ? 'Operating profit present'
                : 'Not mapped',
      ),
      FinancialReportStandardTransitionItem(
        kind: FinancialReportStandardTransitionKind.incomeExpenseClassification,
        title: 'Income and expense classification taxonomy',
        status:
            hasOperatingClassification && hasFinanceClassification
                ? FinancialReportStandardTransitionStatus.ready
                : missingStatus,
        metric:
            hasOperatingClassification && hasFinanceClassification
                ? 'Operating/finance'
                : 'Classification gap',
        owner: 'Chart of accounts owner',
        reference: nextStandardReference,
        detail:
            hasOperatingClassification && hasFinanceClassification
                ? 'Operating and finance groupings are available for the statement layout.'
                : 'Map income and expenses into operating, investing, financing, tax, and discontinued-operation categories.',
        evidenceReference: 'P&L mapping',
      ),
      FinancialReportStandardTransitionItem(
        kind:
            FinancialReportStandardTransitionKind.managementPerformanceMeasures,
        title: 'UKTM / management performance measure disclosure',
        status:
            hasManagementPerformanceMeasureNote
                ? FinancialReportStandardTransitionStatus.ready
                : missingStatus,
        metric:
            hasManagementPerformanceMeasureNote
                ? 'Disclosure drafted'
                : 'Disclosure gap',
        owner: 'Finance director',
        reference: nextStandardReference,
        detail:
            hasManagementPerformanceMeasureNote
                ? 'Management-defined performance measure disclosure is documented.'
                : 'Document management performance measures, reconciliations, and responsible approval.',
        evidenceReference:
            hasManagementPerformanceMeasureNote ? 'UKTM note' : 'Not drafted',
      ),
      FinancialReportStandardTransitionItem(
        kind: FinancialReportStandardTransitionKind.comparativeTransition,
        title: 'Comparative presentation bridge',
        status:
            hasComparatives
                ? FinancialReportStandardTransitionStatus.ready
                : missingStatus,
        metric: hasComparatives ? 'Comparatives ready' : 'No comparative',
        owner: 'Controller',
        reference: nextStandardReference,
        detail:
            hasComparatives
                ? 'Comparative columns are available for transition review.'
                : 'Prepare comparative presentation mapping for the first PSAK 118 reporting period.',
        evidenceReference: pack.comparativePeriodLabel ?? 'Not configured',
      ),
      FinancialReportStandardTransitionItem(
        kind: FinancialReportStandardTransitionKind.cashFlowPresentation,
        title: 'Cash flow presentation impact',
        status:
            hasCashFlowBuckets
                ? FinancialReportStandardTransitionStatus.ready
                : missingStatus,
        metric: hasCashFlowBuckets ? 'Buckets mapped' : 'Cash flow gap',
        owner: 'Treasury / Cash accountant',
        reference: '$nextStandardReference / PSAK 207',
        detail:
            hasCashFlowBuckets
                ? 'Operating, investing, and financing cash flow buckets are visible.'
                : 'Review cash flow labels affected by PSAK 118 transition choices.',
        evidenceReference: 'Cash flow statement',
      ),
      FinancialReportStandardTransitionItem(
        kind: FinancialReportStandardTransitionKind.disclosureUpdate,
        title: 'PSAK 118 transition note',
        status:
            hasPsak118Note
                ? FinancialReportStandardTransitionStatus.ready
                : missingStatus,
        metric: hasPsak118Note ? 'Note present' : 'Note missing',
        owner: 'Disclosure owner',
        reference: nextStandardReference,
        detail:
            hasPsak118Note
                ? 'The report pack includes a PSAK 118 readiness note.'
                : 'Add a transition note explaining expected presentation changes and open implementation work.',
        evidenceReference:
            hasPsak118Note ? 'PSAK 118 readiness' : 'Not drafted',
      ),
    ];
  }

  List<FinancialReportStandardTransitionItem> _outOfScopeItems(
    AccountingPolicyProfile policy,
  ) {
    return [
      FinancialReportStandardTransitionItem(
        kind: FinancialReportStandardTransitionKind.effectiveStandard,
        title: 'PSAK 118 scope check',
        status: FinancialReportStandardTransitionStatus.notApplicable,
        metric: policy.framework.label,
        owner: 'Reporting lead',
        reference: nextStandardReference,
        detail:
            'The selected reporting framework is not treated as a PSAK 118 transition scope in this review.',
        evidenceReference: policy.standardReference,
      ),
    ];
  }

  FinancialReportStatement? _statement(
    FinancialReportPack pack,
    FinancialReportStatementKind kind,
  ) {
    for (final statement in pack.statements) {
      if (statement.kind == kind) {
        return statement;
      }
    }
    return null;
  }

  bool _hasLine(FinancialReportStatement? statement, String pattern) {
    if (statement == null) {
      return false;
    }
    final needle = pattern.toLowerCase();
    return statement.lines.any(
      (line) => line.label.toLowerCase().contains(needle),
    );
  }

  bool _hasNoteReference(FinancialReportPack pack, String pattern) {
    final needle = pattern.toLowerCase();
    return pack.notes.any((note) {
      return note.title.toLowerCase().contains(needle) ||
          note.body.toLowerCase().contains(needle) ||
          note.standardReferences.any(
            (reference) => reference.toLowerCase().contains(needle),
          );
    });
  }

  bool _isInScope(AccountingPolicyFramework framework) {
    switch (framework) {
      case AccountingPolicyFramework.sakIndonesia:
      case AccountingPolicyFramework.ifrs:
        return true;
      case AccountingPolicyFramework.sakEntitasPrivat:
      case AccountingPolicyFramework.sakEmkm:
        return false;
    }
  }

  FinancialReportStandardTransitionStatus _missingStatus({
    required bool postEffective,
    required int daysUntilEffective,
  }) {
    if (postEffective) {
      return FinancialReportStandardTransitionStatus.overdue;
    }
    if (daysUntilEffective <= 180) {
      return FinancialReportStandardTransitionStatus.actionRequired;
    }
    return FinancialReportStandardTransitionStatus.monitor;
  }

  int _count(
    List<FinancialReportStandardTransitionItem> items,
    FinancialReportStandardTransitionStatus status,
  ) {
    return items.where((item) => item.status == status).length;
  }

  String _headline({
    required bool inScope,
    required int monitorCount,
    required int actionRequiredCount,
    required int overdueCount,
  }) {
    if (!inScope) {
      return 'PSAK 118 transition is outside the selected framework scope.';
    }
    if (overdueCount > 0) {
      return 'PSAK 118 transition is overdue for this reporting context.';
    }
    if (actionRequiredCount > 0) {
      return 'PSAK 118 transition needs implementation work.';
    }
    if (monitorCount > 0) {
      return 'PSAK 118 transition is in monitoring.';
    }
    return 'PSAK 118 transition readiness is complete.';
  }

  String _nextAction(List<FinancialReportStandardTransitionItem> items) {
    final open =
        items
            .where(
              (item) =>
                  item.status !=
                      FinancialReportStandardTransitionStatus.ready &&
                  item.status !=
                      FinancialReportStandardTransitionStatus.notApplicable,
            )
            .toList()
          ..sort((a, b) {
            final rank = _statusRank(a.status).compareTo(_statusRank(b.status));
            if (rank != 0) {
              return rank;
            }
            return a.title.compareTo(b.title);
          });
    if (open.isEmpty) {
      return 'PSAK 118 transition readiness is complete for this pack.';
    }
    final next = open.first;
    return '${next.title}: ${next.detail}';
  }

  int _statusRank(FinancialReportStandardTransitionStatus status) {
    switch (status) {
      case FinancialReportStandardTransitionStatus.overdue:
        return 0;
      case FinancialReportStandardTransitionStatus.actionRequired:
        return 1;
      case FinancialReportStandardTransitionStatus.monitor:
        return 2;
      case FinancialReportStandardTransitionStatus.ready:
        return 3;
      case FinancialReportStandardTransitionStatus.notApplicable:
        return 4;
    }
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
