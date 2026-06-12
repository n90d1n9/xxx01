import 'package:flutter/material.dart';

import 'billing_release_workspace_registry.dart';

const billingReleaseWorkspaceAllSavedViewId = 'all';
const billingReleaseWorkspacePackageSavedViewId = 'packages';
const billingReleaseWorkspaceProductReleaseSavedViewId = 'release';
const billingReleaseWorkspaceLaunchSavedViewId = 'launch';

class BillingReleaseWorkspaceSavedView {
  final String id;
  final String label;
  final String description;
  final Set<String> deckIds;
  final bool includesAllDecks;
  final IconData? icon;
  final Color? accentColor;

  const BillingReleaseWorkspaceSavedView({
    required this.id,
    required this.label,
    required this.description,
    this.deckIds = const {},
    this.includesAllDecks = false,
    this.icon,
    this.accentColor,
  });

  bool matches(String savedViewId) {
    return id == savedViewId.trim();
  }

  BillingReleaseWorkspaceRegistry apply(
    BillingReleaseWorkspaceRegistry registry,
  ) {
    if (includesAllDecks || deckIds.isEmpty) return registry;

    return registry.only(deckIds);
  }

  int count(BillingReleaseWorkspaceRegistry registry) {
    return apply(registry).count;
  }
}

const billingReleaseWorkspaceAllSavedView = BillingReleaseWorkspaceSavedView(
  id: billingReleaseWorkspaceAllSavedViewId,
  label: 'All readiness',
  description: 'Every release workspace deck',
  includesAllDecks: true,
);

const billingReleaseWorkspacePackageSavedView =
    BillingReleaseWorkspaceSavedView(
      id: billingReleaseWorkspacePackageSavedViewId,
      label: 'Packages',
      description: 'Package, manifest, bundle, and launch playbook readiness',
      deckIds: {billingReleaseWorkspacePackageReadinessDeckId},
    );

const billingReleaseWorkspaceProductReleaseSavedView =
    BillingReleaseWorkspaceSavedView(
      id: billingReleaseWorkspaceProductReleaseSavedViewId,
      label: 'Release matrix',
      description: 'Product edition and channel matrix readiness',
      deckIds: {billingReleaseWorkspaceProductReleaseDeckId},
    );

const billingReleaseWorkspaceLaunchSavedView = BillingReleaseWorkspaceSavedView(
  id: billingReleaseWorkspaceLaunchSavedViewId,
  label: 'Launch queue',
  description: 'Channel launch plan, runbook, and queue readiness',
  deckIds: {billingReleaseWorkspaceChannelLaunchDeckId},
);

const billingReleaseWorkspaceDefaultSavedViews =
    <BillingReleaseWorkspaceSavedView>[
      billingReleaseWorkspaceAllSavedView,
      billingReleaseWorkspacePackageSavedView,
      billingReleaseWorkspaceProductReleaseSavedView,
      billingReleaseWorkspaceLaunchSavedView,
    ];

BillingReleaseWorkspaceSavedView? findBillingReleaseWorkspaceSavedView({
  required String id,
  Iterable<BillingReleaseWorkspaceSavedView> views =
      billingReleaseWorkspaceDefaultSavedViews,
}) {
  for (final view in views) {
    if (view.matches(id)) return view;
  }

  return null;
}

class BillingReleaseWorkspaceSavedViewBar extends StatelessWidget {
  final BillingReleaseWorkspaceRegistry registry;
  final BillingReleaseWorkspaceSavedView selectedView;
  final ValueChanged<BillingReleaseWorkspaceSavedView> onSelected;
  final List<BillingReleaseWorkspaceSavedView> views;

  const BillingReleaseWorkspaceSavedViewBar({
    super.key,
    required this.registry,
    required this.selectedView,
    required this.onSelected,
    this.views = billingReleaseWorkspaceDefaultSavedViews,
  });

  @override
  Widget build(BuildContext context) {
    if (views.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final view = views[index];

          return _ReleaseSavedViewPill(
            view: view,
            count: view.count(registry),
            selected: selectedView.id == view.id,
            onTap: () => onSelected(view),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemCount: views.length,
      ),
    );
  }
}

class _ReleaseSavedViewPill extends StatelessWidget {
  final BillingReleaseWorkspaceSavedView view;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _ReleaseSavedViewPill({
    required this.view,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = view.accentColor ?? _accentFor(view.id);
    final foreground = selected ? Colors.white : accent;

    return Semantics(
      button: true,
      selected: selected,
      label: '${view.label}, $count release decks',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 158,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: selected ? accent : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? accent : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: selected ? 0.10 : 0.04),
                  blurRadius: selected ? 14 : 8,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  view.icon ?? _iconFor(view.id),
                  size: 17,
                  color: foreground,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    view.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _ReleaseSavedViewCountBadge(count: count, selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String id) {
    return switch (id) {
      billingReleaseWorkspacePackageSavedViewId => Icons.inventory_2_outlined,
      billingReleaseWorkspaceProductReleaseSavedViewId =>
        Icons.view_carousel_outlined,
      billingReleaseWorkspaceLaunchSavedViewId => Icons.rocket_launch_outlined,
      _ => Icons.dashboard_customize_outlined,
    };
  }

  Color _accentFor(String id) {
    return switch (id) {
      billingReleaseWorkspacePackageSavedViewId => const Color(0xFF2563EB),
      billingReleaseWorkspaceProductReleaseSavedViewId => const Color(
        0xFF7C3AED,
      ),
      billingReleaseWorkspaceLaunchSavedViewId => const Color(0xFF059669),
      _ => const Color(0xFF334155),
    };
  }
}

class _ReleaseSavedViewCountBadge extends StatelessWidget {
  final int count;
  final bool selected;

  const _ReleaseSavedViewCountBadge({
    required this.count,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 24),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color:
            selected
                ? Colors.white.withValues(alpha: 0.18)
                : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF334155),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
