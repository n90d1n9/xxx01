import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  testWidgets('shared filter chip bar renders counts and reports changes', (
    tester,
  ) async {
    var selected = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantFilterChipBar<int>(
            selectedValue: selected,
            onChanged: (value) => selected = value,
            options: const [
              RestaurantFilterChipOption(value: 1, label: 'All', count: 3),
              RestaurantFilterChipOption(value: 2, label: 'Open', count: 2),
            ],
          ),
        ),
      ),
    );

    expect(find.text('All 3'), findsOneWidget);
    expect(find.text('Open 2'), findsOneWidget);

    await tester.tap(find.text('Open 2'));
    await tester.pumpAndSettle();

    expect(selected, 2);
  });

  testWidgets('shared summary strip renders title, value, and metrics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RestaurantSummaryStrip(
              title: 'Service watch',
              valueLabel: '2 warm',
              progressValue: .5,
              status: RestaurantServiceStatus.busy,
              metrics: [
                RestaurantSummaryStripMetric(
                  icon: Icons.receipt_long_outlined,
                  label: '20 tickets',
                ),
                RestaurantSummaryStripMetric(
                  icon: Icons.schedule_outlined,
                  label: '12m avg',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Service watch'), findsOneWidget);
      expect(find.text('2 warm'), findsOneWidget);
      expect(find.text('20 tickets'), findsOneWidget);
      expect(find.text('12m avg'), findsOneWidget);
      expect(find.byType(RestaurantSectionSurface), findsOneWidget);
      expect(find.byType(RestaurantSectionHeader), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      final progressSemantics = tester.getSemantics(
        find.byType(LinearProgressIndicator),
      );
      expect(progressSemantics.label, 'Service watch progress, 2 warm');
      expect(progressSemantics.value, '50%');
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('shared progress bar exposes fallback semantics', (tester) async {
    final semantics = tester.ensureSemantics();

    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RestaurantProgressBar(
              value: .43,
              status: RestaurantServiceStatus.busy,
            ),
          ),
        ),
      );

      final progressSemantics = tester.getSemantics(
        find.byType(LinearProgressIndicator),
      );
      expect(progressSemantics.label, 'Busy progress');
      expect(progressSemantics.value, '43%');
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('status menu cluster renders compact status and optional menu', (
    tester,
  ) async {
    RestaurantServiceStatus? selectedStatus;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantStatusMenuCluster(
            status: RestaurantServiceStatus.busy,
            tooltip: 'Change table status',
            onChanged: (status) => selectedStatus = status,
          ),
        ),
      ),
    );

    expect(find.byType(RestaurantStatusPill), findsOneWidget);
    expect(find.byType(RestaurantStatusMenuButton), findsOneWidget);
    expect(find.byTooltip('Change table status'), findsOneWidget);

    await tester.tap(find.byTooltip('Change table status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calm').last);
    await tester.pumpAndSettle();

    expect(selectedStatus, RestaurantServiceStatus.calm);
  });

  testWidgets('shared mini stat groups readable semantics', (tester) async {
    final semantics = tester.ensureSemantics();

    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 76,
              child: RestaurantMiniStat(
                icon: Icons.timer_outlined,
                label: 'Average prep time',
                value: '1234567890m',
                semanticLabel: 'Average prep time, 1234567890 minutes',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Average prep time'), findsOneWidget);
      expect(find.text('1234567890m'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Average prep time, 1234567890 minutes'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('shared signal chip renders optional icon and border', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RestaurantSignalChip(
            label: 'VIP: 2',
            icon: Icons.star_border_rounded,
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            borderColor: Colors.blue,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
    expect(find.text('VIP: 2'), findsOneWidget);

    final decoratedBox = tester.widget<DecoratedBox>(
      find.byType(DecoratedBox).first,
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    final border = decoration.border as Border;
    expect(decoration.color, Colors.white);
    expect(border.top.color, Colors.blue);
  });

  testWidgets('shared icon badge applies color and compact padding', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RestaurantIconBadge(
            icon: Icons.warning_amber_rounded,
            foregroundColor: Colors.black,
            backgroundColor: Colors.yellow,
            iconSize: 17,
            padding: EdgeInsets.all(7),
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.warning_amber_rounded));
    expect(icon.color, Colors.black);
    expect(icon.size, 17);

    final decoratedBox = tester.widget<DecoratedBox>(
      find.byType(DecoratedBox).first,
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    expect(decoration.color, Colors.yellow);

    final padding = tester.widget<Padding>(find.byType(Padding).first);
    expect(padding.padding, const EdgeInsets.all(7));
  });

  testWidgets('shared inline notice renders copy and trailing action', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantInlineNotice(
            icon: Icons.warning_amber_rounded,
            title: 'Stale snapshot',
            message: 'Updated 22m ago',
            backgroundColor: Colors.white,
            borderColor: Colors.blue,
            trailing: TextButton(
              onPressed: () => tapped = true,
              child: const Text('Refresh'),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.text('Stale snapshot'), findsOneWidget);
    expect(find.text('Updated 22m ago'), findsOneWidget);

    final decoratedBox = tester.widget<DecoratedBox>(
      find.byType(DecoratedBox).first,
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    final border = decoration.border as Border;
    expect(decoration.color, Colors.white);
    expect(border.top.color, Colors.blue);

    await tester.tap(find.text('Refresh'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('shared panel header renders badges and trailing actions', (
    tester,
  ) async {
    var refreshed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantPanelHeader(
            title: 'Kitchen flow',
            subtitle: 'Station load and firing pace by lead.',
            leading: const Icon(Icons.soup_kitchen_outlined),
            trailing: IconButton(
              tooltip: 'Refresh panel',
              onPressed: () => refreshed = true,
              icon: const Icon(Icons.refresh_rounded),
            ),
            badges: const [
              RestaurantPanelHeaderBadge(
                icon: Icons.room_service_outlined,
                label: '3 stations',
              ),
              RestaurantPanelHeaderBadge(
                icon: Icons.warning_amber_rounded,
                label: '2 warm',
                status: RestaurantServiceStatus.busy,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Kitchen flow'), findsOneWidget);
    expect(find.text('Station load and firing pace by lead.'), findsOneWidget);
    expect(find.text('3 stations'), findsOneWidget);
    expect(find.text('2 warm'), findsOneWidget);
    expect(find.byType(RestaurantStatusPill), findsOneWidget);
    expect(
      tester.widget<RestaurantStatusPill>(find.byType(RestaurantStatusPill)),
      isA<RestaurantStatusPill>()
          .having((pill) => pill.status, 'status', RestaurantServiceStatus.busy)
          .having((pill) => pill.label, 'label', '2 warm')
          .having((pill) => pill.icon, 'icon', Icons.warning_amber_rounded)
          .having((pill) => pill.compact, 'compact', isTrue),
    );

    await tester.tap(find.byTooltip('Refresh panel'));
    await tester.pump();

    expect(refreshed, isTrue);
  });

  testWidgets('shared interactive surface handles selection and taps', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantInteractiveSurface(
            backgroundColor: Colors.white,
            borderColor: Colors.grey,
            selectedBorderColor: Colors.blue,
            isSelected: true,
            tooltip: 'Open surface',
            onPressed: () => tapped = true,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Surface action'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Surface action'), findsOneWidget);
    expect(find.byTooltip('Open surface'), findsOneWidget);

    final ink = tester.widget<Ink>(find.byType(Ink));
    final decoration = ink.decoration as BoxDecoration;
    final border = decoration.border as Border;
    expect(border.top.color, Colors.blue);
    expect(border.top.width, 1.4);

    await tester.tap(find.text('Surface action'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('shared section surface applies reusable chrome', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RestaurantSectionSurface(
            backgroundColor: Colors.white,
            borderColor: Colors.blue,
            padding: EdgeInsets.all(20),
            child: Text('Section content'),
          ),
        ),
      ),
    );

    expect(find.text('Section content'), findsOneWidget);

    final decoratedBox = tester.widget<DecoratedBox>(
      find.byType(DecoratedBox).first,
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    final border = decoration.border as Border;
    expect(decoration.color, Colors.white);
    expect(border.top.color, Colors.blue);

    final padding = tester.widget<Padding>(find.byType(Padding).first);
    expect(padding.padding, const EdgeInsets.all(20));
  });

  testWidgets('status card surface applies status-aware chrome', (
    tester,
  ) async {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    );
    const statusStyle = RestaurantStatusStyle(
      foreground: Colors.red,
      background: Colors.white,
      icon: Icons.priority_high_rounded,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: const RestaurantStatusCardSurface(
            statusStyle: statusStyle,
            isFocused: true,
            child: Text('Status content'),
          ),
        ),
      ),
    );

    expect(find.text('Status content'), findsOneWidget);
    expect(find.byType(RestaurantSectionSurface), findsOneWidget);

    final decoratedBox = tester.widget<DecoratedBox>(
      find.byType(DecoratedBox).first,
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    final border = decoration.border as Border;
    expect(border.top.color, theme.colorScheme.primary.withValues(alpha: .58));
    expect(border.top.width, 1.6);
  });

  testWidgets('shared section header renders subtitle and trailing label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RestaurantSectionHeader(
            icon: Icons.timeline_rounded,
            title: 'Arrival queue',
            subtitle: 'Reservations due soon.',
            trailingLabel: '12 covers',
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.timeline_rounded), findsOneWidget);
    expect(find.text('Arrival queue'), findsOneWidget);
    expect(find.text('Reservations due soon.'), findsOneWidget);
    expect(find.text('12 covers'), findsOneWidget);
  });

  testWidgets('operational insight grid renders cards and reports selection', (
    tester,
  ) async {
    RestaurantOperationalInsight? selectedInsight;
    final insights = const RestaurantOperationalInsightBuilder()
        .build(restaurantDemoSnapshot)
        .take(2)
        .toList(growable: false);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantOperationalInsightGrid(
            insights: insights,
            selectedInsight: insights.first,
            onInsightSelected: (insight) => selectedInsight = insight,
          ),
        ),
      ),
    );

    expect(find.text('Shift insights'), findsOneWidget);
    expect(find.text('Reservation risk'), findsOneWidget);
    expect(find.text('Recover Wijaya Family'), findsOneWidget);
    expect(find.text('8m late'), findsOneWidget);
    expect(find.text('Menu risk'), findsOneWidget);
    expect(find.text('Protect Short Rib Rendang'), findsOneWidget);
    expect(find.text('72% risk'), findsOneWidget);
    expect(find.byType(RestaurantInteractiveSurface), findsNWidgets(2));
    expect(
      tester
          .widget<RestaurantOperationalInsightCard>(
            find.byType(RestaurantOperationalInsightCard).first,
          )
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<RestaurantOperationalInsightCard>(
            find.byType(RestaurantOperationalInsightCard).last,
          )
          .selected,
      isFalse,
    );

    await tester.tap(find.text('Protect Short Rib Rendang'));
    await tester.pump();

    expect(selectedInsight?.id, 'menu-risk-short-rib-rendang');
    expect(selectedInsight?.targetView, RestaurantWorkspaceView.menu);
    expect(selectedInsight?.targetFilters.menu, RestaurantMenuFilter.risk);
    expect(selectedInsight?.targetFilters.menuSort, RestaurantMenuSort.risk);
  });

  testWidgets(
    'attention signal strip renders ranked cross-functional signals',
    (tester) async {
      final queue = const RestaurantAttentionSignalBuilder().build(
        restaurantDemoSnapshot,
      );
      RestaurantAttentionSignal? selectedSignal;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RestaurantAttentionSignalStrip(
              queue: queue,
              limit: 3,
              selectedSignal: queue.topSignal,
              onSignalSelected: (signal) => selectedSignal = signal,
            ),
          ),
        ),
      );

      expect(find.text('Attention feed'), findsOneWidget);
      expect(find.text('17 signals need attention'), findsOneWidget);
      expect(find.text('Menu risk'), findsOneWidget);
      expect(find.text('Short Rib Rendang'), findsOneWidget);
      expect(find.text('72% risk'), findsOneWidget);
      expect(find.text('Reservation'), findsOneWidget);
      expect(find.text('Wijaya Family'), findsOneWidget);
      expect(find.byType(RestaurantInteractiveSurface), findsNWidgets(3));
      expect(find.byTooltip('Open Menu risk'), findsOneWidget);
      expect(
        tester
            .widget<RestaurantInteractiveSurface>(
              find.byType(RestaurantInteractiveSurface).first,
            )
            .isSelected,
        isTrue,
      );

      await tester.tap(find.text('Short Rib Rendang'));
      await tester.pump();

      expect(selectedSignal?.id, 'menu-risk-short-rib-rendang');
    },
  );

  testWidgets('attention signal strip keeps selected signals visible', (
    tester,
  ) async {
    final queue = const RestaurantAttentionSignalBuilder().build(
      restaurantDemoSnapshot,
    );
    final selectedSignal = queue.attentionSignals.last;

    expect(selectedSignal.id, isNot(queue.topSignal?.id));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantAttentionSignalStrip(
            queue: queue,
            limit: 1,
            selectedSignal: selectedSignal,
          ),
        ),
      ),
    );

    expect(find.text(selectedSignal.title), findsOneWidget);
    expect(find.text(queue.topSignal!.title), findsNothing);
    expect(
      tester
          .widget<RestaurantInteractiveSurface>(
            find.byType(RestaurantInteractiveSurface),
          )
          .isSelected,
      isTrue,
    );
  });

  testWidgets('shared empty state renders optional recovery action', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantEmptyState(
            icon: Icons.filter_alt_off_outlined,
            message: 'No matching records.',
            actionLabel: 'Show all',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('No matching records.'), findsOneWidget);
    expect(find.text('Show all'), findsOneWidget);

    await tester.tap(find.text('Show all'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('shared search field reports text and clear actions', (
    tester,
  ) async {
    var query = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return RestaurantSearchField(
                value: query,
                hintText: 'Search menu items',
                onChanged: (value) => setState(() => query = value),
              );
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'rendang');
    await tester.pump();

    expect(query, 'rendang');
    expect(find.byTooltip('Clear search'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();

    expect(query, isEmpty);
  });

  testWidgets('workspace command bar renders active controls and resets', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var reset = false;
    final clearedLenses = <RestaurantWorkspaceActiveLens>[];
    final selectedLenses = <RestaurantWorkspaceActiveLens>[];

    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RestaurantWorkspaceCommandBar(
              selectedView: RestaurantWorkspaceView.menu,
              filters: const RestaurantWorkspacePanelFilters(
                menu: RestaurantMenuFilter.risk,
                menuSearchQuery: 'cheese',
                reservationSearchQuery: 'Terrace',
              ),
              isRefreshing: true,
              onReset: () => reset = true,
              reservationZoneLabels: const ['Main Floor', 'Terrace'],
              onClearLens: clearedLenses.add,
              onLensSelected: selectedLenses.add,
            ),
          ),
        ),
      );

      expect(find.text('Command center'), findsOneWidget);
      expect(find.text('3 active lenses'), findsOneWidget);
      expect(
        find.byType(RestaurantWorkspaceCommandCenterHeader),
        findsOneWidget,
      );
      expect(find.byType(RestaurantWorkspaceResetControl), findsOneWidget);
      expect(find.text('View: Menu Mix'), findsOneWidget);
      expect(find.text('Lenses: 3 active lenses'), findsOneWidget);
      expect(find.text('Menu: Risk'), findsOneWidget);
      expect(find.text('Menu search: cheese'), findsOneWidget);
      expect(find.text('Zone: Terrace'), findsOneWidget);
      expect(find.text('Refresh: Refreshing'), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          RegExp('Command center.*Menu Mix.*Refresh Refreshing'),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('Reset workspace controls')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Menu search[\s\S]*cheese')),
        findsWidgets,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Zone[\s\S]*Terrace')),
        findsWidgets,
      );
      expect(
        find.bySemanticsLabel(RegExp('Active lens Menu: Risk')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          RegExp('Active lens Menu: Risk.*Already viewing Menu Mix'),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          RegExp('Active lens Zone: Terrace.*Open Reservations'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Zone: Terrace'));
      await tester.pump();

      expect(
        selectedLenses.single.kind,
        RestaurantWorkspaceLensKind.reservationSearch,
      );
      expect(selectedLenses.single.label, 'Zone: Terrace');

      await tester.tap(find.byTooltip('Clear Menu: Risk'));
      await tester.pump();

      expect(clearedLenses.last.kind, RestaurantWorkspaceLensKind.menu);
      expect(clearedLenses.last.label, 'Menu: Risk');

      await tester.tap(find.byTooltip('Clear Menu search: cheese'));
      await tester.pump();

      expect(clearedLenses.last.kind, RestaurantWorkspaceLensKind.menuSearch);
      expect(clearedLenses.last.label, 'Menu search: cheese');

      await tester.tap(find.byTooltip('Clear Zone: Terrace'));
      await tester.pump();

      expect(
        clearedLenses.last.kind,
        RestaurantWorkspaceLensKind.reservationSearch,
      );
      expect(clearedLenses.last.label, 'Zone: Terrace');

      await tester.tap(find.text('Reset'));
      await tester.pump();

      expect(reset, isTrue);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('workspace active lens strip scopes navigation affordances', (
    tester,
  ) async {
    final selectedLenses = <RestaurantWorkspaceActiveLens>[];
    final clearedLenses = <RestaurantWorkspaceActiveLens>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantWorkspaceActiveLensStrip(
            selectedView: RestaurantWorkspaceView.menu,
            availableViews: const [
              RestaurantWorkspaceView.menu,
              RestaurantWorkspaceView.floor,
            ],
            lenses: const [
              RestaurantWorkspaceActiveLens(
                kind: RestaurantWorkspaceLensKind.menu,
                label: 'Menu: Risk',
              ),
              RestaurantWorkspaceActiveLens(
                kind: RestaurantWorkspaceLensKind.floor,
                label: 'Floor: Waitlist',
              ),
              RestaurantWorkspaceActiveLens(
                kind: RestaurantWorkspaceLensKind.reservationSearch,
                label: 'Zone: Terrace',
              ),
            ],
            onSelected: selectedLenses.add,
            onClear: clearedLenses.add,
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(
        RegExp('Active lens Menu: Risk.*Already viewing Menu Mix'),
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        RegExp('Active lens Floor: Waitlist.*Open Floor Plan'),
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        RegExp('Active lens Zone: Terrace.*Reservations unavailable'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Menu: Risk'));
    await tester.pump();
    expect(selectedLenses, isEmpty);

    await tester.tap(find.text('Floor: Waitlist'));
    await tester.pump();
    expect(selectedLenses.single.kind, RestaurantWorkspaceLensKind.floor);

    await tester.tap(find.text('Zone: Terrace'));
    await tester.pump();
    expect(selectedLenses, hasLength(1));

    await tester.tap(find.byTooltip('Clear Zone: Terrace'));
    await tester.pump();
    expect(
      clearedLenses.single.kind,
      RestaurantWorkspaceLensKind.reservationSearch,
    );
  });

  testWidgets('workspace command bar keeps compact signal chips responsive', (
    tester,
  ) async {
    Object? layoutException;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 280,
            child: RestaurantWorkspaceCommandBar(
              selectedView: RestaurantWorkspaceView.menu,
              filters: const RestaurantWorkspacePanelFilters(
                menu: RestaurantMenuFilter.risk,
                menuSearchQuery:
                    'extra long cheese tasting query for service prep review',
              ),
              onReset: () {},
              onClearLens: (_) {},
            ),
          ),
        ),
      ),
    );

    layoutException = tester.takeException();

    expect(layoutException, isNull);
    expect(find.text('Command center'), findsOneWidget);
    expect(find.text('2 active lenses'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Reset'), findsOneWidget);
    expect(find.textContaining('Menu search:'), findsOneWidget);
    expect(
      find.byTooltip(
        'Clear Menu search: extra long cheese tasting query for service prep review',
      ),
      findsOneWidget,
    );
  });
}
