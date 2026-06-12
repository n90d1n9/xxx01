import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_field_group.dart';
import 'package:kaysir/features/product/models/management_pack_field_group_progress.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/widgets/management_pack_field_section.dart';

void main() {
  testWidgets('management pack field section groups fields by capability', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final pack = groceryFreshGoodsProductManagementPack;
    final groups = buildProductManagementPackFieldGroups(pack);
    final groupProgress = buildProductManagementPackFieldGroupProgressOverview(
      groups: groups,
      values: const {
        'barcode': '8990001',
        'expiry_date': '2026-07-01',
        'shelf_life_days': '5',
      },
    );
    ProductManagementPackField? selectedField;
    final controllers = {
      for (final field in productManagementPackEditableFields(pack))
        if (field.type != ProductManagementFieldType.toggle)
          field.id: TextEditingController(),
    };
    addTearDown(() {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductManagementPackFieldSection(
              pack: pack,
              textControllers: controllers,
              toggleValues: const {},
              groupProgress: groupProgress,
              onSelectField: (field) {
                selectedField = field;
              },
              onToggleChanged: (_, _) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Grocery Fresh Goods data'), findsOneWidget);
    expect(find.text('7 fields'), findsOneWidget);
    expect(find.text('6 groups'), findsOneWidget);
    expect(find.text('Scan readiness'), findsOneWidget);
    expect(find.text('Stock tracking'), findsOneWidget);
    expect(find.text('Expiry tracking'), findsOneWidget);
    expect(find.text('Batch tracking'), findsOneWidget);
    expect(find.text('Weighted inventory'), findsOneWidget);
    expect(find.text('Freshness queue'), findsOneWidget);
    expect(
      find.text(
        'Identifiers used by scan, checkout, stock count, and kiosk flows.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Review signals used to keep fresh goods safe and sellable.'),
      findsOneWidget,
    );
    expect(find.text('1 required field'), findsNWidgets(2));
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('1 missing required'), findsOneWidget);
    expect(find.text('Optional'), findsNWidgets(4));
    expect(find.text('1/1 required'), findsOneWidget);
    expect(find.text('0/1 required'), findsOneWidget);
    expect(find.text('1/1 filled'), findsOneWidget);
    expect(find.text('1/2 filled'), findsOneWidget);
    expect(find.text('1/6 groups open'), findsOneWidget);
    expect(find.text('7/7 fields shown'), findsOneWidget);
    expect(find.text('1 review group pinned open'), findsOneWidget);
    expect(find.text('All fields'), findsOneWidget);
    expect(find.text('Required only'), findsOneWidget);
    expect(find.byTooltip('Expand all pack field groups'), findsOneWidget);
    expect(
      find.byTooltip('Collapse optional and ready groups'),
      findsOneWidget,
    );
    expect(find.text('Review Batch number'), findsOneWidget);
    expect(find.byTooltip('Show Scan readiness fields'), findsOneWidget);
    expect(find.byTooltip('Show Expiry tracking fields'), findsOneWidget);
    expect(find.byTooltip('Hide Batch tracking fields'), findsNothing);
    expect(find.text('Show fields'), findsNWidgets(5));
    expect(find.text('Barcode'), findsNothing);
    expect(find.text('Expiry date'), findsNothing);
    expect(find.text('Batch number'), findsOneWidget);
    expect(find.text('Shelf life'), findsNothing);
    expect(find.text('Freshness status'), findsNothing);

    final showScanReadinessButton = find.byTooltip(
      'Show Scan readiness fields',
    );
    await tester.ensureVisible(showScanReadinessButton);
    await tester.pumpAndSettle();
    await tester.tap(showScanReadinessButton);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Hide Scan readiness fields'), findsOneWidget);
    expect(find.text('Barcode'), findsOneWidget);

    await tester.tap(find.byTooltip('Hide Scan readiness fields'));
    await tester.pumpAndSettle();

    expect(find.text('Barcode'), findsNothing);

    final expandAllButton = find.byTooltip('Expand all pack field groups');
    await tester.ensureVisible(expandAllButton);
    await tester.pumpAndSettle();
    await tester.tap(expandAllButton);
    await tester.pumpAndSettle();

    expect(find.text('6/6 groups open'), findsOneWidget);
    expect(find.text('Barcode'), findsOneWidget);
    expect(find.text('Expiry date'), findsOneWidget);
    expect(find.text('Shelf life'), findsOneWidget);
    expect(find.text('Freshness status'), findsOneWidget);
    expect(find.text('Hide fields'), findsNWidgets(5));

    final collapseReadyButton = find.byTooltip(
      'Collapse optional and ready groups',
    );
    await tester.ensureVisible(collapseReadyButton);
    await tester.pumpAndSettle();
    await tester.tap(collapseReadyButton);
    await tester.pumpAndSettle();

    expect(find.text('1/6 groups open'), findsOneWidget);
    expect(find.text('Barcode'), findsNothing);
    expect(find.text('Expiry date'), findsNothing);
    expect(find.text('Batch number'), findsOneWidget);
    expect(find.byTooltip('Hide Batch tracking fields'), findsNothing);

    final requiredOnlySegment = find.text('Required only');
    await tester.ensureVisible(requiredOnlySegment);
    await tester.pumpAndSettle();
    await tester.tap(requiredOnlySegment);
    await tester.pumpAndSettle();

    expect(find.text('2/2 groups open'), findsOneWidget);
    expect(find.text('2/7 fields shown'), findsOneWidget);
    expect(find.text('2 review groups pinned open'), findsOneWidget);
    expect(find.text('Scan readiness'), findsNothing);
    expect(find.text('Stock tracking'), findsNothing);
    expect(find.text('Expiry tracking'), findsOneWidget);
    expect(find.text('Batch tracking'), findsOneWidget);
    expect(find.text('Freshness queue'), findsNothing);
    expect(find.text('Expiry date'), findsOneWidget);
    expect(find.text('Batch number'), findsOneWidget);
    expect(find.text('Barcode'), findsNothing);
    expect(find.text('Shelf life'), findsNothing);
    expect(find.text('Show fields'), findsNothing);

    final allFieldsSegment = find.text('All fields');
    await tester.ensureVisible(allFieldsSegment);
    await tester.pumpAndSettle();
    await tester.tap(allFieldsSegment);
    await tester.pumpAndSettle();

    expect(find.text('1/6 groups open'), findsOneWidget);
    expect(find.text('7/7 fields shown'), findsOneWidget);
    expect(find.text('Scan readiness'), findsOneWidget);
    expect(find.text('Barcode'), findsNothing);
    expect(find.text('Batch number'), findsOneWidget);

    final reviewBatchButton = find.widgetWithText(
      OutlinedButton,
      'Review Batch number',
    );
    await tester.ensureVisible(reviewBatchButton);
    await tester.pumpAndSettle();
    await tester.tap(reviewBatchButton);
    await tester.pump();

    expect(selectedField?.id, ProductManagementFieldId.batchNumber);
  });

  testWidgets('management pack field section keeps invalid groups reviewable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final pack = groceryFreshGoodsProductManagementPack;
    final groups = buildProductManagementPackFieldGroups(pack);
    final groupProgress = buildProductManagementPackFieldGroupProgressOverview(
      groups: groups,
      values: const {'expiry_date': 'soon', 'batch_number': 'B-01'},
    );
    ProductManagementPackField? selectedField;
    final controllers = {
      for (final field in productManagementPackEditableFields(pack))
        if (field.type != ProductManagementFieldType.toggle)
          field.id: TextEditingController(),
    };
    addTearDown(() {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductManagementPackFieldSection(
              pack: pack,
              textControllers: controllers,
              toggleValues: const {},
              groupProgress: groupProgress,
              onSelectField: (field) {
                selectedField = field;
              },
              onToggleChanged: (_, _) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('1/6 groups open'), findsOneWidget);
    expect(find.text('1 review group pinned open'), findsOneWidget);
    expect(find.text('1 invalid'), findsOneWidget);
    expect(find.text('Review Expiry date'), findsOneWidget);
    expect(find.text('Expiry date'), findsOneWidget);
    expect(find.text('Batch number'), findsNothing);
    expect(find.byTooltip('Hide Expiry tracking fields'), findsNothing);

    final reviewExpiryButton = find.widgetWithText(
      OutlinedButton,
      'Review Expiry date',
    );
    await tester.ensureVisible(reviewExpiryButton);
    await tester.pumpAndSettle();
    await tester.tap(reviewExpiryButton);
    await tester.pump();

    expect(selectedField?.id, ProductManagementFieldId.expiryDate);
  });

  testWidgets(
    'management pack field section recovers from empty required-only mode',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(760, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final pack = _optionalOnlyProductManagementPack;
      final controllers = {
        for (final field in productManagementPackEditableFields(pack))
          if (field.type != ProductManagementFieldType.toggle)
            field.id: TextEditingController(),
      };
      addTearDown(() {
        for (final controller in controllers.values) {
          controller.dispose();
        }
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductManagementPackFieldSection(
                pack: pack,
                textControllers: controllers,
                toggleValues: const {},
                onToggleChanged: (_, _) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Optional Service Pack data'), findsOneWidget);
      expect(find.text('1/1 groups open'), findsOneWidget);
      expect(find.text('1/1 fields shown'), findsOneWidget);
      expect(find.text('Barcode'), findsOneWidget);

      await tester.tap(find.text('Required only'));
      await tester.pumpAndSettle();

      expect(find.text('No required pack fields'), findsOneWidget);
      expect(
        find.text(
          'This pack only adds optional product attributes. Switch back to all fields to review them.',
        ),
        findsOneWidget,
      );
      expect(find.text('Show all fields'), findsOneWidget);
      expect(find.text('Barcode'), findsNothing);

      await tester.tap(find.text('Show all fields'));
      await tester.pumpAndSettle();

      expect(find.text('No required pack fields'), findsNothing);
      expect(find.text('1/1 groups open'), findsOneWidget);
      expect(find.text('1/1 fields shown'), findsOneWidget);
      expect(find.text('Barcode'), findsOneWidget);
    },
  );

  testWidgets('management pack field section opens a focused optional field', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final pack = groceryFreshGoodsProductManagementPack;
    final groups = buildProductManagementPackFieldGroups(pack);
    final groupProgress = buildProductManagementPackFieldGroupProgressOverview(
      groups: groups,
      values: const {
        'barcode': '8990001',
        'expiry_date': '2026-07-01',
        'shelf_life_days': '5',
      },
    );
    final controllers = {
      for (final field in productManagementPackEditableFields(pack))
        if (field.type != ProductManagementFieldType.toggle)
          field.id: TextEditingController(),
    };
    addTearDown(() {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    });

    ProductManagementFieldId? focusedFieldId;
    var focusedFieldRequestVersion = 0;

    Widget buildSubject() {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductManagementPackFieldSection(
              pack: pack,
              textControllers: controllers,
              toggleValues: const {},
              focusedFieldId: focusedFieldId,
              focusedFieldRequestVersion: focusedFieldRequestVersion,
              groupProgress: groupProgress,
              onToggleChanged: (_, _) {},
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Required only'));
    await tester.pumpAndSettle();

    expect(find.text('2/2 groups open'), findsOneWidget);
    expect(find.text('Shelf life'), findsNothing);
    expect(find.text('Freshness queue'), findsNothing);

    focusedFieldId = ProductManagementFieldId.shelfLifeDays;
    focusedFieldRequestVersion += 1;
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('2/6 groups open'), findsOneWidget);
    expect(find.text('7/7 fields shown'), findsOneWidget);
    expect(find.text('Freshness queue'), findsOneWidget);
    expect(find.byTooltip('Hide Freshness queue fields'), findsOneWidget);
    expect(find.text('Shelf life'), findsOneWidget);
    expect(find.text('Freshness status'), findsOneWidget);
  });
}

final _optionalOnlyProductManagementPack = ProductManagementPack(
  id: const ProductManagementPackId('optional_service_pack'),
  title: 'Optional Service Pack',
  subtitle: 'Optional product attributes for service-style catalogs',
  businessModelLabel: 'Service catalog',
  operatorFocusLabel: 'Capture optional lookup metadata',
  profilePacks: [defaultProductSalesChannelProfilePack],
  defaultChannelProfileId: ProductSalesChannelProfileId.omniRetail,
  capabilities: const [ProductManagementCapability.scanReadiness],
  fields: const [
    ProductManagementPackField(
      id: ProductManagementFieldId.barcode,
      label: 'Barcode',
      type: ProductManagementFieldType.text,
      description: 'Optional scan code used when service tickets need lookup.',
      capability: ProductManagementCapability.scanReadiness,
      displayPriority: 10,
    ),
  ],
);
