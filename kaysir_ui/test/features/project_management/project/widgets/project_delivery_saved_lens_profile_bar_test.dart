import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_delivery_saved_lens_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_delivery_saved_lens_profile_bar.dart';

void main() {
  testWidgets('project delivery saved lens profile bar switches roles', (
    tester,
  ) async {
    var profile = ProjectDeliverySavedLensProfile.deliveryLead;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ProjectDeliverySavedLensProfileBar(
                value: profile,
                onChanged:
                    (value) => setState(() {
                      profile = value;
                    }),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Delivery Lead'), findsOneWidget);
    expect(find.text('Finance Partner'), findsOneWidget);
    expect(find.text('Release Desk'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Finance Partner'));
    await tester.pump();

    expect(profile, ProjectDeliverySavedLensProfile.financePartner);
    expect(
      tester
          .widget<ChoiceChip>(
            find.widgetWithText(ChoiceChip, 'Finance Partner'),
          )
          .selected,
      isTrue,
    );
  });
}
