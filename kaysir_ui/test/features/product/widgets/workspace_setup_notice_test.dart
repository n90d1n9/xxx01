import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_action.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/widgets/workspace_setup_notice.dart';

void main() {
  testWidgets('workspace setup notice renders resolved action label', (
    tester,
  ) async {
    var pressed = false;
    const target = ProductWorkspaceSetupTarget(
      id: 'restaurant_menu',
      title: 'Restaurant menu setup',
      subtitle: 'Prepare dine-in menu metadata.',
      actionLabel: 'Target label',
    );
    const action = ProductWorkspaceSetupAction(
      targetId: 'restaurant_menu',
      label: 'Open setup',
      routePath: '/products?filter=attention',
      source: ProductWorkspaceSetupActionSource.fallback,
    );
    const prompt = ProductWorkspaceSetupPrompt(target: target, action: action);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductWorkspaceSetupNotice(
            prompt: prompt,
            onActionPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Restaurant menu setup'), findsOneWidget);
    expect(find.text('Prepare dine-in menu metadata.'), findsOneWidget);
    expect(find.text('Active setup'), findsOneWidget);
    expect(find.text('Open setup'), findsOneWidget);
    expect(find.text('Target label'), findsNothing);

    await tester.tap(find.text('Open setup'));

    expect(pressed, isTrue);
  });
}
