import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('workspace view availability normalizes view selection policy', () {
    final availability = RestaurantWorkspaceViewAvailability.fromViews([
      RestaurantWorkspaceView.menu,
      RestaurantWorkspaceView.menu,
      RestaurantWorkspaceView.floor,
    ]);

    expect(availability.views, [
      RestaurantWorkspaceView.menu,
      RestaurantWorkspaceView.floor,
    ]);
    expect(availability.contains(RestaurantWorkspaceView.kitchen), isFalse);
    expect(
      availability.selectedOrFallback(RestaurantWorkspaceView.kitchen),
      RestaurantWorkspaceView.menu,
    );
    expect(
      availability.selectedOrFallback(
        RestaurantWorkspaceView.kitchen,
        preferredFallback: RestaurantWorkspaceView.floor,
      ),
      RestaurantWorkspaceView.floor,
    );
    expect(
      availability.selectedOrFallback(RestaurantWorkspaceView.floor),
      RestaurantWorkspaceView.floor,
    );

    expect(
      RestaurantWorkspaceViewAvailability.fromViews(const []).views,
      isEmpty,
    );
    expect(
      RestaurantWorkspaceViewAvailability.fromViews(
        const [],
        useAllWhenEmpty: true,
      ).views,
      RestaurantWorkspaceView.values,
    );
  });

  test('workspace panel plans define view-specific operating surfaces', () {
    expect(
      RestaurantWorkspacePanelPlan.forView(RestaurantWorkspaceView.pulse).slots,
      [
        RestaurantWorkspacePanelSlot.service,
        RestaurantWorkspacePanelSlot.briefing,
        RestaurantWorkspacePanelSlot.floor,
        RestaurantWorkspacePanelSlot.reservations,
        RestaurantWorkspacePanelSlot.kitchen,
        RestaurantWorkspacePanelSlot.task,
        RestaurantWorkspacePanelSlot.activity,
      ],
    );
    expect(
      RestaurantWorkspacePanelPlan.forView(RestaurantWorkspaceView.floor).slots,
      [
        RestaurantWorkspacePanelSlot.briefing,
        RestaurantWorkspacePanelSlot.floor,
        RestaurantWorkspacePanelSlot.reservations,
        RestaurantWorkspacePanelSlot.task,
        RestaurantWorkspacePanelSlot.activity,
      ],
    );
    expect(
      RestaurantWorkspacePanelPlan.forView(
        RestaurantWorkspaceView.reservations,
      ).slots,
      [
        RestaurantWorkspacePanelSlot.briefing,
        RestaurantWorkspacePanelSlot.reservations,
        RestaurantWorkspacePanelSlot.floor,
        RestaurantWorkspacePanelSlot.task,
        RestaurantWorkspacePanelSlot.activity,
      ],
    );
    expect(
      RestaurantWorkspacePanelPlan.forView(RestaurantWorkspaceView.menu).slots,
      [
        RestaurantWorkspacePanelSlot.briefing,
        RestaurantWorkspacePanelSlot.menu,
        RestaurantWorkspacePanelSlot.kitchen,
        RestaurantWorkspacePanelSlot.activity,
      ],
    );
    expect(
      RestaurantWorkspacePanelPlan.forView(
        RestaurantWorkspaceView.kitchen,
      ).slots,
      [
        RestaurantWorkspacePanelSlot.briefing,
        RestaurantWorkspacePanelSlot.kitchen,
        RestaurantWorkspacePanelSlot.task,
        RestaurantWorkspacePanelSlot.menu,
        RestaurantWorkspacePanelSlot.activity,
      ],
    );

    expect(
      RestaurantWorkspacePanelPlan.menu.contains(
        RestaurantWorkspacePanelSlot.service,
      ),
      isFalse,
    );
    expect(
      RestaurantWorkspacePanelPlan.kitchen.contains(
        RestaurantWorkspacePanelSlot.task,
      ),
      isTrue,
    );
  });

  test('workspace navigation targets map briefing focus to views', () {
    expect(
      RestaurantWorkspaceNavigationTarget.forBriefingCategory(
        RestaurantBriefingCategory.overview,
      ),
      const RestaurantWorkspaceNavigationTarget(
        view: RestaurantWorkspaceView.pulse,
      ),
    );
    expect(
      RestaurantWorkspaceNavigationTarget.forBriefingCategory(
        RestaurantBriefingCategory.floor,
      ).view,
      RestaurantWorkspaceView.floor,
    );
    expect(
      RestaurantWorkspaceNavigationTarget.forBriefingCategory(
        RestaurantBriefingCategory.reservations,
      ).view,
      RestaurantWorkspaceView.reservations,
    );
    expect(
      RestaurantWorkspaceNavigationTarget.forBriefingCategory(
        RestaurantBriefingCategory.kitchen,
      ).view,
      RestaurantWorkspaceView.kitchen,
    );
    expect(
      RestaurantWorkspaceNavigationTarget.forBriefingCategory(
        RestaurantBriefingCategory.menu,
      ).view,
      RestaurantWorkspaceView.menu,
    );
    expect(
      RestaurantWorkspaceNavigationTarget.forBriefingCategory(
        RestaurantBriefingCategory.task,
      ).view,
      RestaurantWorkspaceView.pulse,
    );
  });

  test('workspace ready view data snapshots presentation collections', () {
    final views = [RestaurantWorkspaceView.pulse];
    final presets = [RestaurantWorkspacePreset.servicePulse];
    final data = RestaurantWorkspaceReadyViewData(
      snapshot: restaurantDemoSnapshot,
      selectedView: RestaurantWorkspaceView.pulse,
      filters: const RestaurantWorkspacePanelFilters(),
      availableViews: views,
      availablePresets: presets,
      activities: const [],
      insights: const [],
    );

    views.add(RestaurantWorkspaceView.menu);
    presets.clear();

    expect(data.availableViews, [RestaurantWorkspaceView.pulse]);
    expect(data.availablePresets, [RestaurantWorkspacePreset.servicePulse]);
    expect(data.hasPresets, isTrue);
    expect(data.hasInsights, isFalse);
    expect(data.hasAttentionSignals, isFalse);
    expect(data.hasSelectedAttentionSignal, isFalse);
    expect(
      () => data.availableViews.add(RestaurantWorkspaceView.kitchen),
      throwsUnsupportedError,
    );
  });

  test(
    'workspace ready view data builder filters available presentation data',
    () {
      final data = const RestaurantWorkspaceReadyViewDataBuilder().build(
        snapshot: restaurantDemoSnapshot,
        selectedView: RestaurantWorkspaceView.menu,
        filters: RestaurantWorkspacePreset.menuRisk.filters,
        focus: const RestaurantWorkspacePanelFocus(
          kind: RestaurantWorkspacePanelFocusKind.menuSignal,
          targetId: 'short-rib-rendang',
        ),
        viewAvailability: RestaurantWorkspaceViewAvailability.fromViews([
          RestaurantWorkspaceView.menu,
        ]),
        updatedAt: DateTime(2026, 1, 1, 12),
        isRefreshing: true,
      );

      expect(data.availableViews, [RestaurantWorkspaceView.menu]);
      expect(data.availablePresets, [
        RestaurantWorkspacePreset.menuRisk,
        RestaurantWorkspacePreset.marginFocus,
      ]);
      expect(data.selectedPreset, RestaurantWorkspacePreset.menuRisk);
      expect(data.hasPanelFocus, isTrue);
      expect(data.panelFocus?.targetId, 'short-rib-rendang');
      expect(data.insights.map((insight) => insight.targetView).toSet(), {
        RestaurantWorkspaceView.menu,
      });
      expect(data.attentionQueue.hasAttention, isTrue);
      expect(data.attentionQueue.topSignal?.id, 'menu-risk-short-rib-rendang');
      expect(
        data.attentionQueue.signals.every(
          (signal) =>
              const RestaurantAttentionSignalTargetResolver()
                  .resolve(signal)
                  .view ==
              RestaurantWorkspaceView.menu,
        ),
        isTrue,
      );
      expect(data.selectedInsight?.targetView, RestaurantWorkspaceView.menu);
      expect(data.selectedAttentionSignal?.id, 'menu-risk-short-rib-rendang');
      expect(data.isRefreshing, isTrue);
      expect(data.updatedAt, DateTime(2026, 1, 1, 12));
    },
  );
}
