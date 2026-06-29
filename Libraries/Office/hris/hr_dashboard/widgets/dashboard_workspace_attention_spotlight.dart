import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_workspace_entry.dart';
import 'dashboard_workspace_attention_actions.dart';
import 'dashboard_workspace_risk_badge.dart';

class DashboardWorkspaceAttentionSpotlight extends StatelessWidget {
  final DashboardWorkspaceEntry entry;
  final VoidCallback onFocusAttention;

  const DashboardWorkspaceAttentionSpotlight({
    super.key,
    required this.entry,
    required this.onFocusAttention,
  });

  @override
  Widget build(BuildContext context) {
    final signal = entry.riskSignal;
    if (signal == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: entry.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: entry.color.withValues(alpha: 0.18)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 720) {
            return _CompactSpotlightContent(
              entry: entry,
              onFocusAttention: onFocusAttention,
            );
          }

          return _WideSpotlightContent(
            entry: entry,
            onFocusAttention: onFocusAttention,
          );
        },
      ),
    );
  }
}

class _WideSpotlightContent extends StatelessWidget {
  final DashboardWorkspaceEntry entry;
  final VoidCallback onFocusAttention;

  const _WideSpotlightContent({
    required this.entry,
    required this.onFocusAttention,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SpotlightIcon(entry: entry),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SpotlightCopy(entry: entry),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: DashboardWorkspaceAttentionActions(
                  entry: entry,
                  onFocusAttention: onFocusAttention,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactSpotlightContent extends StatelessWidget {
  final DashboardWorkspaceEntry entry;
  final VoidCallback onFocusAttention;

  const _CompactSpotlightContent({
    required this.entry,
    required this.onFocusAttention,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SpotlightIcon(entry: entry),
            const SizedBox(width: 12),
            Expanded(child: _SpotlightCopy(entry: entry)),
          ],
        ),
        const SizedBox(height: 12),
        DashboardWorkspaceAttentionActions(
          entry: entry,
          onFocusAttention: onFocusAttention,
        ),
      ],
    );
  }
}

class _SpotlightIcon extends StatelessWidget {
  final DashboardWorkspaceEntry entry;

  const _SpotlightIcon({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: entry.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(entry.icon, color: entry.color),
    );
  }
}

class _SpotlightCopy extends StatelessWidget {
  final DashboardWorkspaceEntry entry;

  const _SpotlightCopy({required this.entry});

  @override
  Widget build(BuildContext context) {
    final signal = entry.riskSignal!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Top attention',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: HrisColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
            DashboardWorkspaceRiskBadge(signal: signal, compact: true),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Top attention: ${entry.title}',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${signal.leadingSignal} - ${signal.timeSensitiveRisks} time-sensitive',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
      ],
    );
  }
}
