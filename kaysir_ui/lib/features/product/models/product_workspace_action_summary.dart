import 'product_workspace_action_group.dart';
import 'product_workspace_shortcut.dart';

class ProductWorkspaceActionSetupFocus {
  const ProductWorkspaceActionSetupFocus({
    required this.actionId,
    required this.actionTitle,
    this.groupTitle,
    this.routePath,
    this.reason,
  });

  final ProductWorkspaceShortcutId actionId;
  final String actionTitle;
  final String? groupTitle;
  final String? routePath;
  final String? reason;

  String get label => 'Set up $actionTitle';

  bool get hasRoutePath => routePath != null && routePath!.trim().isNotEmpty;

  String get tooltip {
    final contextLabel =
        groupTitle == null || groupTitle!.trim().isEmpty
            ? actionTitle
            : '$groupTitle: $actionTitle';
    final reasonText = reason?.trim();
    if (reasonText == null || reasonText.isEmpty) return contextLabel;

    return '$contextLabel - $reasonText';
  }
}

class ProductWorkspaceActionSummary {
  const ProductWorkspaceActionSummary({
    required this.groupCount,
    required this.actionCount,
    required this.enabledActionCount,
    required this.gatedActionCount,
    required this.readyGroupCount,
    required this.partialGroupCount,
    required this.gatedGroupCount,
    this.setupFocus,
  });

  factory ProductWorkspaceActionSummary.fromGroups(
    List<ProductWorkspaceActionGroup> groups,
  ) {
    final visibleGroups = groups
        .where((group) => group.hasShortcuts)
        .toList(growable: false);
    var actionCount = 0;
    var enabledActionCount = 0;
    var gatedActionCount = 0;
    var readyGroupCount = 0;
    var partialGroupCount = 0;
    var gatedGroupCount = 0;

    for (final group in visibleGroups) {
      actionCount += group.shortcutCount;
      enabledActionCount += group.enabledShortcutCount;
      gatedActionCount += group.disabledShortcutCount;

      switch (group.availability) {
        case ProductWorkspaceActionGroupAvailability.ready:
          readyGroupCount += 1;
          break;
        case ProductWorkspaceActionGroupAvailability.partial:
          partialGroupCount += 1;
          break;
        case ProductWorkspaceActionGroupAvailability.gated:
          gatedGroupCount += 1;
          break;
      }
    }

    return ProductWorkspaceActionSummary(
      groupCount: visibleGroups.length,
      actionCount: actionCount,
      enabledActionCount: enabledActionCount,
      gatedActionCount: gatedActionCount,
      readyGroupCount: readyGroupCount,
      partialGroupCount: partialGroupCount,
      gatedGroupCount: gatedGroupCount,
      setupFocus: _setupFocusForGroups(visibleGroups),
    );
  }

  factory ProductWorkspaceActionSummary.fromShortcuts(
    List<ProductWorkspaceShortcut> shortcuts,
  ) {
    final enabledActionCount =
        shortcuts.where((shortcut) => shortcut.isEnabled).length;

    return ProductWorkspaceActionSummary(
      groupCount: 0,
      actionCount: shortcuts.length,
      enabledActionCount: enabledActionCount,
      gatedActionCount: shortcuts.length - enabledActionCount,
      readyGroupCount: 0,
      partialGroupCount: 0,
      gatedGroupCount: 0,
      setupFocus: _setupFocusForShortcuts(shortcuts),
    );
  }

  final int groupCount;
  final int actionCount;
  final int enabledActionCount;
  final int gatedActionCount;
  final int readyGroupCount;
  final int partialGroupCount;
  final int gatedGroupCount;
  final ProductWorkspaceActionSetupFocus? setupFocus;

  bool get hasActions => actionCount > 0;
  bool get hasGroups => groupCount > 0;
  bool get hasGatedActions => gatedActionCount > 0;
  bool get hasSetupFocus => setupFocus != null;

  ProductWorkspaceActionGroupAvailability get availability {
    if (!hasActions || enabledActionCount == 0) {
      return ProductWorkspaceActionGroupAvailability.gated;
    }
    if (hasGatedActions) return ProductWorkspaceActionGroupAvailability.partial;

    return ProductWorkspaceActionGroupAvailability.ready;
  }

  String get readinessLabel {
    return switch (availability) {
      ProductWorkspaceActionGroupAvailability.ready => 'Ready',
      ProductWorkspaceActionGroupAvailability.partial => 'Partial',
      ProductWorkspaceActionGroupAvailability.gated => 'Setup needed',
    };
  }

  String get readyActionLabel {
    if (!hasActions) return 'No actions';

    return '$enabledActionCount/$actionCount ready';
  }

  String get groupCountLabel {
    return groupCount == 1 ? '1 group' : '$groupCount groups';
  }

  String get setupActionLabel {
    return gatedActionCount == 1 ? '1 setup' : '$gatedActionCount setup';
  }

  String get readinessTooltip {
    if (!hasActions) return 'No workspace actions are enabled yet.';
    if (!hasGatedActions) return 'All workspace actions are ready.';

    return '$enabledActionCount ready, $gatedActionCount waiting for setup.';
  }
}

ProductWorkspaceActionSetupFocus? _setupFocusForGroups(
  List<ProductWorkspaceActionGroup> groups,
) {
  for (final group in groups) {
    if (group.availability != ProductWorkspaceActionGroupAvailability.gated) {
      continue;
    }

    final focus = _setupFocusForGroup(group);
    if (focus != null) return focus;
  }

  for (final group in groups) {
    if (group.availability != ProductWorkspaceActionGroupAvailability.partial) {
      continue;
    }

    final focus = _setupFocusForGroup(group);
    if (focus != null) return focus;
  }

  return null;
}

ProductWorkspaceActionSetupFocus? _setupFocusForGroup(
  ProductWorkspaceActionGroup group,
) {
  for (final shortcut in group.shortcuts) {
    if (shortcut.isEnabled) continue;

    return ProductWorkspaceActionSetupFocus(
      actionId: shortcut.id,
      actionTitle: shortcut.title,
      groupTitle: group.title,
      routePath: shortcut.setupRoutePath,
      reason: shortcut.disabledReason,
    );
  }

  return null;
}

ProductWorkspaceActionSetupFocus? _setupFocusForShortcuts(
  List<ProductWorkspaceShortcut> shortcuts,
) {
  for (final shortcut in shortcuts) {
    if (shortcut.isEnabled) continue;

    return ProductWorkspaceActionSetupFocus(
      actionId: shortcut.id,
      actionTitle: shortcut.title,
      routePath: shortcut.setupRoutePath,
      reason: shortcut.disabledReason,
    );
  }

  return null;
}
