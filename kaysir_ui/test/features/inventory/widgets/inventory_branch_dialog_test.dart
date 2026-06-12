import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_branch.dart';
import 'package:kaysir/features/inventory/models/inventory_branch_draft.dart';
import 'package:kaysir/features/inventory/widgets/inventory_branch_dialog.dart';

void main() {
  test('branch form controller bundle creates draft from field values', () {
    final controllers = InventoryBranchFormControllerBundle.fromBranch(_branch);
    addTearDown(controllers.dispose);

    controllers.nameController.text = 'Jakarta Expansion';
    controllers.cityController.text = 'Jakarta';
    controllers.managerController.text = 'Rina Wijaya';
    controllers.contactController.text = 'rina@example.test';
    controllers.codeController.text = 'JKT-EX';
    controllers.regionController.text = 'Java West';
    controllers.legalEntityController.text = 'PT Kaysir Nusantara';
    controllers.employeeCountController.text = '64';
    controllers.notesController.text = 'Expanded branch mandate';
    controllers.type = InventoryBranchType.fulfillmentHub;
    controllers.complianceTier = InventoryBranchComplianceTier.monitored;
    controllers.status = InventoryBranchStatus.planning;

    final draft = controllers.toDraft();

    expect(draft.name, 'Jakarta Expansion');
    expect(draft.code, 'JKT-EX');
    expect(draft.employeeCount, 64);
    expect(draft.type, InventoryBranchType.fulfillmentHub);
    expect(draft.complianceTier, InventoryBranchComplianceTier.monitored);
    expect(draft.status, InventoryBranchStatus.planning);
    expect(draft.notes, 'Expanded branch mandate');
  });

  testWidgets('branch dialog submits a valid draft', (tester) async {
    await _setLargeSurface(tester);

    InventoryBranchDraft? submittedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryBranchDialog(
            onSubmit: (draft) => submittedDraft = draft,
          ),
        ),
      ),
    );

    expect(find.byType(InventoryBranchFormFields), findsOneWidget);
    expect(find.byType(InventoryBranchIdentityFields), findsOneWidget);
    expect(find.byType(InventoryBranchContactFields), findsOneWidget);
    expect(find.byType(InventoryBranchGovernanceTextFields), findsOneWidget);
    expect(find.byType(InventoryBranchNotesField), findsOneWidget);
    expect(find.byType(InventoryBranchGovernanceFields), findsOneWidget);
    expect(find.byType(InventoryBranchTypeField), findsOneWidget);
    expect(find.byType(InventoryBranchComplianceTierField), findsOneWidget);
    expect(find.byType(InventoryBranchStatusField), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Bandung Retail');
    await tester.enterText(fields.at(1), 'Bandung');
    await tester.enterText(fields.at(2), 'Maya Lestari');
    await tester.enterText(fields.at(3), 'bandung.ops@kaysir.local');
    await tester.enterText(fields.at(4), 'BDG-RT');
    await tester.enterText(fields.at(5), 'Java West');
    await tester.enterText(fields.at(6), 'PT Kaysir Retail Indonesia');
    await tester.enterText(fields.at(7), '18');
    await tester.enterText(fields.at(8), 'New retail branch');
    await tester.ensureVisible(find.text('Active'));
    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Planning').last);
    await tester.pumpAndSettle();
    final addButton = find.widgetWithText(FilledButton, 'Add branch');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(submittedDraft?.name, 'Bandung Retail');
    expect(submittedDraft?.code, 'BDG-RT');
    expect(submittedDraft?.region, 'Java West');
    expect(submittedDraft?.legalEntity, 'PT Kaysir Retail Indonesia');
    expect(submittedDraft?.employeeCount, 18);
    expect(submittedDraft?.status, InventoryBranchStatus.planning);
    expect(submittedDraft?.notes, 'New retail branch');
  });

  testWidgets('branch dialog blocks missing required values', (tester) async {
    await _setLargeSurface(tester);

    var submitted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryBranchDialog(onSubmit: (_) => submitted = true),
        ),
      ),
    );

    final addButton = find.widgetWithText(FilledButton, 'Add branch');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(submitted, isFalse);
    expect(find.text('Enter a branch name'), findsOneWidget);
  });

  testWidgets('branch delete dialog blocks assigned branches', (tester) async {
    await _setLargeSurface(tester);

    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryBranchDeleteDialog(
            branch: _branch,
            assignedWarehouseCount: 2,
            onConfirm: () => deleted = true,
          ),
        ),
      ),
    );

    expect(find.textContaining('Move 2 assigned warehouses'), findsOneWidget);
    final blockedButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Branch in use'),
    );
    expect(blockedButton.onPressed, isNull);
    expect(deleted, isFalse);
  });
}

Future<void> _setLargeSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(900, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

const _branch = InventoryBranch(
  id: 'b1',
  name: 'Jakarta Central',
  city: 'Jakarta',
  managerName: 'Rina Wijaya',
  contact: 'jakarta.ops@kaysir.local',
);
