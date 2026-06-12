import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/states/management_workspace_preferences_controller.dart';
import 'package:kaysir/features/product/utils/management_mode_feedback.dart';

void main() {
  final selection = ProductManagementWorkspaceSelection(
    pack: coreProductManagementPack,
    channelProfile: omniRetailProductSalesChannelProfile,
  );

  test('product management mode feedback formats pack and channel', () {
    expect(
      productManagementModeFeedbackMessage(
        label: 'Product mode switched',
        selection: selection,
      ),
      'Product mode switched: Core Catalog / Omni Retail',
    );
  });

  testWidgets('product management mode feedback shows snackbar action', (
    tester,
  ) async {
    var resetCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () => showProductManagementModeFeedback(
                        context,
                        label: 'Product mode switched',
                        selection: selection,
                        action: SnackBarAction(
                          label: 'Reset',
                          onPressed: () => resetCount += 1,
                        ),
                      ),
                  child: const Text('Show feedback'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show feedback'));
    await tester.pump();

    expect(
      find.text('Product mode switched: Core Catalog / Omni Retail'),
      findsOneWidget,
    );

    final action = tester.widget<SnackBarAction>(
      find.widgetWithText(SnackBarAction, 'Reset'),
    );
    action.onPressed();
    await tester.pump();

    expect(resetCount, 1);
  });
}
