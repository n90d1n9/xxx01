import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile_search.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/icon_label_chip.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_search_match_badge.dart';

void main() {
  testWidgets('ProfileSearchMatchBadge renders summary and tooltip', (
    tester,
  ) async {
    const match = ProductProfileSearchMatch(
      type: ProductProfileSearchMatchType.recommendation,
      label: 'Add price-list channel coverage',
      detail: 'Review price lists',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProfileSearchMatchBadge(match: match)),
      ),
    );

    expect(
      find.text('Playbook: Add price-list channel coverage'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('profile_search_match')), findsOneWidget);
    expect(find.byType(IconLabelChip), findsOneWidget);

    final tooltip = tester.widget<Tooltip>(
      find
          .ancestor(
            of: find.byType(IconLabelChip),
            matching: find.byType(Tooltip),
          )
          .first,
    );
    expect(
      tooltip.message,
      'Playbook match: Add price-list channel coverage - Review price lists',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileSearchMatchBadge omits repeated tooltip detail', (
    tester,
  ) async {
    const match = ProductProfileSearchMatch(
      type: ProductProfileSearchMatchType.salesChannel,
      label: 'Phone order',
      detail: 'Phone order',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProfileSearchMatchBadge(match: match)),
      ),
    );

    final tooltip = tester.widget<Tooltip>(
      find
          .ancestor(
            of: find.byType(IconLabelChip),
            matching: find.byType(Tooltip),
          )
          .first,
    );
    expect(tooltip.message, 'Channel match: Phone order');
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileSearchMatchBadge renders order workspace icon', (
    tester,
  ) async {
    const match = ProductProfileSearchMatch(
      type: ProductProfileSearchMatchType.orderWorkspace,
      label: 'Marketplace Orders',
      detail: 'Marketplace fulfillment',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProfileSearchMatchBadge(match: match)),
      ),
    );

    expect(find.text('Order workspace: Marketplace Orders'), findsOneWidget);

    final chip = tester.widget<IconLabelChip>(find.byType(IconLabelChip));
    expect(chip.icon, Icons.receipt_long_outlined);
    expect(tester.takeException(), isNull);
  });
}
