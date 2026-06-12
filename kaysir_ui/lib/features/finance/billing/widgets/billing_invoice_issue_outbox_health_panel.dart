import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_invoice_issue_outbox_health.dart';
import '../states/billing_invoice_issue_outbox_provider.dart';

class BillingInvoiceIssueOutboxHealthSection extends ConsumerWidget {
  final String tenantId;
  final VoidCallback? onInspect;

  const BillingInvoiceIssueOutboxHealthSection({
    super.key,
    required this.tenantId,
    this.onInspect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(
      billingInvoiceIssueOutboxHealthProvider(tenantId),
    );
    final syncState = ref.watch(
      billingInvoiceIssueOutboxSyncControllerProvider,
    );

    return healthAsync.when(
      loading:
          () => const _IssueOutboxHealthFrame(
            child: SizedBox(
              height: 112,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      error:
          (error, stack) => const _IssueOutboxHealthFrame(
            child: SizedBox(
              height: 112,
              child: Center(child: Text('Unable to load issue sync')),
            ),
          ),
      data:
          (health) => BillingInvoiceIssueOutboxHealthPanel(
            health: health,
            isSyncing: syncState.isLoading,
            onInspect: onInspect,
            onSyncNow:
                !health.canSyncNow || syncState.isLoading
                    ? null
                    : () => ref
                        .read(
                          billingInvoiceIssueOutboxSyncControllerProvider
                              .notifier,
                        )
                        .sync(tenantId: tenantId),
          ),
    );
  }
}

class BillingInvoiceIssueOutboxHealthPanel extends StatelessWidget {
  final BillingInvoiceIssueOutboxHealth health;
  final bool isSyncing;
  final VoidCallback? onSyncNow;
  final VoidCallback? onInspect;

  const BillingInvoiceIssueOutboxHealthPanel({
    super.key,
    required this.health,
    this.isSyncing = false,
    this.onSyncNow,
    this.onInspect,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _IssueOutboxHealthVisuals.fromHealth(health);
    final supportingText = _supportingText(context, health);

    return _IssueOutboxHealthFrame(
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
                  color: visuals.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(visuals.icon, color: visuals.color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Issue sync',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      visuals.headline,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      supportingText,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              BillingInvoiceIssueOutboxHealthBadge(health: health),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 640;
              final tiles = [
                _IssueOutboxMetricTile(
                  label: 'Ready',
                  value: '${health.retryableNowCount}',
                  icon: Icons.sync_outlined,
                  color: const Color(0xFF2563EB),
                ),
                _IssueOutboxMetricTile(
                  label: 'Waiting',
                  value: '${health.deferredRetryCount}',
                  icon: Icons.schedule_outlined,
                  color: const Color(0xFFD97706),
                ),
                _IssueOutboxMetricTile(
                  label: 'Exhausted',
                  value: '${health.exhaustedCount}',
                  icon: Icons.error_outline,
                  color: const Color(0xFFDC2626),
                ),
                _IssueOutboxMetricTile(
                  label: 'Synced',
                  value: '${health.syncedCount}',
                  icon: Icons.cloud_done_outlined,
                  color: const Color(0xFF059669),
                ),
              ];

              if (isCompact) {
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      tiles
                          .map(
                            (tile) => SizedBox(
                              width: (constraints.maxWidth - 10) / 2,
                              child: tile,
                            ),
                          )
                          .toList(),
                );
              }

              return Row(
                children: List.generate(tiles.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == tiles.length - 1 ? 0 : 10,
                      ),
                      child: tiles[index],
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              FilledButton.icon(
                onPressed: onSyncNow,
                icon:
                    isSyncing
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.sync_outlined, size: 18),
                label: Text(isSyncing ? 'Syncing' : 'Retry now'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  disabledForegroundColor: const Color(0xFF64748B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.outlined(
                tooltip: 'Inspect issue outbox',
                onPressed: onInspect,
                icon: const Icon(Icons.manage_search_outlined, size: 20),
                style: IconButton.styleFrom(
                  foregroundColor: const Color(0xFF475569),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${health.pendingCount} pending',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BillingInvoiceIssueOutboxHealthBadge extends StatelessWidget {
  final BillingInvoiceIssueOutboxHealth health;

  const BillingInvoiceIssueOutboxHealthBadge({super.key, required this.health});

  @override
  Widget build(BuildContext context) {
    final visuals = _IssueOutboxHealthVisuals.fromHealth(health);

    return Tooltip(
      message: visuals.tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: visuals.backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: visuals.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(visuals.icon, color: visuals.color, size: 14),
            const SizedBox(width: 4),
            Text(
              visuals.badgeLabel,
              style: TextStyle(
                color: visuals.color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueOutboxHealthFrame extends StatelessWidget {
  final Widget child;

  const _IssueOutboxHealthFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}

class _IssueOutboxMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _IssueOutboxMetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
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

class _IssueOutboxHealthVisuals {
  final String headline;
  final String badgeLabel;
  final String tooltip;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;

  const _IssueOutboxHealthVisuals({
    required this.headline,
    required this.badgeLabel,
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
  });

  factory _IssueOutboxHealthVisuals.fromHealth(
    BillingInvoiceIssueOutboxHealth health,
  ) {
    if (health.isCaughtUp) {
      return const _IssueOutboxHealthVisuals(
        headline: 'Caught up',
        badgeLabel: 'Synced',
        tooltip: 'All issue commands are synced.',
        icon: Icons.cloud_done_outlined,
        color: Color(0xFF047857),
        backgroundColor: Color(0xFFD1FAE5),
        borderColor: Color(0xFFA7F3D0),
      );
    }

    if (health.exhaustedCount > 0) {
      return const _IssueOutboxHealthVisuals(
        headline: 'Manual review',
        badgeLabel: 'Blocked',
        tooltip: 'Some issue commands exhausted retry attempts.',
        icon: Icons.error_outline,
        color: Color(0xFFB91C1C),
        backgroundColor: Color(0xFFFEE2E2),
        borderColor: Color(0xFFFECACA),
      );
    }

    if (health.retryableNowCount > 0) {
      return const _IssueOutboxHealthVisuals(
        headline: 'Ready to sync',
        badgeLabel: 'Ready',
        tooltip: 'Issue commands are ready to sync.',
        icon: Icons.sync_outlined,
        color: Color(0xFF1D4ED8),
        backgroundColor: Color(0xFFDBEAFE),
        borderColor: Color(0xFFBFDBFE),
      );
    }

    return const _IssueOutboxHealthVisuals(
      headline: 'Waiting on retry',
      badgeLabel: 'Waiting',
      tooltip: 'Issue commands are waiting for retry backoff.',
      icon: Icons.schedule_outlined,
      color: Color(0xFFB45309),
      backgroundColor: Color(0xFFFEF3C7),
      borderColor: Color(0xFFFDE68A),
    );
  }
}

String _supportingText(
  BuildContext context,
  BillingInvoiceIssueOutboxHealth health,
) {
  if (health.isCaughtUp) {
    return 'No pending invoice issue commands.';
  }

  if (health.exhaustedCount > 0) {
    return '${health.exhaustedCount} exhausted, ${health.retryableNowCount} ready, ${health.deferredRetryCount} waiting.';
  }

  if (health.retryableNowCount > 0) {
    return '${health.retryableNowCount} ready, ${health.deferredRetryCount} waiting, ${health.failedCount} failed.';
  }

  final nextRetryAt = health.nextRetryAt;
  if (nextRetryAt != null) {
    final retryTime = TimeOfDay.fromDateTime(nextRetryAt).format(context);
    return 'Next retry window opens at $retryTime.';
  }

  return '${health.pendingCount} issue commands pending.';
}
