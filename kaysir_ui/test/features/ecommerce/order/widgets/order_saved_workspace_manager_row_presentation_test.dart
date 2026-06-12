import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_manager_row_presentation.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  test('row presentation describes active pinned custom-note rows', () {
    final presentation = OrderSavedWorkspaceManagerRowPresentation(
      workspace: savedWorkspacePinnedDeliveryToday,
      isActive: true,
      canSelect: true,
    );

    expect(presentation.leadingIcon, Icons.push_pin_rounded);
    expect(presentation.showNoteMarker, true);
    expect(presentation.badges, ['Active', 'Pinned', 'Custom note']);
    expect(presentation.canApply, false);
    expect(presentation.applyIcon, Icons.check_circle_rounded);
    expect(presentation.applyLabel, 'Active');
  });

  test('row presentation describes inactive selectable rows', () {
    final presentation = OrderSavedWorkspaceManagerRowPresentation(
      workspace: savedWorkspacePickupPriority,
      isActive: false,
      canSelect: true,
    );

    expect(presentation.leadingIcon, Icons.bookmark_border_rounded);
    expect(presentation.showNoteMarker, false);
    expect(presentation.badges, isEmpty);
    expect(presentation.canApply, true);
    expect(presentation.applyIcon, Icons.play_arrow_rounded);
    expect(presentation.applyLabel, 'Apply');
  });

  test('row presentation disables apply without selection callbacks', () {
    final presentation = OrderSavedWorkspaceManagerRowPresentation(
      workspace: savedWorkspacePickupPriority,
      isActive: false,
      canSelect: false,
    );

    expect(presentation.canApply, false);
    expect(presentation.applyLabel, 'Apply');
  });

  test('row presentation resolves active and inactive colors from theme', () {
    final theme = ThemeData(useMaterial3: true);
    final active = OrderSavedWorkspaceManagerRowPresentation(
      workspace: savedWorkspacePinnedDeliveryToday,
      isActive: true,
      canSelect: true,
    ).colorsFor(theme);
    final inactive = OrderSavedWorkspaceManagerRowPresentation(
      workspace: savedWorkspacePickupPriority,
      isActive: false,
      canSelect: true,
    ).colorsFor(theme);

    expect(
      active.background,
      theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
    );
    expect(active.border, theme.colorScheme.primary.withValues(alpha: 0.28));
    expect(active.leading, theme.colorScheme.onPrimaryContainer);
    expect(active.title, theme.colorScheme.onPrimaryContainer);
    expect(
      active.description,
      theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.75),
    );
    expect(
      inactive.background,
      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
    );
    expect(inactive.border, theme.dividerColor);
    expect(inactive.leading, theme.colorScheme.onSurfaceVariant);
    expect(inactive.title, theme.colorScheme.onSurface);
    expect(inactive.description, theme.colorScheme.onSurfaceVariant);
  });
}
