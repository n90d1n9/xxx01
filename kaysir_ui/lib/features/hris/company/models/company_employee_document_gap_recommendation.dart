import 'company_employee_document_gap.dart';

enum CompanyEmployeeDocumentGapPriority { low, medium, high, critical }

extension CompanyEmployeeDocumentGapPriorityLabels
    on CompanyEmployeeDocumentGapPriority {
  String get label {
    switch (this) {
      case CompanyEmployeeDocumentGapPriority.low:
        return 'Low';
      case CompanyEmployeeDocumentGapPriority.medium:
        return 'Medium';
      case CompanyEmployeeDocumentGapPriority.high:
        return 'High';
      case CompanyEmployeeDocumentGapPriority.critical:
        return 'Critical';
    }
  }
}

class CompanyEmployeeDocumentGapRecommendation
    implements Comparable<CompanyEmployeeDocumentGapRecommendation> {
  final String gapId;
  final String employeeName;
  final CompanyEmployeeDocumentGapPriority priority;
  final int score;
  final int daysUntilDue;
  final String actionLabel;
  final String rationale;

  const CompanyEmployeeDocumentGapRecommendation({
    required this.gapId,
    required this.employeeName,
    required this.priority,
    required this.score,
    required this.daysUntilDue,
    required this.actionLabel,
    required this.rationale,
  });

  factory CompanyEmployeeDocumentGapRecommendation.fromGap({
    required CompanyEmployeeDocumentGap gap,
    required DateTime asOfDate,
  }) {
    final issues = gap.issues(asOfDate);
    final daysUntilDue = gap.daysUntilDue(asOfDate);
    final score = _scoreGap(
      gap: gap,
      issues: issues,
      daysUntilDue: daysUntilDue,
    );

    return CompanyEmployeeDocumentGapRecommendation(
      gapId: gap.id,
      employeeName: gap.employeeName,
      priority: _priorityForScore(score),
      score: score,
      daysUntilDue: daysUntilDue,
      actionLabel: _actionLabelFor(gap: gap, issues: issues),
      rationale: _rationaleFor(
        gap: gap,
        issues: issues,
        daysUntilDue: daysUntilDue,
      ),
    );
  }

  @override
  int compareTo(CompanyEmployeeDocumentGapRecommendation other) {
    final scoreComparison = other.score.compareTo(score);
    if (scoreComparison != 0) return scoreComparison;

    final dueComparison = daysUntilDue.compareTo(other.daysUntilDue);
    if (dueComparison != 0) return dueComparison;

    return employeeName.compareTo(other.employeeName);
  }
}

List<CompanyEmployeeDocumentGapRecommendation>
buildCompanyEmployeeDocumentGapRecommendations({
  required List<CompanyEmployeeDocumentGap> gaps,
  required DateTime asOfDate,
  int? limit,
}) {
  final recommendations =
      gaps
          .map(
            (gap) => CompanyEmployeeDocumentGapRecommendation.fromGap(
              gap: gap,
              asOfDate: asOfDate,
            ),
          )
          .toList()
        ..sort();

  if (limit == null || limit >= recommendations.length) {
    return recommendations;
  }

  return recommendations.take(limit).toList(growable: false);
}

int _scoreGap({
  required CompanyEmployeeDocumentGap gap,
  required List<CompanyEmployeeDocumentGapIssue> issues,
  required int daysUntilDue,
}) {
  if (gap.status == CompanyEmployeeDocumentGapStatus.complete ||
      gap.status == CompanyEmployeeDocumentGapStatus.waived) {
    return 0;
  }

  var score = 0;
  if (gap.status == CompanyEmployeeDocumentGapStatus.blocked) score += 30;

  if (daysUntilDue < 0) {
    score += 40;
  } else if (daysUntilDue == 0) {
    score += 35;
  } else if (daysUntilDue <= 3) {
    score += 30;
  } else if (daysUntilDue <= 7) {
    score += 20;
  } else if (daysUntilDue <= 14) {
    score += 12;
  }

  if (issues.contains(CompanyEmployeeDocumentGapIssue.missingRequirement)) {
    score += 25;
  }
  if (issues.contains(CompanyEmployeeDocumentGapIssue.missingOwner)) {
    score += 15;
  }
  if (issues.contains(CompanyEmployeeDocumentGapIssue.noOpenRequest)) {
    score += 20;
  } else if (gap.openRequestCount > 0) {
    score += 6;
  }
  if (gap.rejectedDocumentCount > 0) {
    score += 25 + (gap.rejectedDocumentCount * 5).clamp(0, 15).toInt();
  }

  score += (gap.missingDocumentCount * 4).clamp(0, 24).toInt();
  score += (gap.pendingDocumentCount * 3).clamp(0, 12).toInt();

  return score;
}

CompanyEmployeeDocumentGapPriority _priorityForScore(int score) {
  if (score >= 85) return CompanyEmployeeDocumentGapPriority.critical;
  if (score >= 55) return CompanyEmployeeDocumentGapPriority.high;
  if (score >= 25) return CompanyEmployeeDocumentGapPriority.medium;
  return CompanyEmployeeDocumentGapPriority.low;
}

String _actionLabelFor({
  required CompanyEmployeeDocumentGap gap,
  required List<CompanyEmployeeDocumentGapIssue> issues,
}) {
  if (gap.status == CompanyEmployeeDocumentGapStatus.complete ||
      gap.status == CompanyEmployeeDocumentGapStatus.waived) {
    return 'No action needed';
  }
  if (issues.contains(CompanyEmployeeDocumentGapIssue.missingRequirement)) {
    return 'Map requirement';
  }
  if (issues.contains(CompanyEmployeeDocumentGapIssue.missingOwner)) {
    return 'Assign owner';
  }
  if (issues.contains(CompanyEmployeeDocumentGapIssue.rejectedEvidence)) {
    return 'Review rejected evidence';
  }
  if (issues.contains(CompanyEmployeeDocumentGapIssue.noOpenRequest)) {
    return 'Generate request';
  }
  if (issues.contains(CompanyEmployeeDocumentGapIssue.overdue) &&
      gap.openRequestCount > 0) {
    return 'Escalate overdue request';
  }
  if (issues.contains(CompanyEmployeeDocumentGapIssue.dueSoon) &&
      gap.openRequestCount > 0) {
    return 'Follow up request';
  }
  if (gap.pendingDocumentCount > 0) return 'Verify pending evidence';
  if (gap.openRequestCount > 0) return 'Monitor request';
  return 'Review evidence';
}

String _rationaleFor({
  required CompanyEmployeeDocumentGap gap,
  required List<CompanyEmployeeDocumentGapIssue> issues,
  required int daysUntilDue,
}) {
  if (gap.status == CompanyEmployeeDocumentGapStatus.complete) {
    return 'Evidence requirement is complete.';
  }
  if (gap.status == CompanyEmployeeDocumentGapStatus.waived) {
    return 'Evidence requirement is waived.';
  }

  final parts = <String>[];
  if (daysUntilDue < 0) {
    parts.add('overdue by ${daysUntilDue.abs()}d');
  } else if (daysUntilDue == 0) {
    parts.add('due today');
  } else {
    parts.add('due in ${daysUntilDue}d');
  }
  if (gap.missingDocumentCount > 0) {
    parts.add('${gap.missingDocumentCount} missing');
  }
  if (gap.pendingDocumentCount > 0) {
    parts.add('${gap.pendingDocumentCount} pending');
  }
  if (gap.rejectedDocumentCount > 0) {
    parts.add('${gap.rejectedDocumentCount} rejected');
  }
  if (gap.openRequestCount > 0) {
    parts.add(
      '${gap.openRequestCount} open request'
      '${gap.openRequestCount == 1 ? '' : 's'}',
    );
  }
  if (issues.contains(CompanyEmployeeDocumentGapIssue.noOpenRequest)) {
    parts.add('no open request');
  }
  if (issues.contains(CompanyEmployeeDocumentGapIssue.missingOwner)) {
    parts.add('owner missing');
  }
  if (issues.contains(CompanyEmployeeDocumentGapIssue.missingRequirement)) {
    parts.add('requirement missing');
  }

  return parts.join(', ');
}
