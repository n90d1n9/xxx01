import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_personal_records_models.dart';
import 'employee_personal_records_styles.dart';

class EmployeePersonalRecordsSummaryStrip extends StatelessWidget {
  final EmployeePersonalRecordsProfile profile;

  const EmployeePersonalRecordsSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Addresses',
          value: '${profile.verifiedAddressCount}/${profile.addresses.length}',
        ),
        HrisMetricStripItem(
          label: 'Contacts',
          value:
              '${profile.verifiedContactCount}/${profile.emergencyContacts.length}',
        ),
        HrisMetricStripItem(
          label: 'Attention',
          value: '${profile.totalAttentionCount}',
        ),
        HrisMetricStripItem(
          label: 'Primary',
          value: profile.primaryContact?.relationship.label ?? 'None',
        ),
      ],
    );
  }
}

class EmployeeAddressRecordTile extends StatelessWidget {
  final EmployeeAddressRecord address;
  final DateTime asOfDate;
  final VoidCallback onVerify;

  const EmployeeAddressRecordTile({
    super.key,
    required this.address,
    required this.asOfDate,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final attention = address.needsAttention(asOfDate);
    final color =
        attention
            ? const Color(0xFFB45309)
            : employeePersonalRecordStatusColor(address.status);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(employeeAddressTypeIcon(address.type), color: color),
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
                        address.label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(label: address.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  address.singleLine,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      icon: Icons.public_outlined,
                      label: address.country,
                    ),
                    _MetaChip(
                      icon: Icons.event_available_outlined,
                      label:
                          'Verified ${DateFormat('MMM d').format(address.lastVerifiedAt)}',
                      color: attention ? const Color(0xFFB45309) : null,
                    ),
                    if (attention)
                      FilledButton.tonalIcon(
                        onPressed: onVerify,
                        icon: const Icon(Icons.verified_outlined),
                        label: const Text('Verify'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeEmergencyContactTile extends StatelessWidget {
  final EmployeeEmergencyContactRecord contact;
  final DateTime asOfDate;
  final VoidCallback onVerify;
  final VoidCallback onMakePrimary;

  const EmployeeEmergencyContactTile({
    super.key,
    required this.contact,
    required this.asOfDate,
    required this.onVerify,
    required this.onMakePrimary,
  });

  @override
  Widget build(BuildContext context) {
    final attention = contact.needsAttention(asOfDate);
    final color =
        attention
            ? const Color(0xFFB45309)
            : employeePersonalRecordStatusColor(contact.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeEmergencyRelationshipIcon(contact.relationship),
                  color: color,
                  size: 20,
                ),
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
                            contact.fullName,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        HrisStatusPill(
                          label:
                              contact.isPrimary
                                  ? 'Primary'
                                  : 'P${contact.priority}',
                          color: contact.isPrimary ? HrisColors.primary : color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.relationship.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.phone_outlined, label: contact.phone),
              if (contact.email.isNotEmpty)
                _MetaChip(icon: Icons.email_outlined, label: contact.email),
              _MetaChip(
                icon: Icons.event_available_outlined,
                label:
                    'Verified ${DateFormat('MMM d').format(contact.lastVerifiedAt)}',
                color: attention ? const Color(0xFFB45309) : null,
              ),
              if (attention)
                FilledButton.tonalIcon(
                  onPressed: onVerify,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Verify'),
                ),
              if (!contact.isPrimary)
                OutlinedButton.icon(
                  onPressed: onMakePrimary,
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Primary'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? HrisColors.muted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: resolvedColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: resolvedColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
