import 'company_employee_document_gap.dart';
import 'company_employee_document_gap_recommendation.dart';

class CompanyEmployeeDocumentWorkload
    implements Comparable<CompanyEmployeeDocumentWorkload> {
  final String ownerName;
  final List<String> entityNames;
  final List<String> gapIds;
  final int score;
  final int gapCount;
  final int criticalCount;
  final int highCount;
  final int overdueCount;
  final int dueSoonCount;
  final int openRequestCount;
  final int missingDocumentCount;
  final int pendingDocumentCount;
  final int rejectedDocumentCount;
  final String primaryAction;
  final String primaryGapId;
  final String primaryEmployeeName;

  const CompanyEmployeeDocumentWorkload({
    required this.ownerName,
    required this.entityNames,
    required this.gapIds,
    required this.score,
    required this.gapCount,
    required this.criticalCount,
    required this.highCount,
    required this.overdueCount,
    required this.dueSoonCount,
    required this.openRequestCount,
    required this.missingDocumentCount,
    required this.pendingDocumentCount,
    required this.rejectedDocumentCount,
    required this.primaryAction,
    required this.primaryGapId,
    required this.primaryEmployeeName,
  });

  String get entitySummary {
    if (entityNames.isEmpty) return 'No entity';
    if (entityNames.length == 1) return entityNames.single;
    return '${entityNames.length} entities';
  }

  bool get requiresEscalation => criticalCount > 0 || overdueCount > 0;

  @override
  int compareTo(CompanyEmployeeDocumentWorkload other) {
    final scoreComparison = other.score.compareTo(score);
    if (scoreComparison != 0) return scoreComparison;

    final criticalComparison = other.criticalCount.compareTo(criticalCount);
    if (criticalComparison != 0) return criticalComparison;

    final overdueComparison = other.overdueCount.compareTo(overdueCount);
    if (overdueComparison != 0) return overdueComparison;

    return ownerName.compareTo(other.ownerName);
  }
}

List<CompanyEmployeeDocumentWorkload> buildCompanyEmployeeDocumentWorkloads({
  required List<CompanyEmployeeDocumentGap> gaps,
  required List<CompanyEmployeeDocumentGapRecommendation> recommendations,
  required DateTime asOfDate,
  int? limit,
}) {
  final recommendationsByGapId = {
    for (final recommendation in recommendations)
      recommendation.gapId: recommendation,
  };
  final builders = <String, _CompanyEmployeeDocumentWorkloadBuilder>{};

  for (final gap in gaps) {
    final ownerName =
        gap.ownerName.trim().isEmpty ? 'Unassigned' : gap.ownerName.trim();
    final builder = builders.putIfAbsent(
      ownerName,
      () => _CompanyEmployeeDocumentWorkloadBuilder(ownerName),
    );
    builder.add(
      gap: gap,
      recommendation:
          recommendationsByGapId[gap.id] ??
          CompanyEmployeeDocumentGapRecommendation.fromGap(
            gap: gap,
            asOfDate: asOfDate,
          ),
      asOfDate: asOfDate,
    );
  }

  final workloads =
      builders.values.map((builder) => builder.build()).toList()..sort();

  if (limit == null || limit >= workloads.length) return workloads;
  return workloads.take(limit).toList(growable: false);
}

class _CompanyEmployeeDocumentWorkloadBuilder {
  final String ownerName;
  final Set<String> entityNames = {};
  final List<String> gapIds = [];
  int score = 0;
  int criticalCount = 0;
  int highCount = 0;
  int overdueCount = 0;
  int dueSoonCount = 0;
  int openRequestCount = 0;
  int missingDocumentCount = 0;
  int pendingDocumentCount = 0;
  int rejectedDocumentCount = 0;
  CompanyEmployeeDocumentGapRecommendation? topRecommendation;

  _CompanyEmployeeDocumentWorkloadBuilder(this.ownerName);

  void add({
    required CompanyEmployeeDocumentGap gap,
    required CompanyEmployeeDocumentGapRecommendation recommendation,
    required DateTime asOfDate,
  }) {
    final issues = gap.issues(asOfDate);
    entityNames.add(gap.entityName);
    gapIds.add(gap.id);
    score += recommendation.score;
    if (recommendation.priority ==
        CompanyEmployeeDocumentGapPriority.critical) {
      criticalCount++;
    }
    if (recommendation.priority == CompanyEmployeeDocumentGapPriority.high) {
      highCount++;
    }
    if (issues.contains(CompanyEmployeeDocumentGapIssue.overdue)) {
      overdueCount++;
    }
    if (issues.contains(CompanyEmployeeDocumentGapIssue.dueSoon)) {
      dueSoonCount++;
    }
    openRequestCount += gap.openRequestCount;
    missingDocumentCount += gap.missingDocumentCount;
    pendingDocumentCount += gap.pendingDocumentCount;
    rejectedDocumentCount += gap.rejectedDocumentCount;

    final currentTop = topRecommendation;
    if (currentTop == null || recommendation.compareTo(currentTop) < 0) {
      topRecommendation = recommendation;
    }
  }

  CompanyEmployeeDocumentWorkload build() {
    final sortedEntities = entityNames.toList()..sort();
    final top = topRecommendation;
    return CompanyEmployeeDocumentWorkload(
      ownerName: ownerName,
      entityNames: sortedEntities,
      gapIds: [...gapIds],
      score: score,
      gapCount: gapIds.length,
      criticalCount: criticalCount,
      highCount: highCount,
      overdueCount: overdueCount,
      dueSoonCount: dueSoonCount,
      openRequestCount: openRequestCount,
      missingDocumentCount: missingDocumentCount,
      pendingDocumentCount: pendingDocumentCount,
      rejectedDocumentCount: rejectedDocumentCount,
      primaryAction: top?.actionLabel ?? 'Review evidence',
      primaryGapId: top?.gapId ?? '',
      primaryEmployeeName: top?.employeeName ?? '',
    );
  }
}
