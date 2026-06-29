import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/holiday_audit_models.dart';
import 'holiday_formatters.dart';

class HolidayAuditTrailPanel extends StatelessWidget {
  final HolidayAuditSummary summary;

  const HolidayAuditTrailPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.manage_history_outlined,
      title: 'Calendar audit',
      subtitle: '${summary.totalCount} recorded changes',
      children: [
        _AuditSummarySurface(summary: summary),
        for (final entry in summary.entries) _AuditEntryTile(entry: entry),
      ],
    );
  }
}

class _AuditSummarySurface extends StatelessWidget {
  final HolidayAuditSummary summary;

  const _AuditSummarySurface({required this.summary});

  @override
  Widget build(BuildContext context) {
    final latestEntry = summary.latestEntry;

    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final headline = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: HrisColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${summary.totalCount}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: HrisColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.hasActivity ? 'Recent changes' : 'No activity',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: HrisColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    latestEntry == null
                        ? 'No recorded changes yet'
                        : '${latestEntry.action.label} by ${latestEntry.actor}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                  ),
                ],
              ),
            ],
          );

          final stats = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AuditStat(
                icon: Icons.add_circle_outline,
                label: 'Created',
                value: '${summary.createdCount}',
              ),
              _AuditStat(
                icon: Icons.edit_outlined,
                label: 'Updated',
                value: '${summary.updatedCount}',
              ),
              _AuditStat(
                icon: Icons.delete_outline,
                label: 'Removed',
                value: '${summary.deletedCount}',
              ),
              _AuditStat(
                icon: Icons.policy_outlined,
                label: 'Sensitive',
                value: '${summary.releaseSensitiveCount}',
              ),
            ],
          );

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [headline, const SizedBox(height: 14), stats],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              headline,
              const SizedBox(width: 20),
              Expanded(child: stats),
            ],
          );
        },
      ),
    );
  }
}

class _AuditStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AuditStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 118),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: HrisColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuditEntryTile extends StatelessWidget {
  final HolidayAuditEntry entry;

  const _AuditEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final heading = Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _actionColor(entry.action).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _actionIcon(entry.action),
                      color: _actionColor(entry.action),
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.holidayName,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          _formatAuditTimestamp(entry.recordedAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: HrisColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final pills = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  HrisStatusPill(
                    label: entry.action.label,
                    color: _actionColor(entry.action),
                  ),
                  HrisStatusPill(
                    label: entry.sensitivity.label,
                    color:
                        entry.isReleaseSensitive
                            ? Colors.orange.shade700
                            : Colors.blueGrey.shade700,
                  ),
                ],
              );

              if (constraints.maxWidth < 680) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [heading, const SizedBox(height: 10), pills],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 16),
                  Flexible(child: pills),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            entry.summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final detail in entry.details)
                HrisStatusPill(label: detail, color: HrisColors.primary),
            ],
          ),
        ],
      ),
    );
  }
}

Color _actionColor(HolidayAuditAction action) {
  return switch (action) {
    HolidayAuditAction.created => Colors.green.shade700,
    HolidayAuditAction.updated => HrisColors.primary,
    HolidayAuditAction.deleted => Colors.red.shade700,
  };
}

IconData _actionIcon(HolidayAuditAction action) {
  return switch (action) {
    HolidayAuditAction.created => Icons.add_circle_outline,
    HolidayAuditAction.updated => Icons.edit_outlined,
    HolidayAuditAction.deleted => Icons.delete_outline,
  };
}

String _formatAuditTimestamp(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${formatHolidayDate(value)} $hour:$minute';
}
