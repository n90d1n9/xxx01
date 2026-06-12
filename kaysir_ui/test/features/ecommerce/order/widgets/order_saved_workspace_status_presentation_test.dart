import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_status_presentation.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  test('status presentation describes pinned custom-note workspaces', () {
    final presentation = OrderSavedWorkspaceStatusPresentation(
      workspace: savedWorkspacePinnedDeliveryToday,
    );

    expect(presentation.leadingIcon, Icons.push_pin_rounded);
    expect(presentation.showNoteMarker, true);
    expect(_badgeLabels(presentation.detailBadges), ['Pinned', 'Custom note']);
    expect(_badgeIcons(presentation.detailBadges), [
      Icons.push_pin_rounded,
      Icons.sticky_note_2_outlined,
    ]);
    expect(presentation.rowBadges(isActive: true), [
      'Active',
      'Pinned',
      'Custom note',
    ]);
  });

  test('status presentation describes unpinned auto-summary workspaces', () {
    final presentation = OrderSavedWorkspaceStatusPresentation(
      workspace: savedWorkspaceWebOverdue,
    );

    expect(presentation.leadingIcon, Icons.bookmark_border_rounded);
    expect(presentation.showNoteMarker, false);
    expect(_badgeLabels(presentation.detailBadges), [
      'Unpinned',
      'Auto summary',
    ]);
    expect(_badgeIcons(presentation.detailBadges), [
      Icons.bookmark_border_rounded,
      Icons.auto_awesome_outlined,
    ]);
    expect(presentation.rowBadges(isActive: false), isEmpty);
  });
}

List<String> _badgeLabels(
  List<OrderSavedWorkspaceStatusBadgePresentation> badges,
) {
  return badges.map((badge) => badge.label).toList();
}

List<IconData> _badgeIcons(
  List<OrderSavedWorkspaceStatusBadgePresentation> badges,
) {
  return badges.map((badge) => badge.icon).toList();
}
