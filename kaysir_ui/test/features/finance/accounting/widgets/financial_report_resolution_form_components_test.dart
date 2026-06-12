import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_resolution_form_components.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';

void main() {
  group('financial report resolution form components', () {
    testWidgets('dialog frame validates shared text fields before saving', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      final reviewerController = TextEditingController();
      var cancelCount = 0;
      var saveCount = 0;
      addTearDown(reviewerController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportResolutionDialogFrame(
              header: const Text('Resolution workspace'),
              formKey: formKey,
              onCancel: () => cancelCount += 1,
              onConfirm: () {
                if (formKey.currentState!.validate()) {
                  saveCount += 1;
                }
              },
              children: [
                FinancialReportResolutionTextField(
                  controller: reviewerController,
                  label: 'Reviewer',
                  icon: Icons.verified_user_rounded,
                  validator: financialReportResolutionRequiredValidator,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Resolution workspace'), findsOneWidget);
      expect(find.text('Reviewer'), findsOneWidget);
      expect(find.byType(AppDialogActions), findsOneWidget);

      await tester.tap(find.text('Save Evidence'));
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsOneWidget);
      expect(saveCount, 0);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Reviewer'),
        'Controller',
      );
      await tester.tap(find.text('Save Evidence'));
      await tester.pumpAndSettle();

      expect(saveCount, 1);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(cancelCount, 1);
    });
  });
}
