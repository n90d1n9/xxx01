import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_details_header_presentation.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  test(
    'details header presentation describes pinned custom-note workspace',
    () {
      final presentation =
          OrderSavedWorkspaceDetailsHeaderPresentation.fromWorkspace(
            savedWorkspacePinnedDeliveryToday,
          );

      expect(presentation.label, 'Delivery / Today');
      expect(presentation.description, 'Morning courier note');
      expect(_badgeLabels(presentation), ['Pinned', 'Custom note']);
      expect(_badgeIcons(presentation), [
        Icons.push_pin_rounded,
        Icons.sticky_note_2_outlined,
      ]);
    },
  );

  test(
    'details header presentation describes unpinned auto-summary workspace',
    () {
      final presentation =
          OrderSavedWorkspaceDetailsHeaderPresentation.fromWorkspace(
            savedWorkspaceWebOverdue,
          );

      expect(presentation.label, 'Web overdue');
      expect(presentation.description, 'Website escalations');
      expect(_badgeLabels(presentation), ['Unpinned', 'Auto summary']);
      expect(_badgeIcons(presentation), [
        Icons.bookmark_border_rounded,
        Icons.auto_awesome_outlined,
      ]);
    },
  );
}

List<String> _badgeLabels(
  OrderSavedWorkspaceDetailsHeaderPresentation presentation,
) {
  return presentation.badges.map((badge) => badge.label).toList();
}

List<IconData> _badgeIcons(
  OrderSavedWorkspaceDetailsHeaderPresentation presentation,
) {
  return presentation.badges.map((badge) => badge.icon).toList();
}
