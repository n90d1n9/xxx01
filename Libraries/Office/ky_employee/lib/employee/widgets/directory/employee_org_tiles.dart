import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_org_models.dart';
import 'employee_org_styles.dart';

class EmployeeOrgSummaryStrip extends StatelessWidget {
  final EmployeeOrgProfile profile;

  const EmployeeOrgSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Manager',
          value: profile.manager == null ? 'None' : '1',
        ),
        HrisMetricStripItem(
          label: 'Reports',
          value: '${profile.directReportCount}',
        ),
        HrisMetricStripItem(label: 'Peers', value: '${profile.peerCount}'),
        HrisMetricStripItem(label: 'Risks', value: '${profile.riskCount}'),
      ],
    );
  }
}

class EmployeeOrgManagerCard extends StatelessWidget {
  final EmployeeOrgProfile profile;

  const EmployeeOrgManagerCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final manager = profile.manager;

    return HrisListSurface(
      child:
          manager == null
              ? Text(
                'No manager is assigned.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EmployeeOrgPersonRow(
                    person: manager,
                    titlePrefix: 'Manager',
                    trailing:
                        manager.watchlist
                            ? const HrisStatusPill(
                              label: 'Watchlist',
                              color: Color(0xFFB91C1C),
                            )
                            : null,
                  ),
                  if (profile.chain.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Chain: ${profile.chain.map((person) => person.name).join(' -> ')}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HrisColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
    );
  }
}

class EmployeeOrgPersonRow extends StatelessWidget {
  final EmployeeOrgPerson person;
  final String? titlePrefix;
  final Widget? trailing;

  const EmployeeOrgPersonRow({
    super.key,
    required this.person,
    this.titlePrefix,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        person.watchlist ? const Color(0xFFB91C1C) : HrisColors.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.person_outline, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titlePrefix == null
                    ? person.name
                    : '$titlePrefix: ${person.name}',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${person.position} - ${person.department}',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class EmployeeOrgPeopleCard extends StatelessWidget {
  final String title;
  final List<EmployeeOrgPerson> people;
  final String emptyMessage;

  const EmployeeOrgPeopleCard({
    super.key,
    required this.title,
    required this.people,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (people.isEmpty)
            Text(
              emptyMessage,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            )
          else
            ..._spacedPeople(people),
        ],
      ),
    );
  }

  List<Widget> _spacedPeople(List<EmployeeOrgPerson> people) {
    final widgets = <Widget>[];
    for (var index = 0; index < people.length; index++) {
      if (index > 0) widgets.add(const SizedBox(height: 10));
      widgets.add(EmployeeOrgPersonRow(person: people[index]));
    }
    return widgets;
  }
}

class EmployeeOrgRiskTile extends StatelessWidget {
  final EmployeeOrgRiskSignal risk;
  final VoidCallback onAcknowledge;

  const EmployeeOrgRiskTile({
    super.key,
    required this.risk,
    required this.onAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeeOrgRiskColor(risk.type);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(employeeOrgRiskIcon(risk.type), color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        risk.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(label: risk.type.label, color: color),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  risk.detail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: onAcknowledge,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Acknowledge'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeOrgRelationshipTile extends StatelessWidget {
  final EmployeeOrgRelationshipRecord relationship;
  final VoidCallback onActivate;
  final VoidCallback onArchive;

  const EmployeeOrgRelationshipTile({
    super.key,
    required this.relationship,
    required this.onActivate,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeeOrgRelationshipStatusColor(relationship.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeOrgRelationshipTypeIcon(relationship.type),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      relationship.relatedEmployeeName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      relationship.type.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: relationship.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            relationship.reason,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.ink),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(
                  icon: Icons.person_outline,
                  label: relationship.owner,
                ),
                _MetaChip(
                  icon: Icons.event_outlined,
                  label: DateFormat('MMM d').format(relationship.createdAt),
                ),
                if (relationship.canActivate)
                  FilledButton.tonalIcon(
                    onPressed: onActivate,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Activate'),
                  ),
                if (relationship.status !=
                    EmployeeOrgRelationshipStatus.archived)
                  OutlinedButton.icon(
                    onPressed: onArchive,
                    icon: const Icon(Icons.archive_outlined),
                    label: const Text('Archive'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: HrisColors.muted),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: HrisColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
