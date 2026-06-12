import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/registry_diagnostics.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/dialog_close_button.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/dialog_header.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/dialog_section.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/empty_state.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/registry_details_dialog.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_ui.dart';

void main() {
  testWidgets('RegistryDetailsDialog presents healthy diagnostics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistryDetailsDialog(
            diagnostics: RegistryDiagnostics.fromIssues(
              moduleIssues: const [],
              actionRuleIssues: const [],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Registry diagnostics'), findsOneWidget);
    expect(
      find.text(
        'Workspace registries are ready across profiles, modules, and actions.',
      ),
      findsOneWidget,
    );
    expect(find.byType(DialogHeader), findsOneWidget);
    expect(find.byType(DialogSection), findsNWidgets(2));
    expect(find.text('Sources'), findsOneWidget);
    expect(find.text('Issues'), findsOneWidget);
    expect(find.byType(POSMetricPill), findsNWidgets(3));
    expect(find.text('Profiles | Ready'), findsOneWidget);
    expect(find.text('Modules | Ready'), findsOneWidget);
    expect(find.text('Actions | Ready'), findsOneWidget);
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('No registry issues found.'), findsOneWidget);
    expect(find.byType(DialogCloseButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
