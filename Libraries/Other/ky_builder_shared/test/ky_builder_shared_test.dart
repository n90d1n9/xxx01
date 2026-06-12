import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

void main() {
  test('catalog filters by category, query, and tags', () {
    final results = websiteBuilderCatalog.search(
      category: 'Commerce',
      query: 'subscription',
    );

    expect(results, hasLength(1));
    expect(results.single.key, 'pricing');
  });

  test('canvas config snaps tabular columns and serializes', () {
    const config = BuilderCanvasConfig(
      canvasWidth: 1200,
      layoutMechanism: BuilderLayoutMechanism.tabularColumns,
      tabularColumnCount: 12,
      tabularColumnGap: 12,
      tabularRowHeight: 64,
    );

    final snappedOffset = config.snapOffset(const Offset(104, 77));
    final snappedSize = config.snapSize(const Size(280, 130));
    final restored = BuilderCanvasConfig.fromJson(config.toJson());

    expect(snappedOffset.dy, 64);
    expect(snappedOffset.dx, config.tabularColumnWidth + 12);
    expect(snappedSize.height, 128);
    expect(restored.layoutMechanism, BuilderLayoutMechanism.tabularColumns);
    expect(restored.tabularColumnCount, 12);
  });

  test('component geometry preserves responsive overrides', () {
    const geometry = BuilderComponentGeometry(
      id: 'hero-1',
      kindKey: 'hero',
      position: Offset(20, 40),
      size: Size(760, 360),
      properties: {'headline': 'Build faster', 'ctaLabel': 'Start now'},
      responsiveOverrides: {
        'mobile': BuilderResponsiveOverride(
          position: Offset(0, 20),
          size: Size(360, 420),
          isVisible: true,
        ),
      },
    );

    final restored = BuilderComponentGeometry.fromJson(geometry.toJson());

    expect(restored.id, 'hero-1');
    expect(restored.properties['headline'], 'Build faster');
    expect(restored.properties['ctaLabel'], 'Start now');
    expect(restored.responsiveOverrides['mobile']?.size, const Size(360, 420));
  });

  test('shared snapshot serializes canvas and components', () {
    const snapshot = BuilderSharedSnapshot(
      id: 'layout-1',
      name: 'Register Layout',
      canvasConfig: BuilderCanvasConfig(
        layoutMechanism: BuilderLayoutMechanism.autoGrid,
      ),
      selectedComponentId: 'button-1',
      components: [
        BuilderComponentGeometry(
          id: 'button-1',
          kindKey: 'custom_button',
          position: Offset(20, 40),
          size: Size(160, 56),
        ),
      ],
    );

    final restored = BuilderSharedSnapshot.fromJson(snapshot.toJson());

    expect(restored.schema, BuilderSharedSnapshot.schemaId);
    expect(restored.name, 'Register Layout');
    expect(restored.componentCount, 1);
    expect(restored.selectedComponentId, 'button-1');
    expect(
      restored.canvasConfig.layoutMechanism,
      BuilderLayoutMechanism.autoGrid,
    );
    expect(restored.components.single.kindKey, 'custom_button');
  });

  testWidgets('library toolbar searches and changes sort', (tester) async {
    var searchQuery = '';
    var submittedQuery = '';
    var sortValue = 'recent';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: KyBuilderLibraryToolbar<String>(
                  searchFieldKey: const ValueKey('shared-toolbar-search'),
                  searchClearKey: const ValueKey('shared-toolbar-clear'),
                  countKey: const ValueKey('shared-toolbar-count'),
                  sortMenuKey: const ValueKey('shared-toolbar-sort'),
                  sortOptionKeyPrefix: 'shared-toolbar-sort',
                  searchQuery: searchQuery,
                  searchHint: 'Search presets',
                  searchInputAction: TextInputAction.done,
                  visibleCount: 2,
                  totalCount: 5,
                  itemLabel: 'preset',
                  itemPluralLabel: 'presets',
                  selectedSortValue: sortValue,
                  sortOptions: const [
                    KyBuilderSortOption(
                      value: 'recent',
                      label: 'Recently saved',
                      keySuffix: 'recent',
                    ),
                    KyBuilderSortOption(
                      value: 'name',
                      label: 'Name A-Z',
                      keySuffix: 'name',
                    ),
                  ],
                  onSearchQueryChanged:
                      (value) => setState(() => searchQuery = value),
                  onSearchSubmitted: (value) => submittedQuery = value,
                  onSortChanged: (value) => setState(() => sortValue = value),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('2 of 5 presets'), findsOneWidget);
    expect(find.text('Recently saved'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('shared-toolbar-search')),
      'quote',
    );
    await tester.pump();

    expect(searchQuery, 'quote');
    expect(find.byKey(const ValueKey('shared-toolbar-clear')), findsOneWidget);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(submittedQuery, 'quote');

    await tester.tap(find.byKey(const ValueKey('shared-toolbar-clear')));
    await tester.pump();

    expect(searchQuery, '');
    expect(find.byKey(const ValueKey('shared-toolbar-clear')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('shared-toolbar-sort')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('shared-toolbar-sort-name')));
    await tester.pumpAndSettle();

    expect(sortValue, 'name');
    expect(find.text('Name A-Z'), findsOneWidget);
  });

  testWidgets('filter chip bar changes selected option', (tester) async {
    var selected = 'All';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: KyBuilderFilterChipBar<String>(
                  optionKeyPrefix: 'shared-filter',
                  options: const ['All', 'Commerce', 'Operations'],
                  selectedValue: selected,
                  labelBuilder: (value) => value,
                  keySuffixBuilder: (value) => value.toLowerCase(),
                  onChanged: (value) => setState(() => selected = value),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(selected, 'All');
    expect(
      tester
          .widget<FilterChip>(find.byKey(const ValueKey('shared-filter-all')))
          .selected,
      isTrue,
    );

    await tester.tap(find.byKey(const ValueKey('shared-filter-operations')));
    await tester.pump();

    expect(selected, 'Operations');
    expect(
      tester
          .widget<FilterChip>(
            find.byKey(const ValueKey('shared-filter-operations')),
          )
          .selected,
      isTrue,
    );
  });

  testWidgets('segmented selector changes selected option', (tester) async {
    var selected = 'replace';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return KyBuilderSegmentedSelector<String>(
                options: const [
                  KyBuilderSegmentOption(
                    value: 'replace',
                    label: 'Replace',
                    icon: Icons.layers_clear_outlined,
                  ),
                  KyBuilderSegmentOption(
                    value: 'append',
                    label: 'Append',
                    icon: Icons.add_to_photos_outlined,
                  ),
                ],
                selectedValue: selected,
                onChanged: (value) => setState(() => selected = value),
              );
            },
          ),
        ),
      ),
    );

    expect(selected, 'replace');
    expect(find.text('Replace'), findsOneWidget);
    expect(find.text('Append'), findsOneWidget);
    expect(find.byIcon(Icons.layers_clear_outlined), findsOneWidget);

    await tester.tap(find.text('Append'));
    await tester.pump();

    expect(selected, 'append');
  });

  testWidgets('library tile renders selected browser rows', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: KyBuilderLibraryTile(
              key: const ValueKey('shared-library-tile'),
              selected: true,
              leading: const Icon(Icons.widgets_outlined),
              title: const Text('Button'),
              subtitle: const Text('Action component'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Button'), findsOneWidget);
    expect(find.text('Action component'), findsOneWidget);
    expect(
      tester.widget<Card>(find.byType(Card)).color,
      Theme.of(
        tester.element(find.text('Button')),
      ).colorScheme.primaryContainer,
    );

    await tester.tap(find.byKey(const ValueKey('shared-library-tile')));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('builder dialog frames content and actions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Builder(
              builder: (context) {
                return FilledButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder:
                          (context) => KyBuilderDialog(
                            title: const Text('Shared dialog'),
                            width: 320,
                            height: 180,
                            content: const SizedBox(
                              key: ValueKey('shared-dialog-content'),
                              child: Text('Dialog body'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                    );
                  },
                  child: const Text('Open dialog'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Shared dialog'), findsOneWidget);
    expect(find.text('Dialog body'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('shared-dialog-content'))),
      const Size(320, 180),
    );
  });

  testWidgets('metric strip renders metric chips', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KyBuilderMetricStrip(
            metrics: [
              KyBuilderMetricItem(
                icon: Icons.add_circle_outline,
                value: '2',
                label: 'new',
              ),
              KyBuilderMetricItem(
                icon: Icons.block,
                value: '1',
                label: 'skipped',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('2'), findsOneWidget);
    expect(find.text('new'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('skipped'), findsOneWidget);
  });

  testWidgets('issue list renders severity rows and actions', (tester) async {
    var fixed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KyBuilderIssueList(
            issues: [
              const KyBuilderIssueItem(
                severity: KyBuilderIssueSeverity.info,
                message: 'Add alternate copy before publishing.',
              ),
              KyBuilderIssueItem(
                severity: KyBuilderIssueSeverity.warning,
                message: 'Hero headline is empty.',
                action: KyBuilderIssueAction(
                  key: const ValueKey('shared-issue-fix'),
                  label: 'Use default headline',
                  onPressed: () => fixed = true,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Add alternate copy before publishing.'), findsOneWidget);
    expect(find.text('Hero headline is empty.'), findsOneWidget);
    expect(find.text('Use default headline'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('shared-issue-fix')));
    await tester.pump();

    expect(fixed, isTrue);
  });

  testWidgets('builder panel frames padded content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KyBuilderPanel(
            key: ValueKey('shared-builder-panel'),
            padding: EdgeInsets.all(12),
            child: Text('Panel body'),
          ),
        ),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(const ValueKey('shared-builder-panel')),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = decoratedBox.decoration as BoxDecoration;

    expect(find.text('Panel body'), findsOneWidget);
    expect(decoration.borderRadius, BorderRadius.circular(8));
    expect(find.byType(Padding), findsOneWidget);
  });

  testWidgets('builder badge renders icon label and trailing content', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KyBuilderBadge(
            key: ValueKey('shared-builder-badge'),
            icon: Icons.info_outline,
            label: 'Core',
            trailing: Text('2'),
            tooltip: 'Built-in preset',
          ),
        ),
      ),
    );

    expect(find.text('Core'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.byTooltip('Built-in preset'), findsOneWidget);
  });

  testWidgets('builder summary section renders metrics issues and details', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KyBuilderSummarySection(
            title: Text('Import summary'),
            subtitle: Text('Register Layout'),
            metrics: [
              KyBuilderMetricItem(
                icon: Icons.file_download_outlined,
                value: '4',
                label: 'imported',
              ),
            ],
            issues: [
              KyBuilderIssueItem(
                severity: KyBuilderIssueSeverity.info,
                message: 'Legacy kinds will be mapped.',
              ),
            ],
            children: [Text('Mapped kinds: image_holder to image')],
          ),
        ),
      ),
    );

    expect(find.text('Import summary'), findsOneWidget);
    expect(find.text('Register Layout'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('imported'), findsOneWidget);
    expect(find.text('Legacy kinds will be mapped.'), findsOneWidget);
    expect(find.text('Mapped kinds: image_holder to image'), findsOneWidget);
  });

  testWidgets('builder detail list renders titled details', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KyBuilderDetailList(
            title: 'Mapped kinds',
            icon: Icons.transform,
            details: ['image_holder to image', 'custom_button to button'],
          ),
        ),
      ),
    );

    expect(find.text('Mapped kinds'), findsOneWidget);
    expect(
      find.text('image_holder to image, custom_button to button'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.transform), findsOneWidget);
  });
}
