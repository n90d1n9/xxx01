import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/icon_label_chip.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_registry_insight_widgets.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_registry_metric_chip.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_registry_text_chip.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/text_badge.dart';

void main() {
  testWidgets('ProfileRegistryMetricWrap renders profile shape metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileRegistryMetricWrap(
            profile: ProductProfile.marketplaceOperations,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('profile_registry_metric_wrap')),
      findsOneWidget,
    );
    expect(find.byType(ProfileRegistryMetricChip), findsNWidgets(5));
    expect(find.byType(IconLabelChip), findsNWidgets(5));
    expect(find.text('Operations first workspace'), findsOneWidget);
    expect(find.text('3 channels'), findsOneWidget);
    expect(find.text('6 modules'), findsOneWidget);
    expect(find.text('10 rules'), findsOneWidget);
    expect(find.text('4 capabilities'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileRegistryChipSection humanizes and summarizes values', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileRegistryChipSection(
            title: 'Modules',
            values: [
              'checkout',
              'promise_policy',
              '  ',
              'marketplace-queue',
              'fulfillment queue',
            ],
            maxVisible: 2,
            chipKeyPrefix: 'test_registry_chip',
          ),
        ),
      ),
    );

    expect(find.text('Modules'), findsOneWidget);
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Promise Policy'), findsOneWidget);
    expect(find.text('Marketplace Queue'), findsNothing);
    expect(find.text('Fulfillment Queue'), findsNothing);
    expect(find.text('+2 more'), findsOneWidget);
    expect(find.byType(ProfileRegistryTextChip), findsNWidgets(3));
    expect(find.byType(TextBadge), findsNWidgets(3));
    expect(
      find.byKey(const ValueKey('test_registry_chip:checkout')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('test_registry_chip:promise_policy')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileRegistryChipSection stays quiet without values', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileRegistryChipSection(
            title: 'Search keywords',
            values: ['', '   '],
            maxVisible: 3,
            chipKeyPrefix: 'test_empty_registry_chip',
          ),
        ),
      ),
    );

    expect(find.text('Search keywords'), findsNothing);
    expect(find.byType(ProfileRegistryTextChip), findsNothing);
    expect(find.byType(TextBadge), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
