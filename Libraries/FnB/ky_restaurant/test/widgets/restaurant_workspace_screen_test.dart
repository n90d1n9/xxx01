import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/reservation_qr_test_finders.dart';

void main() {
  testWidgets('restaurant workspace renders selected view', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RestaurantWorkspaceScreen(
          initialView: RestaurantWorkspaceView.kitchen,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kaysir Table Service'), findsOneWidget);
    expect(find.byType(RestaurantWorkspaceScaffold), findsOneWidget);
    expect(find.text('Operational briefing'), findsOneWidget);
    expect(find.text('Fresh snapshot'), findsOneWidget);
    expect(find.text('Attention feed'), findsOneWidget);
    expect(find.text('Priority watch'), findsOneWidget);
    expect(find.text('Recover Grill'), findsWidgets);
    expect(find.text('Priority 1'), findsWidgets);
    expect(find.text('22m tickets, 0 waiting'), findsWidgets);
    expect(find.byType(RestaurantBriefingCard), findsWidgets);
    expect(find.text('Kitchen flow'), findsWidgets);
    expect(find.text('Grill'), findsWidgets);
  });

  testWidgets('restaurant workspace launches reservation QR intake', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 6, 10, 12);
    final qrController = RestaurantReservationQrSessionController(
      workflow: RestaurantReservationQrWorkflow(
        linkComposer: RestaurantReservationQrLinkComposer(
          clock: () => now,
          tokenFactory: () => 'workspace-panel-token',
        ),
      ),
    );
    final launchedLinks = <RestaurantReservationQrLink>[];

    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantWorkspaceScreen(
          initialView: RestaurantWorkspaceView.reservations,
          views: const [RestaurantWorkspaceView.reservations],
          reservationQrPanelBinding: RestaurantReservationQrPanelBinding(
            controller: qrController,
            launchConfig: RestaurantReservationQrIntakeLaunchConfig(
              baseUri: Uri.parse('https://tables.kaysir.test/workspace'),
              lifetime: const Duration(minutes: 12),
              zoneLabel: 'Terrace',
              queryParameters: const {'source': 'workspace-screen'},
            ),
            onLinkLaunched: launchedLinks.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byType(RestaurantReservationQrSessionControllerPanel),
      findsOneWidget,
    );
    expect(find.text('QR session'), findsOneWidget);

    await tester.ensureVisible(find.text('QR waitlist'));
    await tester.tap(find.text('QR waitlist'));
    await tester.pumpAndSettle();

    expect(launchedLinks, hasLength(1));
    expect(qrController.activeLink, launchedLinks.single);
    expect(launchedLinks.single.payload.token, 'workspace-panel-token');
    expect(
      launchedLinks.single.payload.intent,
      RestaurantReservationQrIntent.waitlist,
    );
    expect(
      launchedLinks.single.uri.queryParameters['source'],
      'workspace-screen',
    );
    expect(find.text('Active QR handoff'), findsOneWidget);

    qrController.dispose();
  });

  testWidgets('restaurant workspace confirms reservation QR check-in', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 6, 10, 12);
    final workspaceController = RestaurantWorkspaceController(
      repository: const DemoRestaurantSnapshotRepository(),
      initialState: RestaurantWorkspaceState.ready(
        snapshot: restaurantDemoSnapshot,
        updatedAt: now,
      ),
    );
    final qrController = RestaurantReservationQrSessionController(
      workflow: RestaurantReservationQrWorkflow(
        linkComposer: RestaurantReservationQrLinkComposer(
          clock: () => now,
          tokenFactory: () => 'workspace-check-in-token',
        ),
        scanResolver: RestaurantReservationQrScanResolver(clock: () => now),
      ),
    );
    final launchedLinks = <RestaurantReservationQrLink>[];

    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantWorkspaceScreen(
          controller: workspaceController,
          initialView: RestaurantWorkspaceView.reservations,
          views: const [RestaurantWorkspaceView.reservations],
          reservationQrPanelBinding: RestaurantReservationQrPanelBinding(
            controller: qrController,
            launchConfig: RestaurantReservationQrIntakeLaunchConfig(
              baseUri: Uri.parse('https://tables.kaysir.test/workspace'),
              lifetime: const Duration(minutes: 12),
              reservationId: 'sari-party',
              zoneLabel: 'Main Floor',
              tableLabel: 'Table 12',
              queryParameters: const {'source': 'workspace-check-in'},
            ),
            onLinkLaunched: launchedLinks.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      _reservationStatus(workspaceController, 'sari-party'),
      RestaurantReservationStatus.confirmed,
    );

    await tester.ensureVisible(find.text('QR check-in'));
    await tester.tap(find.text('QR check-in'));
    await tester.pumpAndSettle();

    expect(launchedLinks, hasLength(1));
    expect(
      launchedLinks.single.payload.intent,
      RestaurantReservationQrIntent.checkIn,
    );
    expect(launchedLinks.single.payload.reservationId, 'sari-party');

    final scanField = _textFieldWithHint('Reservation QR link');
    await tester.ensureVisible(scanField);
    await tester.enterText(scanField, launchedLinks.single.url);
    await tester.pump();

    final resolveScanButton = find.widgetWithText(FilledButton, 'Resolve scan');
    await tester.ensureVisible(resolveScanButton);
    await tester.tap(resolveScanButton);
    await tester.pumpAndSettle();

    final confirmAction = findReservationQrScanAction(
      RestaurantReservationQrScanAction.confirmCheckIn,
    );
    await tester.ensureVisible(confirmAction);
    await tester.tap(confirmAction);
    await tester.pumpAndSettle();

    expect(
      _reservationStatus(workspaceController, 'sari-party'),
      RestaurantReservationStatus.arrived,
    );
    expect(find.text('Confirm check-in handled'), findsOneWidget);
    expect(find.text('Reservation marked Arrived'), findsOneWidget);
    expect(find.widgetWithText(SnackBarAction, 'Undo'), findsOneWidget);

    await tester.tap(find.widgetWithText(SnackBarAction, 'Undo'));
    await tester.pumpAndSettle();

    expect(
      _reservationStatus(workspaceController, 'sari-party'),
      RestaurantReservationStatus.confirmed,
    );
    expect(find.text('Action undone'), findsOneWidget);

    workspaceController.dispose();
    qrController.dispose();
  });

  testWidgets('workspace ready view renders shell and forwards controls', (
    tester,
  ) async {
    var refreshed = false;
    RestaurantWorkspaceView? selectedView;
    RestaurantWorkspacePreset? selectedPreset;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RestaurantWorkspaceReadyView(
              data: RestaurantWorkspaceReadyViewData(
                snapshot: restaurantDemoSnapshot,
                selectedView: RestaurantWorkspaceView.pulse,
                filters: const RestaurantWorkspacePanelFilters(),
                availableViews: RestaurantWorkspaceView.values,
                availablePresets: RestaurantWorkspacePreset.values,
                activities: const [],
                insights: const [],
              ),
              controls: RestaurantWorkspaceControlCallbacks(
                onRefresh: () => refreshed = true,
                onViewChanged: (view) => selectedView = view,
                onPresetSelected: (preset) => selectedPreset = preset,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Kaysir Table Service'), findsOneWidget);
    expect(find.text('Command center'), findsOneWidget);
    expect(find.text('Quick views'), findsOneWidget);
    expect(find.text('Service pulse'), findsWidgets);
    expect(find.byType(RestaurantWorkspaceControlsSection), findsOneWidget);
    expect(find.byType(RestaurantWorkspaceOverviewSection), findsOneWidget);
    expect(find.byType(RestaurantWorkspacePanelDeck), findsOneWidget);
    expect(find.byType(RestaurantMetricCard), findsWidgets);
    expect(find.byType(RestaurantPulseMetricCard), findsWidgets);
    expect(find.byType(RestaurantWorkspacePanelLayout), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pump();

    expect(refreshed, isTrue);

    final menuView = find.descendant(
      of: find.byType(RestaurantViewSwitcher),
      matching: find.text('Menu Mix'),
    );
    await tester.ensureVisible(menuView);
    await tester.pumpAndSettle();
    await tester.tap(menuView);
    await tester.pump();

    expect(selectedView, RestaurantWorkspaceView.menu);

    final menuRiskPreset = find.descendant(
      of: find.byType(RestaurantWorkspacePresetBar),
      matching: find.text('Menu risk'),
    );
    await tester.ensureVisible(menuRiskPreset);
    await tester.pumpAndSettle();
    await tester.tap(menuRiskPreset);
    await tester.pump();

    expect(selectedPreset, RestaurantWorkspacePreset.menuRisk);
  });

  testWidgets('shift focus strip renders ranked items and reports selection', (
    tester,
  ) async {
    RestaurantBriefingItem? selectedItem;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantShiftFocusStrip(
            snapshot: restaurantDemoSnapshot,
            onItemSelected: (item) => selectedItem = item,
          ),
        ),
      ),
    );

    expect(find.text('Priority watch'), findsOneWidget);
    expect(find.text('Stabilize Private Room'), findsOneWidget);
    expect(find.text('Priority 1'), findsOneWidget);
    expect(find.text('22m tickets, 0 waiting'), findsOneWidget);
    expect(find.byType(RestaurantShiftFocusTile), findsWidgets);
    expect(find.byType(RestaurantInteractiveSurface), findsNWidgets(4));

    await tester.tap(find.text('Stabilize Private Room'));
    await tester.pump();

    expect(selectedItem?.category, RestaurantBriefingCategory.floor);
    expect(selectedItem?.action?.targetId, 'private-room');
  });

  testWidgets('restaurant workspace focus strip changes selected view', (
    tester,
  ) async {
    RestaurantWorkspaceView? selectedView;

    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantWorkspaceScreen(
          initialView: RestaurantWorkspaceView.floor,
          onViewChanged: (view) => selectedView = view,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final menuWatchItem = find.text('Protect Short Rib Rendang').first;
    await tester.ensureVisible(menuWatchItem);
    await tester.pumpAndSettle();
    await tester.tap(menuWatchItem);
    await tester.pumpAndSettle();

    expect(selectedView, RestaurantWorkspaceView.menu);
    expect(find.text('Menu mix'), findsOneWidget);
  });

  testWidgets('restaurant workspace applies quick view presets', (
    tester,
  ) async {
    RestaurantWorkspaceView? selectedView;

    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantWorkspaceScreen(
          onViewChanged: (view) => selectedView = view,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Quick views'), findsOneWidget);

    final menuRiskPreset = find.descendant(
      of: find.byType(RestaurantWorkspacePresetBar),
      matching: find.text('Menu risk'),
    );

    await tester.ensureVisible(menuRiskPreset);
    await tester.tap(menuRiskPreset);
    await tester.pumpAndSettle();

    final selectedChip = tester.widget<ChoiceChip>(
      find
          .ancestor(of: menuRiskPreset, matching: find.byType(ChoiceChip))
          .first,
    );

    expect(selectedView, RestaurantWorkspaceView.menu);
    expect(selectedChip.selected, isTrue);
    expect(find.text('Menu mix'), findsOneWidget);
    expect(find.text('3 active lenses'), findsOneWidget);
    expect(_menuSignalText('Short Rib Rendang'), findsOneWidget);
    expect(_menuSignalText('Citrus Pandan Spritz'), findsNothing);
  });

  testWidgets('restaurant workspace applies insight deep links', (
    tester,
  ) async {
    RestaurantWorkspaceView? selectedView;

    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantWorkspaceScreen(
          onViewChanged: (view) => selectedView = view,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final menuRiskInsight = find.descendant(
      of: find.byType(RestaurantOperationalInsightGrid),
      matching: find.text('Protect Short Rib Rendang'),
    );

    await tester.ensureVisible(menuRiskInsight);
    await tester.tap(menuRiskInsight);
    await tester.pumpAndSettle();

    expect(selectedView, RestaurantWorkspaceView.menu);
    expect(find.text('Menu mix'), findsOneWidget);
    expect(find.text('3 active lenses'), findsOneWidget);
    expect(find.text('Risk 2'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(RestaurantMenuSortButton),
        matching: find.text('Risk'),
      ),
      findsOneWidget,
    );
    expect(_menuSignalText('Short Rib Rendang'), findsOneWidget);
    expect(_menuSignalText('Citrus Pandan Spritz'), findsNothing);

    final selectedCard = tester.widget<RestaurantOperationalInsightCard>(
      find
          .ancestor(
            of: menuRiskInsight,
            matching: find.byType(RestaurantOperationalInsightCard),
          )
          .first,
    );
    expect(selectedCard.selected, isTrue);
  });

  testWidgets('freshness notice surfaces stale snapshot state', (tester) async {
    final now = DateTime(2026, 1, 1, 12);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantWorkspaceFreshnessNotice(
            updatedAt: now.subtract(const Duration(minutes: 22)),
            isRefreshing: false,
            now: now,
          ),
        ),
      ),
    );

    expect(find.text('Stale snapshot'), findsOneWidget);
    expect(find.text('Updated 22m ago'), findsOneWidget);
  });

  testWidgets('restaurant workspace preserves panel filters between views', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RestaurantWorkspaceScreen(
          initialView: RestaurantWorkspaceView.floor,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Waitlist 3'));
    await tester.tap(find.text('Waitlist 3'));
    await tester.pumpAndSettle();

    final floorPanel = find.byType(RestaurantFloorPanel);
    expect(
      find.descendant(of: floorPanel, matching: find.text('Main Floor')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: floorPanel, matching: find.text('Terrace')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: floorPanel, matching: find.text('Bar Counter')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: floorPanel, matching: find.text('Private Room')),
      findsNothing,
    );

    await tester.ensureVisible(find.text('Menu Mix'));
    await tester.tap(find.text('Menu Mix'));
    await tester.pumpAndSettle();

    expect(find.text('Menu mix'), findsOneWidget);

    await tester.ensureVisible(find.text('Floor Plan'));
    await tester.tap(find.text('Floor Plan'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: floorPanel, matching: find.text('Main Floor')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: floorPanel, matching: find.text('Terrace')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: floorPanel, matching: find.text('Bar Counter')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: floorPanel, matching: find.text('Private Room')),
      findsNothing,
    );
  });

  testWidgets('restaurant workspace preserves menu search between views', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RestaurantWorkspaceScreen(
          initialView: RestaurantWorkspaceView.menu,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'cheese');
    await tester.pumpAndSettle();

    expect(_menuSignalText('Burnt Cheesecake'), findsOneWidget);
    expect(_menuSignalText('Short Rib Rendang'), findsNothing);

    await tester.ensureVisible(find.text('Kitchen Flow'));
    await tester.tap(find.text('Kitchen Flow'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Menu Mix'));
    await tester.tap(find.text('Menu Mix'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(TextField));

    expect(find.widgetWithText(TextField, 'cheese'), findsOneWidget);
    expect(_menuSignalText('Burnt Cheesecake'), findsOneWidget);
    expect(_menuSignalText('Short Rib Rendang'), findsNothing);
  });

  testWidgets('restaurant workspace reports serializable preference changes', (
    tester,
  ) async {
    final changes = <RestaurantWorkspacePreferences>[];

    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantWorkspaceScreen(
          initialView: RestaurantWorkspaceView.menu,
          onPreferencesChanged: changes.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(changes, isEmpty);

    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'cheese');
    await tester.pumpAndSettle();

    expect(changes.last.view, RestaurantWorkspaceView.menu);
    expect(changes.last.filters.menuSearchQuery, 'cheese');
    expect(changes.last.toJson(), {
      'view': 'menu',
      'filters': {
        'floor': 'all',
        'kitchen': 'all',
        'reservations': 'all',
        'menu': 'all',
        'task': 'all',
        'activity': 'all',
        'menuSearchQuery': 'cheese',
        'reservationSearchQuery': '',
        'menuSort': 'demand',
      },
    });

    await tester.ensureVisible(find.text('Kitchen Flow'));
    await tester.tap(find.text('Kitchen Flow'));
    await tester.pumpAndSettle();

    expect(changes.last.view, RestaurantWorkspaceView.kitchen);
    expect(changes.last.filters.menuSearchQuery, 'cheese');
  });

  testWidgets('restaurant workspace persists controls through injected prefs', (
    tester,
  ) async {
    final preferences = RestaurantWorkspacePreferencesController(
      initialPreferences: const RestaurantWorkspacePreferences(
        view: RestaurantWorkspaceView.menu,
        filters: RestaurantWorkspacePanelFilters(
          menu: RestaurantMenuFilter.risk,
          menuSearchQuery: 'cheese',
        ),
      ),
    );
    final viewChanges = <RestaurantWorkspaceView>[];

    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantWorkspaceScreen(
          preferencesController: preferences,
          onViewChanged: viewChanges.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Menu mix'), findsOneWidget);
    expect(find.text('2 active lenses'), findsOneWidget);
    expect(_menuSignalText('Burnt Cheesecake'), findsOneWidget);
    expect(_menuSignalText('Short Rib Rendang'), findsNothing);

    await tester.ensureVisible(find.byTooltip('Clear Menu search: cheese'));
    await tester.tap(find.byTooltip('Clear Menu search: cheese'));
    await tester.pumpAndSettle();

    expect(preferences.filters.menuSearchQuery, isEmpty);
    expect(find.text('1 active lens'), findsOneWidget);

    await tester.ensureVisible(find.text('Kitchen Flow'));
    await tester.tap(find.text('Kitchen Flow'));
    await tester.pumpAndSettle();

    expect(preferences.selectedView, RestaurantWorkspaceView.kitchen);
    expect(viewChanges, [RestaurantWorkspaceView.kitchen]);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantWorkspaceScreen(preferencesController: preferences),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kitchen flow'), findsWidgets);
    expect(find.text('1 active lens'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pumpAndSettle();

    preferences.dispose();
  });

  testWidgets('restaurant workspace clamps restored view to allowed views', (
    tester,
  ) async {
    final preferences = RestaurantWorkspacePreferencesController(
      initialPreferences: const RestaurantWorkspacePreferences(
        view: RestaurantWorkspaceView.kitchen,
        filters: RestaurantWorkspacePanelFilters(menuSearchQuery: 'cheese'),
      ),
    );
    final changes = <RestaurantWorkspacePreferences>[];

    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantWorkspaceScreen(
          preferencesController: preferences,
          initialView: RestaurantWorkspaceView.menu,
          views: const [
            RestaurantWorkspaceView.menu,
            RestaurantWorkspaceView.floor,
          ],
          onPreferencesChanged: changes.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(preferences.selectedView, RestaurantWorkspaceView.menu);
    expect(changes.single.view, RestaurantWorkspaceView.menu);
    expect(changes.single.filters.menuSearchQuery, 'cheese');
    expect(find.text('Menu mix'), findsOneWidget);
    expect(find.text('Kitchen Flow'), findsNothing);
    expect(_menuSignalText('Burnt Cheesecake'), findsOneWidget);
    expect(_menuSignalText('Short Rib Rendang'), findsNothing);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pumpAndSettle();
    preferences.dispose();
  });

  testWidgets('restaurant workspace command reset clears filters and search', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RestaurantWorkspaceScreen(
          initialView: RestaurantWorkspaceView.menu,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Risk 2'));
    await tester.tap(find.text('Risk 2'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'rendang');
    await tester.pumpAndSettle();

    expect(find.text('2 active lenses'), findsOneWidget);
    expect(_menuSignalText('Short Rib Rendang'), findsOneWidget);
    expect(_menuSignalText('Citrus Pandan Spritz'), findsNothing);

    await tester.ensureVisible(find.widgetWithText(TextButton, 'Reset'));
    await tester.tap(find.widgetWithText(TextButton, 'Reset'));
    await tester.pumpAndSettle();

    expect(find.text('Default operating lens'), findsOneWidget);
    expect(find.text('Workspace controls reset'), findsOneWidget);
    expect(_menuSignalText('Short Rib Rendang'), findsOneWidget);
    expect(_menuSignalText('Citrus Pandan Spritz'), findsOneWidget);
    expect(find.text('All 4'), findsWidgets);
  });

  testWidgets('restaurant workspace command center clears menu search', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RestaurantWorkspaceScreen(
          initialView: RestaurantWorkspaceView.menu,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'cheese');
    await tester.pumpAndSettle();

    expect(find.text('1 active lens'), findsOneWidget);
    expect(find.text('Menu search: cheese'), findsOneWidget);
    expect(_menuSignalText('Burnt Cheesecake'), findsOneWidget);
    expect(_menuSignalText('Short Rib Rendang'), findsNothing);

    await tester.ensureVisible(find.byTooltip('Clear Menu search: cheese'));
    await tester.tap(find.byTooltip('Clear Menu search: cheese'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextField));

    final searchField = tester.widget<TextField>(find.byType(TextField));
    expect(searchField.controller?.text, isEmpty);
    expect(find.text('Default operating lens'), findsOneWidget);
    expect(_menuSignalText('Burnt Cheesecake'), findsOneWidget);
    expect(_menuSignalText('Short Rib Rendang'), findsOneWidget);
  });

  testWidgets('restaurant workspace lens chips navigate to target views', (
    tester,
  ) async {
    final viewChanges = <RestaurantWorkspaceView>[];

    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantWorkspaceScreen(
          initialView: RestaurantWorkspaceView.menu,
          initialFilters: const RestaurantWorkspacePanelFilters(
            reservationSearchQuery: 'Terrace',
          ),
          onViewChanged: viewChanges.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Menu mix'), findsOneWidget);
    expect(find.text('Zone: Terrace'), findsOneWidget);

    await tester.ensureVisible(find.text('Zone: Terrace'));
    await tester.tap(find.text('Zone: Terrace'));
    await tester.pumpAndSettle();

    expect(viewChanges, [RestaurantWorkspaceView.reservations]);
    expect(find.byType(RestaurantReservationPanel), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Terrace'), findsOneWidget);
    expect(find.text('Wijaya Family'), findsWidgets);
    expect(find.text('Sari Putri'), findsNothing);
  });

  testWidgets('restaurant workspace lens chips respect available views', (
    tester,
  ) async {
    final viewChanges = <RestaurantWorkspaceView>[];

    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantWorkspaceScreen(
          initialView: RestaurantWorkspaceView.menu,
          initialFilters: const RestaurantWorkspacePanelFilters(
            reservationSearchQuery: 'Terrace',
          ),
          views: const [RestaurantWorkspaceView.menu],
          onViewChanged: viewChanges.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Menu mix'), findsOneWidget);
    expect(find.text('Zone: Terrace'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        RegExp('Active lens Zone: Terrace.*Reservations unavailable'),
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Zone: Terrace'));
    await tester.tap(find.text('Zone: Terrace'));
    await tester.pumpAndSettle();

    expect(viewChanges, isEmpty);
    expect(find.byType(RestaurantReservationPanel), findsNothing);
    expect(find.text('Menu mix'), findsOneWidget);
  });

  testWidgets('restaurant workspace command center clears reservation search', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RestaurantWorkspaceScreen(
          initialView: RestaurantWorkspaceView.reservations,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final reservationsPanel = find.byType(RestaurantReservationPanel);
    final searchField = find.descendant(
      of: reservationsPanel,
      matching: find.byType(TextField),
    );

    await tester.ensureVisible(searchField);
    await tester.enterText(searchField, 'Terrace');
    await tester.pumpAndSettle();

    expect(find.text('1 active lens'), findsOneWidget);
    expect(find.text('Zone: Terrace'), findsOneWidget);
    expect(
      find.descendant(
        of: reservationsPanel,
        matching: find.text('Wijaya Family'),
      ),
      findsWidgets,
    );
    expect(
      find.descendant(of: reservationsPanel, matching: find.text('Sari Putri')),
      findsNothing,
    );

    await tester.ensureVisible(find.byTooltip('Clear Zone: Terrace'));
    await tester.tap(find.byTooltip('Clear Zone: Terrace'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(searchField);

    final field = tester.widget<TextField>(searchField);
    expect(field.controller?.text, isEmpty);
    expect(find.text('Default operating lens'), findsOneWidget);
    expect(
      find.descendant(
        of: reservationsPanel,
        matching: find.text('Wijaya Family'),
      ),
      findsWidgets,
    );
    expect(
      find.descendant(of: reservationsPanel, matching: find.text('Sari Putri')),
      findsWidgets,
    );
  });
}

Finder _menuSignalText(String text) {
  return find.descendant(
    of: find.byType(RestaurantMenuSignalList),
    matching: find.text(text),
  );
}

Finder _textFieldWithHint(String hintText) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.hintText == hintText,
  );
}

RestaurantReservationStatus _reservationStatus(
  RestaurantWorkspaceController controller,
  String reservationId,
) {
  return controller.state.snapshot!.reservations
      .firstWhere((reservation) => reservation.id == reservationId)
      .status;
}
