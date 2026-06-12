import 'package:flutter/material.dart';

import '../utils/billing_business_domain_pack_readiness.dart';

class BillingBusinessDomainPackReadinessIssueList extends StatelessWidget {
  final List<BillingBusinessDomainPackReadinessIssue> issues;
  final int hiddenIssueCount;

  const BillingBusinessDomainPackReadinessIssueList({
    super.key,
    required this.issues,
    this.hiddenIssueCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...issues.map((issue) => _PackIssueTile(issue: issue)),
        if (hiddenIssueCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$hiddenIssueCount more pack issues hidden',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PackIssueTile extends StatelessWidget {
  final BillingBusinessDomainPackReadinessIssue issue;

  const _PackIssueTile({required this.issue});

  @override
  Widget build(BuildContext context) {
    final visuals = _PackIssueVisuals.fromIssue(issue);
    final details = _issueDetails(issue);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(visuals.icon, color: visuals.color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visuals.label,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  issue.message,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                if (details != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    details,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackIssueVisuals {
  final String label;
  final IconData icon;
  final Color color;

  const _PackIssueVisuals({
    required this.label,
    required this.icon,
    required this.color,
  });

  factory _PackIssueVisuals.fromIssue(
    BillingBusinessDomainPackReadinessIssue issue,
  ) {
    return _PackIssueVisuals(
      label: _issueKindLabel(issue.kind),
      icon: issue.isBlocker ? Icons.error_outline : Icons.info_outline_rounded,
      color:
          issue.isBlocker ? const Color(0xFFDC2626) : const Color(0xFFD97706),
    );
  }
}

String _issueKindLabel(BillingBusinessDomainPackReadinessIssueKind kind) {
  switch (kind) {
    case BillingBusinessDomainPackReadinessIssueKind.missingDiagnosticsProfile:
      return 'Diagnostics profile';
    case BillingBusinessDomainPackReadinessIssueKind
        .missingReleaseWorkspaceProfile:
      return 'Release workspace';
    case BillingBusinessDomainPackReadinessIssueKind
        .missingReleaseProfileSavedViewProfile:
      return 'Release profile views';
    case BillingBusinessDomainPackReadinessIssueKind
        .missingReleaseGateLaneTarget:
      return 'Release gate target';
  }
}

String? _issueDetails(BillingBusinessDomainPackReadinessIssue issue) {
  if (issue.details.isEmpty) return null;

  final visibleDetails = issue.details
      .take(4)
      .map(_sentenceCaseName)
      .join(', ');
  final hiddenCount = issue.details.length - 4;
  if (hiddenCount <= 0) return visibleDetails;

  return '$visibleDetails and $hiddenCount more';
}

String _sentenceCaseName(String value) {
  final words =
      value
          .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) {
            return '${match.group(1)} ${match.group(2)}';
          })
          .replaceAll('_', ' ')
          .trim()
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .toList();

  if (words.isEmpty) return value;

  final normalizedWords = words.map((word) => word.toLowerCase()).toList();
  final first = normalizedWords.first;
  normalizedWords[0] = first.substring(0, 1).toUpperCase() + first.substring(1);

  return normalizedWords.join(' ');
}
