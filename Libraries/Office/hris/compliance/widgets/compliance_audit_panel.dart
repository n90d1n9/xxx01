import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/compliance_models.dart';
import 'compliance_status_styles.dart';

class ComplianceAuditPanel extends StatelessWidget {
  final List<AuditFinding> findings;

  const ComplianceAuditPanel({super.key, required this.findings});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.gpp_maybe_outlined,
      title: 'Audit Findings',
      subtitle: '${findings.length} findings',
      emptyMessage: 'No matching audit findings',
      children:
          findings.map((finding) => _FindingTile(finding: finding)).toList(),
    );
  }
}

class _FindingTile extends StatelessWidget {
  final AuditFinding finding;

  const _FindingTile({required this.finding});

  @override
  Widget build(BuildContext context) {
    final severityColor = findingSeverityColor(finding.severity);
    final formatter = DateFormat('MMM d');

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      finding.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${finding.department} - ${finding.ownerName} - due ${formatter.format(finding.dueDate)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              HrisStatusPill(
                label: findingSeverityLabel(finding.severity),
                color: severityColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            finding.remediation,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF374151)),
          ),
          const SizedBox(height: 10),
          HrisStatusPill(
            label: findingStatusLabel(finding.status),
            color: findingStatusColor(finding.status),
          ),
        ],
      ),
    );
  }
}
