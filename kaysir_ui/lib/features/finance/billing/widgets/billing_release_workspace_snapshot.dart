import 'package:flutter/material.dart';

import 'billing_release_workspace_registry.dart';
import 'billing_release_workspace_saved_view.dart';

class BillingReleaseWorkspaceSnapshot {
  final String businessDomain;
  final BillingReleaseWorkspaceSavedView savedView;
  final BillingReleaseWorkspaceRegistry baseRegistry;
  final BillingReleaseWorkspaceRegistry visibleRegistry;

  factory BillingReleaseWorkspaceSnapshot.forView({
    required String businessDomain,
    required BillingReleaseWorkspaceSavedView savedView,
    required BillingReleaseWorkspaceRegistry baseRegistry,
  }) {
    return BillingReleaseWorkspaceSnapshot._(
      businessDomain: businessDomain.trim(),
      savedView: savedView,
      baseRegistry: baseRegistry,
      visibleRegistry: savedView.apply(baseRegistry),
    );
  }

  const BillingReleaseWorkspaceSnapshot._({
    required this.businessDomain,
    required this.savedView,
    required this.baseRegistry,
    required this.visibleRegistry,
  });

  int get totalDeckCount => baseRegistry.count;

  int get visibleDeckCount => visibleRegistry.count;

  int get hiddenDeckCount => totalDeckCount - visibleDeckCount;

  bool get isFiltered => hiddenDeckCount > 0;

  List<String> get visibleDeckIds => visibleRegistry.deckIds;

  List<String> get hiddenDeckIds {
    final visibleIds = visibleRegistry.deckIds.toSet();
    return List.unmodifiable(
      baseRegistry.deckIds.where((deckId) => !visibleIds.contains(deckId)),
    );
  }

  String get domainLabel {
    final normalizedDomain = businessDomain.trim();
    if (normalizedDomain.isEmpty) return 'Default domain';

    return normalizedDomain
        .split(RegExp(r'[-_\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String get summaryLabel {
    if (!isFiltered) {
      return 'Showing all $totalDeckCount release workspace decks.';
    }

    return 'Showing $visibleDeckCount of $totalDeckCount release workspace decks.';
  }

  String get hiddenDeckLabel {
    if (!isFiltered) return 'No decks hidden';

    return '$hiddenDeckCount hidden';
  }
}

class BillingReleaseWorkspaceSnapshotBanner extends StatelessWidget {
  final BillingReleaseWorkspaceSnapshot snapshot;

  const BillingReleaseWorkspaceSnapshotBanner({
    super.key,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 680;

          final details = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SnapshotPill(
                label: snapshot.domainLabel,
                icon: Icons.domain_outlined,
                color: const Color(0xFF2563EB),
              ),
              _SnapshotPill(
                label: '${snapshot.visibleDeckCount} visible',
                icon: Icons.visibility_outlined,
                color: const Color(0xFF059669),
              ),
              _SnapshotPill(
                label: snapshot.hiddenDeckLabel,
                icon: Icons.visibility_off_outlined,
                color:
                    snapshot.isFiltered
                        ? const Color(0xFFD97706)
                        : const Color(0xFF64748B),
              ),
            ],
          );

          final title = _SnapshotTitle(snapshot: snapshot);
          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 10), details],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: title),
              const SizedBox(width: 14),
              details,
            ],
          );
        },
      ),
    );
  }
}

class _SnapshotTitle extends StatelessWidget {
  final BillingReleaseWorkspaceSnapshot snapshot;

  const _SnapshotTitle({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.dashboard_customize_outlined,
            color: Color(0xFF2563EB),
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                snapshot.savedView.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                snapshot.summaryLabel,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SnapshotPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SnapshotPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
