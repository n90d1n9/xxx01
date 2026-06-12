import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_presentation_state.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_saved_view.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_table_preferences.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_table_sort.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_table_view_state.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_data_table_surface.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_workspace_selection.dart';
import 'package:kaysir/features/inventory/widgets/inventory_reset_filters_button.dart';
import 'package:kaysir/features/inventory/widgets/inventory_row_actions.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_icon_action_button.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  test('workspace selection snapshot ignores stale product ids', () {
    final snapshot = InventoryProductCatalogWorkspaceSelectionSnapshot.from(
      records: _records,
      selectedProductIds: {'p1', 'missing-product'},
    );

    expect(snapshot.selectedIds, {'p1'});
    expect(snapshot.selectedRecords.map((record) => record.id), ['p1']);
    expect(snapshot.summary.productCount, 1);
    expect(
      snapshot.summary.totalQuantity,
      snapshot.selectedRecords.single.totalQuantity,
    );
  });

  testWidgets('product catalog summary renders reusable metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductCatalogSummaryGrid(summary: _summary),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Tracked'), findsOneWidget);
    expect(find.text('Attention'), findsOneWidget);
    expect(find.text('Stock Value'), findsOneWidget);
  });

  testWidgets('product catalog toolbar emits search and filter changes', (
    tester,
  ) async {
    final searchController = TextEditingController();
    addTearDown(searchController.dispose);
    var query = '';
    var filter = InventoryProductCatalogFilter.all;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return InventoryProductCatalogToolbar(
                searchController: searchController,
                filter: filter,
                records: _records,
                onSearchChanged: (value) => setState(() => query = value),
                onFilterChanged: (value) => setState(() => filter = value),
              );
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'cable');
    await tester.pump();
    expect(query, 'cable');
    expect(find.text('1 matching product'), findsOneWidget);

    await tester.tap(find.text('Attention (1)'));
    await tester.pump();
    expect(filter, InventoryProductCatalogFilter.attention);
  });

  testWidgets('product catalog toolbar can recover search matches by filter', (
    tester,
  ) async {
    final searchController = TextEditingController();
    addTearDown(searchController.dispose);
    var query = '';
    var filter = InventoryProductCatalogFilter.inStock;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return InventoryProductCatalogToolbar(
                searchController: searchController,
                filter: filter,
                records: _records,
                onSearchChanged: (value) => setState(() => query = value),
                onFilterChanged: (value) => setState(() => filter = value),
              );
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'cable');
    await tester.pump();

    expect(query, 'cable');
    expect(find.text('No matching products'), findsOneWidget);
    expect(
      find.text(
        'No results in In stock. 1 matching product available in Attention.',
      ),
      findsOneWidget,
    );
    expect(find.text('Show Attention'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('inventory-product-catalog-show-search-matches-action'),
      ),
    );
    await tester.pump();

    expect(filter, InventoryProductCatalogFilter.attention);
  });

  testWidgets('product catalog presentation badge summarizes active view', (
    tester,
  ) async {
    final customTableState = InventoryProductCatalogPresentationState(
      viewMode: InventoryProductCatalogViewMode.table,
      tableViewState: InventoryProductCatalogTablePreset.pricing.viewState
          .copyWith(
            preferences: InventoryProductCatalogTablePreset.pricing.preferences
                .toggleColumn(InventoryProductCatalogTableOptionalColumn.stock),
          ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              InventoryProductCatalogPresentationBadge(
                presentationState:
                    InventoryProductCatalogPresentationState.defaults,
              ),
              InventoryProductCatalogPresentationBadge(
                presentationState:
                    InventoryProductCatalogPresentationPreset
                        .pricing
                        .presentationState,
              ),
              InventoryProductCatalogPresentationBadge(
                presentationState: customTableState,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('View: Cards'), findsOneWidget);
    expect(find.text('View: Pricing review'), findsOneWidget);
    expect(find.text('Custom table'), findsOneWidget);
  });

  testWidgets('product catalog presentation preset button emits selections', (
    tester,
  ) async {
    InventoryProductCatalogPresentationPreset? selectedPreset;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: InventoryProductCatalogPresentationPresetButton(
              presentationState:
                  InventoryProductCatalogPresentationState.defaults,
              onPresetSelected: (preset) => selectedPreset = preset,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Apply catalog view preset'));
    await tester.pumpAndSettle();

    expect(find.text('Pricing review'), findsOneWidget);
    expect(find.text('Price, value, and margin review'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('inventory-product-catalog-presentation-preset-pricing'),
      ),
    );
    await tester.pumpAndSettle();

    expect(selectedPreset, InventoryProductCatalogPresentationPreset.pricing);
  });

  testWidgets('product catalog saved view button applies and saves views', (
    tester,
  ) async {
    final savedView = InventoryProductCatalogSavedView(
      id: 'pricing-review',
      label: 'Pricing review',
      description: 'Margin review',
      presentationState:
          InventoryProductCatalogPresentationPreset.pricing.presentationState,
    );
    InventoryProductCatalogSavedView? selectedView;
    InventoryProductCatalogSavedView? copiedView;
    InventoryProductCatalogSavedView? renamedView;
    InventoryProductCatalogSavedView? updatedView;
    InventoryProductCatalogSavedView? deletedView;
    InventoryProductCatalogSavedView? defaultView;
    InventoryProductCatalogPresentationState? savedPresentationState;
    InventoryProductCatalogPresentationState? updatedPresentationState;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: InventoryProductCatalogSavedViewButton(
              savedViews: [savedView],
              activeSavedViewId: savedView.id,
              defaultSavedViewId: savedView.id,
              currentPresentationState:
                  InventoryProductCatalogPresentationState.defaults,
              onSelected: (view) => selectedView = view,
              onSaveCurrent: (state) => savedPresentationState = state,
              onCopySavedView: (view) => copiedView = view,
              onRenameSavedView: (view) => renamedView = view,
              onUpdateSavedView: (view, state) {
                updatedView = view;
                updatedPresentationState = state;
              },
              onDeleteSavedView: (view) => deletedView = view,
              onDefaultSavedViewChanged: (view) => defaultView = view,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();

    expect(find.text('Pricing review'), findsOneWidget);
    expect(find.text('Default startup view - Margin review'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    await tester.tap(find.text('Pricing review'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(selectedView?.id, savedView.id);

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey(
          'inventory-product-catalog-copy-saved-view-pricing-review',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(copiedView?.id, savedView.id);

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey(
          'inventory-product-catalog-rename-saved-view-pricing-review',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(renamedView?.id, savedView.id);

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey(
          'inventory-product-catalog-default-saved-view-pricing-review',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(defaultView, isNull);

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey(
          'inventory-product-catalog-update-saved-view-pricing-review',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(updatedView?.id, savedView.id);
    expect(updatedPresentationState?.isDefault, isTrue);

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey(
          'inventory-product-catalog-delete-saved-view-pricing-review',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(deletedView?.id, savedView.id);

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('inventory-product-catalog-save-current-view')),
    );
    await tester.pumpAndSettle();

    expect(savedPresentationState?.isDefault, isTrue);
  });

  testWidgets('product catalog saved view button groups saved views', (
    tester,
  ) async {
    final savedView = InventoryProductCatalogSavedView(
      id: 'pricing-review',
      label: 'Pricing review',
      description: 'Margin review',
      presentationState:
          InventoryProductCatalogPresentationPreset.pricing.presentationState,
    );
    final starterView = InventoryProductCatalogSavedView(
      id: 'starter-core_catalog.omni_retail.omni-readiness',
      label: 'Omni readiness',
      description: 'Channel launch signals',
      presentationState:
          InventoryProductCatalogPresentationPreset
              .channelSignals
              .presentationState,
    );
    InventoryProductCatalogSavedView? selectedView;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: InventoryProductCatalogSavedViewButton(
              savedViews: [savedView, starterView],
              currentPresentationState:
                  InventoryProductCatalogPresentationState.defaults,
              savedViewSectionLabel:
                  (view) =>
                      view.id.startsWith('starter-')
                          ? 'Starter views'
                          : 'My views',
              onSelected: (view) => selectedView = view,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Saved catalog views'));
    await tester.pumpAndSettle();

    expect(find.text('My views'), findsOneWidget);
    expect(find.text('Starter views'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('inventory-product-catalog-saved-view-section-my-views'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey(
          'inventory-product-catalog-saved-view-section-starter-views',
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Omni readiness'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(selectedView?.id, starterView.id);
  });

  testWidgets('product catalog panel renders product tiles', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    InventoryProductCatalogRecord? editedRecord;
    InventoryProductCatalogRecord? duplicatedRecord;
    InventoryProductCatalogRecord? deletedRecord;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductCatalogPanel(
            records: _records,
            totalCount: _records.length,
            onEdit: (record) => editedRecord = record,
            onDuplicate: (record) => duplicatedRecord = record,
            onDelete: (record) => deletedRecord = record,
            recordFooterBuilder:
                (context, record) => Text('Footer ${record.productName}'),
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(InventoryProductCatalogTile), findsNWidgets(4));
    expect(find.text('Adapter'), findsOneWidget);
    expect(find.text('Out of stock'), findsOneWidget);
    expect(find.text('Low stock'), findsOneWidget);
    expect(find.text('Untracked'), findsOneWidget);
    expect(find.text('In stock'), findsOneWidget);
    expect(find.text(r'$1,400.00'), findsOneWidget);
    expect(find.text('Footer Laptop'), findsOneWidget);
    expect(find.text('Footer Cable'), findsOneWidget);
    expect(find.byType(InventoryTileSurface), findsAtLeastNWidgets(4));
    expect(find.byType(InventoryRowActions), findsNWidgets(4));
    expect(find.byType(AppIconActionButton), findsNWidgets(12));

    await tester.ensureVisible(find.byTooltip('Edit Laptop'));
    await tester.pump();
    await tester.tap(find.byTooltip('Edit Laptop'));
    await tester.ensureVisible(find.byTooltip('Duplicate Adapter'));
    await tester.pump();
    await tester.tap(find.byTooltip('Duplicate Adapter'));
    await tester.ensureVisible(find.byTooltip('Delete Cable'));
    await tester.pump();
    await tester.tap(find.byTooltip('Delete Cable'));

    expect(editedRecord?.productName, 'Laptop');
    expect(duplicatedRecord?.productName, 'Adapter');
    expect(deletedRecord?.productName, 'Cable');
  });

  testWidgets('product catalog panel renders advanced table mode', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final selectedIds = <String>{};
    InventoryProductCatalogRecord? editedRecord;
    InventoryProductCatalogRecord? duplicatedRecord;
    InventoryProductCatalogRecord? deletedRecord;
    final viewModeChanges = <InventoryProductCatalogViewMode>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return InventoryProductCatalogPanel(
                records: _records,
                totalCount: _records.length,
                selectedProductIds: selectedIds,
                onSelectionChanged:
                    (record, selected) => setState(() {
                      if (selected) {
                        selectedIds.add(record.id);
                      } else {
                        selectedIds.remove(record.id);
                      }
                    }),
                onSelectVisibleChanged:
                    (selected) => setState(() {
                      if (selected) {
                        selectedIds.addAll(_records.map((record) => record.id));
                      } else {
                        selectedIds.clear();
                      }
                    }),
                onEdit: (record) => editedRecord = record,
                onDuplicate: (record) => duplicatedRecord = record,
                onDelete: (record) => deletedRecord = record,
                onViewModeChanged: viewModeChanges.add,
                recordFooterBuilder:
                    (context, record) => Text('Footer ${record.productName}'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Table'));
    await tester.pumpAndSettle();

    expect(viewModeChanges, [InventoryProductCatalogViewMode.table]);
    expect(find.byType(InventoryDataTableSurface), findsOneWidget);
    expect(find.byType(DataTable), findsOneWidget);
    expect(find.byType(InventoryProductCatalogTile), findsNothing);
    expect(find.text('Operations'), findsOneWidget);
    expect(find.text('Comfort'), findsOneWidget);
    expect(find.text('Compact'), findsOneWidget);
    expect(find.byTooltip('Apply table preset'), findsOneWidget);
    expect(find.byTooltip('Choose table columns'), findsOneWidget);
    expect(find.text('Signals'), findsOneWidget);
    expect(find.text('Footer Laptop'), findsOneWidget);

    await tester.tap(find.byTooltip('Apply table preset'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('inventory-product-table-preset-pricing')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Pricing'), findsOneWidget);
    expect(find.text('Value'), findsOneWidget);
    expect(find.text('Stock'), findsNothing);
    expect(find.text('Signals'), findsNothing);
    expect(find.text('Footer Laptop'), findsNothing);

    await tester.tap(find.byTooltip('Apply table preset'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey('inventory-product-table-preset-channelSignals'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Signals'), findsOneWidget);
    expect(find.text('Channel signals'), findsOneWidget);
    expect(find.text('Footer Laptop'), findsOneWidget);
    expect(find.text('Price'), findsNothing);

    await tester.tap(find.text('Compact'));
    await tester.pumpAndSettle();

    expect(find.text('Custom'), findsOneWidget);

    final compactTable = tester.widget<DataTable>(find.byType(DataTable));
    expect(compactTable.dataRowMinHeight, 56);
    expect(compactTable.dataRowMaxHeight, 88);

    await tester.tap(find.byTooltip('Choose table columns'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('inventory-product-table-column-signals')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Signals'), findsNothing);
    expect(find.text('Footer Laptop'), findsNothing);

    await tester.tap(find.text('Stock'));
    await tester.pump();
    await tester.tap(find.text('Stock'));
    await tester.pump();

    expect(_topOf(tester, 'Laptop') < _topOf(tester, 'Cable'), isTrue);

    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pump();

    expect(selectedIds, {'p1'});

    await tester.ensureVisible(find.byTooltip('Edit Laptop'));
    await tester.pump();
    await tester.tap(find.byTooltip('Edit Laptop'));
    await tester.ensureVisible(find.byTooltip('Duplicate Adapter'));
    await tester.pump();
    await tester.tap(find.byTooltip('Duplicate Adapter'));
    await tester.ensureVisible(find.byTooltip('Delete Cable'));
    await tester.pump();
    await tester.tap(find.byTooltip('Delete Cable'));

    expect(editedRecord?.productName, 'Laptop');
    expect(duplicatedRecord?.productName, 'Adapter');
    expect(deletedRecord?.productName, 'Cable');
  });

  testWidgets('product catalog panel renders contributed table columns', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductCatalogPanel(
            records: _records,
            totalCount: _records.length,
            initialPresentationState:
                const InventoryProductCatalogPresentationState(
                  viewMode: InventoryProductCatalogViewMode.table,
                ),
            tableColumnContributions: const [
              InventoryProductCatalogTableColumnContribution(
                id: 'mode-fit',
                label: 'Mode fit',
                tooltip: 'Business-mode readiness supplied by an extension',
                sectionLabel: 'Mode columns',
                priority: 5,
                cellBuilder: _modeFitCell,
              ),
              InventoryProductCatalogTableColumnContribution(
                id: 'launch-fit',
                label: 'Launch fit',
                tooltip: 'Opt-in launch readiness column',
                sectionLabel: 'Mode columns',
                priority: 10,
                defaultVisible: false,
                cellBuilder: _launchFitCell,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Mode fit'), findsOneWidget);
    expect(find.text('Laptop mode fit'), findsOneWidget);
    expect(find.text('Cable mode fit'), findsOneWidget);
    expect(find.text('Launch fit'), findsNothing);
    expect(find.text('Laptop launch fit'), findsNothing);
    expect(find.text('Signals'), findsOneWidget);
    expect(find.byTooltip('Choose extension columns'), findsOneWidget);

    await tester.tap(find.byTooltip('Choose table columns'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('inventory-product-table-column-signals')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Signals'), findsNothing);
    expect(find.text('Mode fit'), findsOneWidget);
    expect(find.text('Laptop mode fit'), findsOneWidget);
    expect(find.text('Launch fit'), findsNothing);

    await tester.tap(find.byTooltip('Choose extension columns'));
    await tester.pumpAndSettle();
    expect(find.text('Mode columns'), findsOneWidget);
    expect(find.text('Launch fit'), findsOneWidget);
    await tester.tap(
      find.byKey(
        const ValueKey(
          'inventory-product-table-contribution-column-launch-fit',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Launch fit'), findsOneWidget);
    expect(find.text('Laptop launch fit'), findsOneWidget);

    await tester.tap(find.byTooltip('Choose extension columns'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey('inventory-product-table-contribution-column-mode-fit'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mode fit'), findsNothing);
    expect(find.text('Laptop mode fit'), findsNothing);
    expect(find.text('Launch fit'), findsOneWidget);

    await tester.tap(find.byTooltip('Choose extension columns'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey('inventory-product-table-contribution-column-mode-fit'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mode fit'), findsOneWidget);
    expect(find.text('Laptop mode fit'), findsOneWidget);
    expect(find.text('Launch fit'), findsOneWidget);
  });

  testWidgets('product catalog panel accepts persisted table preferences', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final preferenceChanges = <InventoryProductCatalogTablePreferences>[];
    final sortChanges = <InventoryProductCatalogTableSortState>[];
    final viewStateChanges = <InventoryProductCatalogTableViewState>[];
    final presentationChanges = <InventoryProductCatalogPresentationState>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductCatalogPanel(
            records: _records,
            totalCount: _records.length,
            initialPresentationState: InventoryProductCatalogPresentationState(
              viewMode: InventoryProductCatalogViewMode.table,
              tableViewState:
                  InventoryProductCatalogTablePreset.stockControl.viewState,
            ),
            onTablePreferencesChanged: preferenceChanges.add,
            onTableSortStateChanged: sortChanges.add,
            onTableViewStateChanged: viewStateChanges.add,
            onPresentationStateChanged: presentationChanges.add,
            recordFooterBuilder:
                (context, record) => Text('Footer ${record.productName}'),
          ),
        ),
      ),
    );

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Stock control'), findsOneWidget);
    expect(find.text('Stock'), findsOneWidget);
    expect(find.text('Shortage'), findsOneWidget);
    expect(find.text('Signals'), findsOneWidget);
    expect(find.text('Price'), findsNothing);
    expect(_topOf(tester, 'Adapter') < _topOf(tester, 'Cable'), isTrue);

    await tester.tap(find.byTooltip('Apply table preset'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('inventory-product-table-preset-pricing')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pricing'), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Stock'), findsNothing);
    expect(sortChanges, hasLength(1));
    expect(sortChanges.single.column, InventoryProductCatalogTableColumn.price);
    expect(sortChanges.single.ascending, isFalse);
    expect(viewStateChanges, hasLength(1));
    expect(
      viewStateChanges.single.matches(
        InventoryProductCatalogTablePreset.pricing.viewState,
      ),
      isTrue,
    );
    expect(presentationChanges, hasLength(1));
    expect(
      presentationChanges.single.matches(
        InventoryProductCatalogPresentationState(
          viewMode: InventoryProductCatalogViewMode.table,
          tableViewState: InventoryProductCatalogTablePreset.pricing.viewState,
        ),
      ),
      isTrue,
    );

    await tester.tap(find.byTooltip('Choose table columns'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('inventory-product-table-column-stock')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Custom'), findsOneWidget);
    expect(find.text('Stock'), findsOneWidget);
    expect(preferenceChanges, hasLength(2));
    expect(viewStateChanges, hasLength(2));
    expect(presentationChanges, hasLength(2));
    expect(
      preferenceChanges.last.isVisible(
        InventoryProductCatalogTableOptionalColumn.stock,
      ),
      isTrue,
    );
  });

  testWidgets('product catalog panel applies presentation presets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final viewModeChanges = <InventoryProductCatalogViewMode>[];
    final viewStateChanges = <InventoryProductCatalogTableViewState>[];
    final presentationChanges = <InventoryProductCatalogPresentationState>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductCatalogPanel(
            records: _records,
            totalCount: _records.length,
            onViewModeChanged: viewModeChanges.add,
            onTableViewStateChanged: viewStateChanges.add,
            onPresentationStateChanged: presentationChanges.add,
          ),
        ),
      ),
    );

    expect(find.byType(InventoryProductCatalogTile), findsWidgets);
    expect(find.byType(DataTable), findsNothing);
    expect(find.text('View: Cards'), findsOneWidget);

    await tester.tap(find.byTooltip('Apply catalog view preset'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey('inventory-product-catalog-presentation-preset-pricing'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('View: Pricing review'), findsNothing);
    expect(find.text('Pricing'), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Stock'), findsNothing);
    expect(viewModeChanges, [InventoryProductCatalogViewMode.table]);
    expect(viewStateChanges, hasLength(1));
    expect(
      viewStateChanges.single.matches(
        InventoryProductCatalogTablePreset.pricing.viewState,
      ),
      isTrue,
    );
    expect(presentationChanges, hasLength(1));
    expect(
      presentationChanges.single.matches(
        InventoryProductCatalogPresentationPreset.pricing.presentationState,
      ),
      isTrue,
    );

    await tester.tap(find.byTooltip('Apply catalog view preset'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey('inventory-product-catalog-presentation-preset-cards'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsNothing);
    expect(find.byType(InventoryProductCatalogTile), findsWidgets);
    expect(find.text('View: Cards'), findsOneWidget);
    expect(viewModeChanges.last, InventoryProductCatalogViewMode.cards);
    expect(viewStateChanges, hasLength(2));
    expect(presentationChanges, hasLength(2));
    expect(presentationChanges.last.isDefault, isTrue);
  });

  testWidgets('product catalog panel resets presentation state', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final viewModeChanges = <InventoryProductCatalogViewMode>[];
    final preferenceChanges = <InventoryProductCatalogTablePreferences>[];
    final sortChanges = <InventoryProductCatalogTableSortState>[];
    final viewStateChanges = <InventoryProductCatalogTableViewState>[];
    final presentationChanges = <InventoryProductCatalogPresentationState>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductCatalogPanel(
            records: _records,
            totalCount: _records.length,
            initialPresentationState: InventoryProductCatalogPresentationState(
              viewMode: InventoryProductCatalogViewMode.table,
              tableViewState:
                  InventoryProductCatalogTablePreset.pricing.viewState,
            ),
            onViewModeChanged: viewModeChanges.add,
            onTablePreferencesChanged: preferenceChanges.add,
            onTableSortStateChanged: sortChanges.add,
            onTableViewStateChanged: viewStateChanges.add,
            onPresentationStateChanged: presentationChanges.add,
          ),
        ),
      ),
    );

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.byTooltip('Reset catalog view'), findsOneWidget);

    await tester.tap(find.byTooltip('Reset catalog view'));
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsNothing);
    expect(find.byType(InventoryProductCatalogTile), findsWidgets);
    expect(viewModeChanges, [InventoryProductCatalogViewMode.cards]);
    expect(preferenceChanges, hasLength(1));
    expect(
      preferenceChanges.single.matches(
        InventoryProductCatalogPresentationState
            .defaults
            .tableViewState
            .preferences,
      ),
      isTrue,
    );
    expect(sortChanges, hasLength(1));
    expect(
      sortChanges.single.matches(
        InventoryProductCatalogPresentationState
            .defaults
            .tableViewState
            .sortState,
      ),
      isTrue,
    );
    expect(viewStateChanges, hasLength(1));
    expect(
      viewStateChanges.single.matches(
        InventoryProductCatalogPresentationState.defaults.tableViewState,
      ),
      isTrue,
    );
    expect(presentationChanges, hasLength(1));
    expect(presentationChanges.single.isDefault, isTrue);
    expect(find.byTooltip('Reset catalog view'), findsNothing);
  });

  testWidgets('product catalog panel supports bulk row selection', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final selectedIds = <String>{};
    var categoryActionCalled = false;
    var priceActionCalled = false;
    var skuActionCalled = false;
    var shortcutActionCalled = false;
    var descriptionActionCalled = false;
    var deleteActionCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return InventoryProductCatalogPanel(
                records: _records,
                totalCount: _records.length,
                selectedProductIds: selectedIds,
                onSelectionChanged:
                    (record, selected) => setState(() {
                      if (selected) {
                        selectedIds.add(record.id);
                      } else {
                        selectedIds.remove(record.id);
                      }
                    }),
                onSelectVisibleChanged:
                    (selected) => setState(() {
                      if (selected) {
                        selectedIds.addAll(_records.map((record) => record.id));
                      } else {
                        selectedIds.clear();
                      }
                    }),
                onClearSelection: () => setState(selectedIds.clear),
                onBulkChangeCategory: () => categoryActionCalled = true,
                onBulkUpdatePrice: () => priceActionCalled = true,
                onBulkGenerateSku: () => skuActionCalled = true,
                onBulkGenerateShortcut: () => shortcutActionCalled = true,
                onBulkFillDescription: () => descriptionActionCalled = true,
                onBulkDeleteSelected: () => deleteActionCalled = true,
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Select Laptop'));
    await tester.pump();

    expect(selectedIds, {'p1'});
    expect(find.text('1 selected'), findsOneWidget);
    expect(find.text('No attention'), findsOneWidget);
    expect(find.text('14 units'), findsOneWidget);
    expect(find.text(r'$1,400.00'), findsWidgets);
    expect(find.text('1 category'), findsOneWidget);
    expect(find.text('1 missing scan code'), findsOneWidget);
    expect(find.text('Change category'), findsOneWidget);
    expect(find.text('Generate SKU (0)'), findsOneWidget);
    expect(find.text('Generate shortcut (1)'), findsOneWidget);
    expect(find.text('Fill description (0)'), findsOneWidget);

    await tester.tap(find.text('Generate SKU (0)'));
    await tester.pump();
    expect(skuActionCalled, isFalse);

    await tester.tap(find.byTooltip('Select all visible products'));
    await tester.pump();

    expect(selectedIds.length, _records.length);
    expect(find.text('4 selected'), findsOneWidget);
    expect(find.text('3 attention items'), findsOneWidget);
    expect(find.text('16 units'), findsOneWidget);
    expect(find.text(r'$1,450.00'), findsOneWidget);
    expect(find.text('3 categories'), findsOneWidget);
    expect(find.text('3 missing descriptions'), findsOneWidget);
    expect(find.text('4 missing scan codes'), findsOneWidget);
    expect(find.text('8 shortages'), findsOneWidget);

    await tester.tap(find.text('Change category'));
    await tester.pump();
    expect(categoryActionCalled, isTrue);

    await tester.tap(find.text('Update price'));
    await tester.pump();
    expect(priceActionCalled, isTrue);

    await tester.tap(find.text('Generate SKU (0)'));
    await tester.pump();
    expect(skuActionCalled, isFalse);

    await tester.tap(find.text('Generate shortcut (4)'));
    await tester.pump();
    expect(shortcutActionCalled, isTrue);

    await tester.tap(find.text('Fill description (3)'));
    await tester.pump();
    expect(descriptionActionCalled, isTrue);

    await tester.tap(find.text('Delete selected'));
    await tester.pump();
    expect(deleteActionCalled, isTrue);

    await tester.tap(find.text('Clear'));
    await tester.pump();

    expect(selectedIds, isEmpty);
    expect(find.text('Change category'), findsNothing);
  });

  testWidgets('product catalog panel quick selects repair candidates', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final selectedIds = <String>{};

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return InventoryProductCatalogPanel(
                records: _records,
                totalCount: _records.length,
                selectedProductIds: selectedIds,
                onSelectionChanged:
                    (record, selected) => setState(() {
                      if (selected) {
                        selectedIds.add(record.id);
                      } else {
                        selectedIds.remove(record.id);
                      }
                    }),
                onSelectVisibleChanged:
                    (selected) => setState(() {
                      if (selected) {
                        selectedIds.addAll(_records.map((record) => record.id));
                      } else {
                        selectedIds.clear();
                      }
                    }),
                onSelectRepairCandidates:
                    (target) => setState(() {
                      selectedIds
                        ..clear()
                        ..addAll(
                          _records
                              .where(
                                (record) =>
                                    inventoryProductCatalogRecordNeedsRepair(
                                      record,
                                      target,
                                    ),
                              )
                              .map((record) => record.id),
                        );
                    }),
                onClearSelection: () => setState(selectedIds.clear),
                onBulkChangeCategory: () {},
                onBulkFillDescription: () {},
                onBulkDeleteSelected: () {},
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Repair candidates'), findsOneWidget);
    expect(find.text('Quality issues (4)'), findsOneWidget);
    expect(find.text('Missing descriptions (3)'), findsOneWidget);
    expect(find.text('Missing scan codes (4)'), findsOneWidget);

    await tester.tap(find.text('Quality issues (4)'));
    await tester.pump();

    expect(selectedIds, {'p1', 'p2', 'p3', 'p4'});
    expect(find.text('Repair candidates'), findsNothing);
    expect(find.text('4 selected'), findsOneWidget);

    await tester.tap(find.text('Clear'));
    await tester.pump();

    expect(selectedIds, isEmpty);
    expect(find.text('Repair candidates'), findsOneWidget);

    await tester.tap(find.text('Missing descriptions (3)'));
    await tester.pump();

    expect(selectedIds, {'p2', 'p3', 'p4'});
    expect(find.text('Repair candidates'), findsNothing);
    expect(find.text('3 selected'), findsOneWidget);
    expect(find.text('Fill description (3)'), findsOneWidget);
  });

  testWidgets('product catalog panel shows empty state', (tester) async {
    var resetCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductCatalogPanel(
            records: const [],
            totalCount: 4,
            onResetFilters: () => resetCalled = true,
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.byType(InventoryResetFiltersButton), findsOneWidget);
    expect(find.text('No products found'), findsOneWidget);

    await tester.tap(find.text('Reset filters'));
    await tester.pump();

    expect(resetCalled, isTrue);
  });
}

double _topOf(WidgetTester tester, String text) {
  return tester.getTopLeft(find.text(text)).dy;
}

Widget _modeFitCell(
  BuildContext context,
  InventoryProductCatalogRecord record,
) {
  return Text('${record.productName} mode fit');
}

Widget _launchFitCell(
  BuildContext context,
  InventoryProductCatalogRecord record,
) {
  return Text('${record.productName} launch fit');
}

final _products = [
  Product(
    id: 'p1',
    name: 'Laptop',
    sku: 'LT-001',
    category: 'Electronics',
    description: 'Workstation',
    price: 100,
  ),
  Product(
    id: 'p2',
    name: 'Cable',
    sku: 'CB-001',
    category: 'Accessories',
    price: 25,
  ),
  Product(
    id: 'p3',
    name: 'Adapter',
    sku: 'AD-001',
    category: 'Accessories',
    price: 20,
  ),
  Product(
    id: 'p4',
    name: 'Notebook',
    sku: 'NB-001',
    category: 'Stationery',
    price: 5,
  ),
];

final _warehouses = [
  Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
  Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
];

final _records = buildInventoryProductCatalogRecords(
  products: _products,
  stockRecords: buildInventoryStockRecords(
    products: _products,
    warehouses: _warehouses,
    inventoryItems: [
      InventoryItem(
        id: 'i1',
        productId: 'p1',
        warehouseId: 'w1',
        currentQuantity: 10,
        reorderPoint: 5,
        reorderQuantity: 10,
      ),
      InventoryItem(
        id: 'i2',
        productId: 'p1',
        warehouseId: 'w2',
        currentQuantity: 4,
        reorderPoint: 2,
        reorderQuantity: 6,
      ),
      InventoryItem(
        id: 'i3',
        productId: 'p2',
        warehouseId: 'w1',
        currentQuantity: 2,
        reorderPoint: 5,
        reorderQuantity: 10,
      ),
      InventoryItem(
        id: 'i4',
        productId: 'p3',
        warehouseId: 'w1',
        currentQuantity: 0,
        reorderPoint: 5,
        reorderQuantity: 10,
      ),
    ],
  ),
);

final _summary = summarizeInventoryProductCatalogRecords(_records);
