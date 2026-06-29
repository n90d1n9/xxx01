import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_org_unit.dart';
import 'company_status_styles.dart';

class CompanyOrgStructurePanel extends StatelessWidget {
  final List<CompanyOrgUnit> units;

  const CompanyOrgStructurePanel({super.key, required this.units});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.schema_outlined,
      title: 'Organization Structure',
      subtitle: '${units.length} mapped units',
      emptyMessage: 'No matching organization units',
      children: units.map((unit) => _OrgUnitTile(unit: unit)).toList(),
    );
  }
}

class _OrgUnitTile extends StatelessWidget {
  final CompanyOrgUnit unit;

  const _OrgUnitTile({required this.unit});

  @override
  Widget build(BuildContext context) {
    final statusColor = companyOrgUnitStatusColor(unit.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${unit.name} (${unit.code})',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: unit.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${unit.entityName} - ${unit.location}',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Manager', value: unit.managerName),
              HrisMetricStripItem(
                label: 'Active',
                value: '${unit.activeHeadcount}',
              ),
              HrisMetricStripItem(
                label: 'Planned',
                value: '${unit.plannedHeadcount}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: unit.staffingRatio,
            color: statusColor,
            label:
                '${(unit.staffingRatio * 100).clamp(0, 125).round()}% staffing coverage',
          ),
          if (unit.issues.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  unit.issues
                      .map(
                        (issue) => HrisStatusPill(
                          label: issue.label,
                          color: Colors.orange,
                        ),
                      )
                      .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
