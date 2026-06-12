import 'dart:math' as math;

import 'package:intl/intl.dart';

import '../models/financial_report_disclosure_review.dart';
import '../models/financial_report_going_concern_review.dart';
import '../models/financial_report_pack.dart';
import '../models/financial_report_release_signoff.dart';

class FinancialReportGoingConcernReviewService {
  static const standardReference = 'PSAK 201 / IAS 1';

  const FinancialReportGoingConcernReviewService();

  FinancialReportGoingConcernReviewSummary summarize({
    required FinancialReportPack pack,
    required List<FinancialReportDisclosureReviewItem> disclosureReviewItems,
    required List<FinancialReportReleaseSignOffItem> signOffItems,
  }) {
    final totalAssets = _lineAmount(
      pack,
      FinancialReportStatementKind.financialPosition,
      'Total assets',
    );
    final totalLiabilities = _lineAmount(
      pack,
      FinancialReportStatementKind.financialPosition,
      'Total liabilities',
    );
    final totalEquity = _lineAmount(
      pack,
      FinancialReportStatementKind.financialPosition,
      'Total equity',
    );
    final cash = _lineAmount(
      pack,
      FinancialReportStatementKind.cashFlows,
      'Cash and cash equivalents at end of period',
    );
    final operatingCashFlow = _lineAmount(
      pack,
      FinancialReportStatementKind.cashFlows,
      'Net cash from operating activities',
    );
    final revenue = _lineAmount(
      pack,
      FinancialReportStatementKind.profitOrLossAndOci,
      'Total revenue',
    );
    final profitForPeriod = _lineAmount(
      pack,
      FinancialReportStatementKind.profitOrLossAndOci,
      'Profit (loss) for the period',
    );

    final items = [
      _liquidityBufferItem(cash, operatingCashFlow),
      _operatingPerformanceItem(revenue, profitForPeriod),
      _netAssetPositionItem(totalAssets, totalEquity),
      _operatingCashFlowItem(operatingCashFlow),
      _liabilitiesPressureItem(totalAssets, totalLiabilities),
      _managementAssessmentItem(
        disclosureReviewItems: disclosureReviewItems,
        signOffItems: signOffItems,
      ),
    ];

    final satisfactoryCount = _count(
      items,
      FinancialReportGoingConcernReviewStatus.satisfactory,
    );
    final watchCount = _count(
      items,
      FinancialReportGoingConcernReviewStatus.watch,
    );
    final attentionCount = _count(
      items,
      FinancialReportGoingConcernReviewStatus.attention,
    );
    final materialUncertaintyCount = _count(
      items,
      FinancialReportGoingConcernReviewStatus.materialUncertainty,
    );
    final incompleteCount = _count(
      items,
      FinancialReportGoingConcernReviewStatus.incomplete,
    );

    return FinancialReportGoingConcernReviewSummary(
      standardReference: standardReference,
      items: List.unmodifiable(items),
      satisfactoryCount: satisfactoryCount,
      watchCount: watchCount,
      attentionCount: attentionCount,
      materialUncertaintyCount: materialUncertaintyCount,
      incompleteCount: incompleteCount,
      readinessRatio: items.isEmpty ? 0 : satisfactoryCount / items.length,
      conclusion: _conclusion(
        materialUncertaintyCount: materialUncertaintyCount,
        attentionCount: attentionCount,
        incompleteCount: incompleteCount,
        watchCount: watchCount,
      ),
      nextAction: _nextAction(items),
    );
  }

  FinancialReportGoingConcernReviewItem _liquidityBufferItem(
    double cash,
    double operatingCashFlow,
  ) {
    final monthlyBurn = operatingCashFlow < 0 ? operatingCashFlow.abs() : 0.0;
    final runwayMonths =
        monthlyBurn == 0 ? double.infinity : cash / math.max(monthlyBurn, 1);
    final status =
        cash < 0
            ? FinancialReportGoingConcernReviewStatus.materialUncertainty
            : runwayMonths < 1
            ? FinancialReportGoingConcernReviewStatus.attention
            : runwayMonths < 3
            ? FinancialReportGoingConcernReviewStatus.watch
            : FinancialReportGoingConcernReviewStatus.satisfactory;
    return FinancialReportGoingConcernReviewItem(
      kind: FinancialReportGoingConcernReviewKind.liquidityBuffer,
      title: 'Cash runway and liquidity buffer',
      status: status,
      metric: monthlyBurn == 0 ? 'Positive cash cover' : _months(runwayMonths),
      owner: 'Treasury / Cash accountant',
      reference: '$standardReference / PSAK 207',
      detail:
          monthlyBurn == 0
              ? 'Cash balance is not being consumed by negative operating cash flow.'
              : 'Cash runway compares ending cash to current-period operating cash outflow.',
      evidenceReference: _money(cash),
    );
  }

  FinancialReportGoingConcernReviewItem _operatingPerformanceItem(
    double revenue,
    double profitForPeriod,
  ) {
    final margin =
        revenue.abs() < 0.01 ? null : profitForPeriod / revenue.abs();
    final status =
        profitForPeriod < 0 && (margin == null || margin < -0.1)
            ? FinancialReportGoingConcernReviewStatus.attention
            : profitForPeriod < 0
            ? FinancialReportGoingConcernReviewStatus.watch
            : FinancialReportGoingConcernReviewStatus.satisfactory;
    return FinancialReportGoingConcernReviewItem(
      kind: FinancialReportGoingConcernReviewKind.operatingPerformance,
      title: 'Profitability and loss trend',
      status: status,
      metric: margin == null ? _money(profitForPeriod) : _percent(margin),
      owner: 'Reporting accountant',
      reference: standardReference,
      detail:
          profitForPeriod < 0
              ? 'Current-period loss should be considered in management going-concern assessment.'
              : 'Current-period profit supports the going-concern basis.',
      evidenceReference: _money(profitForPeriod),
    );
  }

  FinancialReportGoingConcernReviewItem _netAssetPositionItem(
    double totalAssets,
    double totalEquity,
  ) {
    final equityRatio =
        totalAssets.abs() < 0.01 ? null : totalEquity / totalAssets.abs();
    final status =
        totalEquity < 0
            ? FinancialReportGoingConcernReviewStatus.materialUncertainty
            : equityRatio != null && equityRatio < 0.1
            ? FinancialReportGoingConcernReviewStatus.attention
            : equityRatio != null && equityRatio < 0.2
            ? FinancialReportGoingConcernReviewStatus.watch
            : FinancialReportGoingConcernReviewStatus.satisfactory;
    return FinancialReportGoingConcernReviewItem(
      kind: FinancialReportGoingConcernReviewKind.netAssetPosition,
      title: 'Net asset and capital buffer',
      status: status,
      metric: equityRatio == null ? _money(totalEquity) : _percent(equityRatio),
      owner: 'Controller',
      reference: '$standardReference / capital management',
      detail:
          totalEquity < 0
              ? 'Negative equity is a potential material uncertainty signal.'
              : 'Equity buffer is assessed against total assets.',
      evidenceReference: _money(totalEquity),
    );
  }

  FinancialReportGoingConcernReviewItem _operatingCashFlowItem(
    double operatingCashFlow,
  ) {
    final status =
        operatingCashFlow < 0
            ? FinancialReportGoingConcernReviewStatus.watch
            : FinancialReportGoingConcernReviewStatus.satisfactory;
    return FinancialReportGoingConcernReviewItem(
      kind: FinancialReportGoingConcernReviewKind.operatingCashFlow,
      title: 'Operating cash-flow support',
      status: status,
      metric: _money(operatingCashFlow),
      owner: 'Treasury / Cash accountant',
      reference: 'PSAK 207 / $standardReference',
      detail:
          operatingCashFlow < 0
              ? 'Negative operating cash flow should be explained in the going-concern assessment.'
              : 'Operating cash flow supports current trading activity.',
      evidenceReference: _money(operatingCashFlow),
    );
  }

  FinancialReportGoingConcernReviewItem _liabilitiesPressureItem(
    double totalAssets,
    double totalLiabilities,
  ) {
    final leverage =
        totalAssets.abs() < 0.01 ? null : totalLiabilities / totalAssets.abs();
    final status =
        leverage != null && leverage > 1
            ? FinancialReportGoingConcernReviewStatus.materialUncertainty
            : leverage != null && leverage > 0.8
            ? FinancialReportGoingConcernReviewStatus.attention
            : leverage != null && leverage > 0.6
            ? FinancialReportGoingConcernReviewStatus.watch
            : FinancialReportGoingConcernReviewStatus.satisfactory;
    return FinancialReportGoingConcernReviewItem(
      kind: FinancialReportGoingConcernReviewKind.liabilitiesPressure,
      title: 'Liabilities and solvency pressure',
      status: status,
      metric: leverage == null ? _money(totalLiabilities) : _percent(leverage),
      owner: 'Controller',
      reference: standardReference,
      detail:
          leverage != null && leverage > 0.8
              ? 'Liabilities are high relative to assets and need management evaluation.'
              : 'Liabilities remain within the configured review threshold.',
      evidenceReference: _money(totalLiabilities),
    );
  }

  FinancialReportGoingConcernReviewItem _managementAssessmentItem({
    required List<FinancialReportDisclosureReviewItem> disclosureReviewItems,
    required List<FinancialReportReleaseSignOffItem> signOffItems,
  }) {
    final managementAssertion = disclosureReviewItems.where(
      (item) => item.id == 'policy-management-assertions',
    );
    final assertionItem =
        managementAssertion.isEmpty ? null : managementAssertion.first;
    final approver = _signOffFor(
      signOffItems,
      FinancialReportReleaseSignOffRole.approver,
    );
    final complete =
        (assertionItem?.isResolved ?? false) && (approver?.isSigned ?? false);
    final blocked =
        (assertionItem?.isDeferred ?? false) || (approver?.isReturned ?? false);
    return FinancialReportGoingConcernReviewItem(
      kind: FinancialReportGoingConcernReviewKind.managementAssessment,
      title: 'Management going-concern conclusion',
      status:
          blocked
              ? FinancialReportGoingConcernReviewStatus.attention
              : complete
              ? FinancialReportGoingConcernReviewStatus.satisfactory
              : FinancialReportGoingConcernReviewStatus.incomplete,
      metric: complete ? 'Conclusion captured' : 'Conclusion pending',
      owner: approver?.requirement.owner ?? 'Finance director',
      reference: standardReference,
      detail:
          complete
              ? 'Management assertion and release approval support the going-concern basis.'
              : 'Capture management assertion and release approval before issuing the report pack.',
      evidenceReference:
          approver?.resolution?.evidenceReference ??
          assertionItem?.resolution?.evidenceReference ??
          '',
    );
  }

  FinancialReportReleaseSignOffItem? _signOffFor(
    List<FinancialReportReleaseSignOffItem> items,
    FinancialReportReleaseSignOffRole role,
  ) {
    for (final item in items) {
      if (item.role == role) {
        return item;
      }
    }
    return null;
  }

  double _lineAmount(
    FinancialReportPack pack,
    FinancialReportStatementKind kind,
    String label,
  ) {
    for (final statement in pack.statements) {
      if (statement.kind != kind) {
        continue;
      }
      for (final line in statement.lines) {
        if (line.label == label) {
          return line.amount ?? 0;
        }
      }
    }
    return 0;
  }

  int _count(
    List<FinancialReportGoingConcernReviewItem> items,
    FinancialReportGoingConcernReviewStatus status,
  ) {
    return items.where((item) => item.status == status).length;
  }

  String _conclusion({
    required int materialUncertaintyCount,
    required int attentionCount,
    required int incompleteCount,
    required int watchCount,
  }) {
    if (materialUncertaintyCount > 0) {
      return 'Material uncertainty indicators require management assessment.';
    }
    if (attentionCount > 0 || incompleteCount > 0) {
      return 'Going-concern conclusion needs management follow-up.';
    }
    if (watchCount > 0) {
      return 'Going-concern basis appears supportable with watch items.';
    }
    return 'Going-concern basis appears supportable.';
  }

  String _nextAction(List<FinancialReportGoingConcernReviewItem> items) {
    final open =
        items
            .where(
              (item) =>
                  item.status !=
                  FinancialReportGoingConcernReviewStatus.satisfactory,
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
      return 'Going-concern review is ready for report release.';
    }
    final next = open.first;
    return '${next.title}: ${next.detail}';
  }

  int _statusRank(FinancialReportGoingConcernReviewStatus status) {
    switch (status) {
      case FinancialReportGoingConcernReviewStatus.materialUncertainty:
        return 0;
      case FinancialReportGoingConcernReviewStatus.attention:
        return 1;
      case FinancialReportGoingConcernReviewStatus.incomplete:
        return 2;
      case FinancialReportGoingConcernReviewStatus.watch:
        return 3;
      case FinancialReportGoingConcernReviewStatus.satisfactory:
        return 4;
    }
  }

  String _money(double value) {
    return NumberFormat.compactCurrency(
      symbol: '',
      decimalDigits: 1,
    ).format(value).trim();
  }

  String _percent(double value) {
    return NumberFormat.percentPattern().format(value);
  }

  String _months(double value) {
    return '${value.isFinite ? value.toStringAsFixed(1) : '>12'} month(s)';
  }
}
