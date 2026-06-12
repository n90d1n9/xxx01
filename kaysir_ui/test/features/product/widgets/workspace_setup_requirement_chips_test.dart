import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/widgets/workspace_setup_requirement_chips.dart';

void main() {
  testWidgets(
    'setup requirement chips render visible requirements and overflow',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductWorkspaceSetupRequirementChips(
              visibleLimit: 2,
              requirements: [
                ProductWorkspaceSetupRequirement(
                  id: 'expiry_date_data',
                  label: 'Expiry date data',
                  type: ProductWorkspaceSetupRequirementType.data,
                ),
                ProductWorkspaceSetupRequirement(
                  id: 'pull_from_shelf_workflow',
                  label: 'Pull-from-shelf workflow',
                  type: ProductWorkspaceSetupRequirementType.workflow,
                ),
                ProductWorkspaceSetupRequirement(
                  id: 'launch_channel',
                  label: 'Launch channel',
                  type: ProductWorkspaceSetupRequirementType.channel,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Expiry date data'), findsOneWidget);
      expect(find.text('Pull-from-shelf workflow'), findsOneWidget);
      expect(find.text('Launch channel'), findsNothing);
      expect(find.text('+1 more'), findsOneWidget);
    },
  );
}
