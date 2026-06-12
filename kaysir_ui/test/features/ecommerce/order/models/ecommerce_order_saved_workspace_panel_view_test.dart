import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace_panel_view.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  test('panel view computes counts and active workspace label', () {
    final view = ecommerceOrderSavedWorkspacePanelView(
      workspaces: _workspaces,
      activeWorkspaceId: savedWorkspaceDeliveryToday.id,
    );

    expect(view.hasWorkspaces, isTrue);
    expect(view.workspaceCount, 3);
    expect(view.pinnedWorkspaceCount, 1);
    expect(view.customNoteWorkspaceCount, 2);
    expect(view.activeWorkspaceLabel, 'Delivery / Today');
  });

  test('panel view exposes responsive header badges', () {
    final view = ecommerceOrderSavedWorkspacePanelView(
      workspaces: _workspaces,
      activeWorkspaceId: null,
    );

    expect(view.visibleBadgesForWidth(320), isEmpty);
    expect(view.visibleBadgesForWidth(380).map((badge) => badge.label), [
      '3 saved',
    ]);
    expect(view.visibleBadgesForWidth(560).map((badge) => badge.label), [
      '3 saved',
      '1 pinned',
    ]);
    expect(view.visibleBadgesForWidth(720).map((badge) => badge.label), [
      '3 saved',
      '1 pinned',
      '2 notes',
    ]);
  });

  test(
    'panel view handles missing active workspace and singular note label',
    () {
      final view = ecommerceOrderSavedWorkspacePanelView(
        workspaces: const [savedWorkspaceDeliveryToday],
        activeWorkspaceId: 'missing',
      );

      expect(view.activeWorkspaceLabel, isNull);
      expect(
        view.visibleBadgesForWidth(double.infinity).map((badge) => badge.label),
        ['1 saved', '1 note'],
      );
    },
  );
}

const _workspaces = [
  savedWorkspaceDeliveryToday,
  savedWorkspacePinnedPickupPriority,
  savedWorkspaceWebOverdueCustomNote,
];
