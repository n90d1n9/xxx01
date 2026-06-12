import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/dialog_close_button.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/dialog_header.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/inset_surface.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_picker_dialog.dart';

void main() {
  testWidgets('ProfilePickerDialog filters and selects', (tester) async {
    String? selectedProfileId;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => Scaffold(
                body: TextButton(
                  onPressed:
                      () => showProfilePicker(
                        context: context,
                        profiles: [
                          ProductProfile.standard,
                          ProductProfile.marketplaceOperations,
                        ],
                        activeProfile: ProductProfile.standard,
                        onProfileSelected:
                            (profileId) => selectedProfileId = profileId,
                      ),
                  child: const Text('Open profile picker'),
                ),
              ),
        ),
      ),
    );

    await tester.tap(find.text('Open profile picker'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('profile_picker_dialog')), findsOneWidget);
    expect(find.text('Active profile'), findsOneWidget);
    expect(find.text('Standard commerce'), findsWidgets);
    expect(find.byType(DialogCloseButton), findsOneWidget);
    expect(find.byType(DialogHeader), findsOneWidget);
    expect(find.byType(InsetSurface), findsOneWidget);
    expect(
      find.byKey(const ValueKey('profile_search_suggestions')),
      findsOneWidget,
    );
    expect(find.text('Retail'), findsOneWidget);

    await tester.tap(find.text('Retail'));
    await tester.pumpAndSettle();

    expect(find.text('1 of 2 profiles'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('profile_search_suggestions')),
      findsNothing,
    );

    await tester.enterText(
      find.byKey(const ValueKey('profile_search')),
      'price lists',
    );
    await tester.pumpAndSettle();

    expect(find.text('1 of 2 profiles'), findsOneWidget);
    expect(find.text('Marketplace operations'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('profile_search_match_filters')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('profile_search_match')), findsOneWidget);

    final playbookFilter = find.byKey(
      const ValueKey('profile_search_match_filter_recommendation'),
    );
    await tester.ensureVisible(playbookFilter);
    await tester.pumpAndSettle();
    await tester.tap(playbookFilter);
    await tester.pumpAndSettle();

    expect(
      find.text('Playbook: Add price-list channel coverage'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(
        const ValueKey('profile_option_details_marketplace_operations'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('product_profile_details_dialog')),
      findsOneWidget,
    );
    expect(find.text('Profile details'), findsOneWidget);
    expect(find.text('Price lists'), findsWidgets);

    await tester.tap(
      find.byKey(const ValueKey('product_profile_use_marketplace_operations')),
    );
    await tester.pumpAndSettle();

    expect(selectedProfileId, 'marketplace_operations');
    expect(find.byKey(const ValueKey('profile_picker_dialog')), findsNothing);
    expect(
      find.byKey(const ValueKey('product_profile_details_dialog')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
