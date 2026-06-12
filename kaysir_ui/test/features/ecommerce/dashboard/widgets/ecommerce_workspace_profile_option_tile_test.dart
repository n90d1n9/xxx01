import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile_search.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_option_tile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/text_badge.dart';

void main() {
  testWidgets('ProfileOptionTile marks selected profile', (tester) async {
    var selected = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileOptionTile(
            profile: ProductProfile.standard,
            selected: true,
            onSelected: () => selected = true,
          ),
        ),
      ),
    );

    expect(find.text('Standard commerce'), findsOneWidget);
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Omnichannel motion'), findsOneWidget);
    expect(find.text('Standard launch | 18 pts'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('order_workspace_chip_standard')),
      findsOneWidget,
    );
    expect(find.text('Orders'), findsOneWidget);
    expect(
      find.ancestor(of: find.text('Current'), matching: find.byType(TextBadge)),
      findsOneWidget,
    );

    await tester.tap(find.text('Standard commerce'));
    await tester.pump();

    expect(selected, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileOptionTile can show search match', (tester) async {
    final result = productProfileSearchResult(
      profile: ProductProfile.marketplaceOperations,
      query: 'review price lists',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileOptionTile(
            profile: result.profile,
            selected: false,
            searchMatch: result.primaryMatch,
            onSelected: null,
          ),
        ),
      ),
    );

    expect(find.text('Marketplace operations'), findsOneWidget);
    expect(find.text('Marketplace motion'), findsOneWidget);
    expect(find.text('Advanced launch | 23 pts'), findsOneWidget);
    expect(find.text('Orders: Marketplace'), findsOneWidget);
    expect(
      find.text('Playbook: Add price-list channel coverage'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('profile_search_match')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileOptionTile exposes details action', (tester) async {
    var selected = false;
    var detailsRequested = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileOptionTile(
            profile: ProductProfile.marketplaceOperations,
            selected: false,
            onSelected: () => selected = true,
            onDetailsRequested: () => detailsRequested = true,
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(
        const ValueKey('profile_option_details_marketplace_operations'),
      ),
    );
    await tester.pump();

    expect(detailsRequested, isTrue);
    expect(selected, isFalse);
    expect(tester.takeException(), isNull);
  });
}
