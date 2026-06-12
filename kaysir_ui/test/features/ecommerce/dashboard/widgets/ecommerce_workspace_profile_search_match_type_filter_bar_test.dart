import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile_search.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_search_match_type_filter_bar.dart';

void main() {
  testWidgets('ProfileSearchMatchTypeFilterBar toggles match filters', (
    tester,
  ) async {
    Set<ProductProfileSearchMatchType> selectedTypes = {};

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ProfileSearchMatchTypeFilterBar(
                selectedTypes: selectedTypes,
                onChanged:
                    (nextTypes) => setState(() => selectedTypes = nextTypes),
              );
            },
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('profile_search_match_filters')),
      findsOneWidget,
    );
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Order workspace'), findsOneWidget);

    await tester.tap(find.text('Order workspace'));
    await tester.pump();

    expect(selectedTypes, {ProductProfileSearchMatchType.orderWorkspace});

    await tester.tap(find.text('All'));
    await tester.pump();

    expect(selectedTypes, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
