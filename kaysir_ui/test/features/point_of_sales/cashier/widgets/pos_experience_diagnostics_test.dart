import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_profiles.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_action_policy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_command_action_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_product_runtime_pack_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_shell_shortcut_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_command_actions.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_shell_shortcuts.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_experience_diagnostics.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_layout_strategy_host.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_layout_strategy_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_layout_strategy_pack_provider.dart';

void main() {
  testWidgets('diagnostics button opens the active POS mode summary', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: POSExperienceDiagnosticsButton(
              viewportWidth: 1280,
              layoutPreference: POSLayoutPreference.auto,
              resolvedStrategy: POSLayoutStrategy.counter,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('POS diagnostics'));
    await tester.pumpAndSettle();

    expect(find.text('POS mode diagnostics'), findsOneWidget);
    expect(find.text('Ready'), findsWidgets);
    expect(find.text('Readiness'), findsOneWidget);
    expect(find.text('Pack'), findsWidgets);
    expect(find.text('Pack health'), findsOneWidget);
    expect(find.text('Support handoff'), findsOneWidget);
    expect(find.text('Handoff summary'), findsOneWidget);
    expect(find.text('Runtime pack'), findsOneWidget);
    expect(find.text('Kaysir Core POS'), findsWidgets);
    expect(find.text('Runtime pack wiring valid.'), findsOneWidget);
    expect(find.text('Product'), findsOneWidget);
    expect(find.text('Profile catalog'), findsOneWidget);
    expect(find.text('Product catalog'), findsOneWidget);
    expect(
      find.text('Product profile catalog contract valid.'),
      findsOneWidget,
    );
    expect(find.text('Channel'), findsWidgets);
    expect(find.text('In-store'), findsWidgets);
    expect(find.text('Commerce channel'), findsOneWidget);
    expect(find.text('Commerce channel contracts valid.'), findsOneWidget);
    expect(find.text('Switch attempts'), findsOneWidget);
    expect(find.text('No switch attempts yet'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('No POS activity yet'), findsOneWidget);
    expect(find.text('Kaysir Core Cashier'), findsOneWidget);
    expect(find.text('Launch'), findsOneWidget);
    expect(find.text('Launch checklist'), findsOneWidget);
    expect(find.text('0 blockers / 0 review items'), findsOneWidget);
    expect(find.text('Registry contract'), findsOneWidget);
    expect(find.text('Mode passes registry validation.'), findsOneWidget);
    expect(find.text('Screen'), findsOneWidget);
    expect(find.text('Desktop / Supported'), findsOneWidget);
    expect(find.text('Runtime fit'), findsOneWidget);
    expect(find.text('Layout strategy'), findsOneWidget);
    expect(find.text('Layout health'), findsOneWidget);
    expect(find.text('Strategy and renderer contracts valid.'), findsOneWidget);
    expect(find.text('Shortcuts'), findsOneWidget);
    expect(find.text('Commands'), findsOneWidget);
    expect(find.text('Catalog + Order + Commands'), findsOneWidget);
    expect(find.text('catalog-first, split-pane, desktop'), findsOneWidget);
    expect(find.textContaining('enabled actions are backed'), findsOneWidget);
    expect(find.text('Standard Cashier'), findsOneWidget);
    expect(find.text('Kaysir Core'), findsWidgets);
    expect(find.text('General commerce'), findsOneWidget);
    expect(find.text('Stable'), findsOneWidget);
    expect(find.text('Data contracts'), findsWidgets);
    expect(find.text('Product id, Product name, Price'), findsOneWidget);
    expect(find.text('Catalog browsing'), findsOneWidget);
    expect(find.text('Payments'), findsWidgets);
    expect(find.text('Actions'), findsOneWidget);
    expect(find.text('Available'), findsWidgets);
    expect(find.text('Module payments'), findsOneWidget);
    expect(find.text('Catalog'), findsWidgets);
    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets('diagnostics button marks fallback mode warnings', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedPOSExperienceIdProvider.overrideWith((ref) => 'missing'),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: POSExperienceDiagnosticsButton(
              viewportWidth: 1280,
              layoutPreference: POSLayoutPreference.auto,
              resolvedStrategy: POSLayoutStrategy.counter,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('POS diagnostics'));
    await tester.pumpAndSettle();

    expect(find.text('Default mode'), findsWidgets);
    expect(find.text(defaultPOSExperience.label), findsOneWidget);
    expect(find.textContaining('not registered'), findsWidgets);
  });

  testWidgets('diagnostics button surfaces injected layout wiring issues', (
    tester,
  ) async {
    final layoutPack = POSLayoutStrategyPack(
      strategyRegistry: defaultPOSLayoutStrategyRegistry,
      rendererRegistry: POSLayoutStrategyRendererRegistry(renderers: const []),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          posLayoutStrategyPackProvider.overrideWithValue(layoutPack),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: const POSExperienceDiagnosticsButton(
              viewportWidth: 1280,
              layoutPreference: POSLayoutPreference.auto,
              resolvedStrategy: POSLayoutStrategy.counter,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('POS diagnostics'));
    await tester.pumpAndSettle();

    expect(find.text('Needs attention'), findsWidgets);
    expect(find.text('Layout issues'), findsOneWidget);
    expect(find.text('Missing renderer'), findsWidgets);
    expect(
      find.textContaining('No POS layout renderer registered'),
      findsWidgets,
    );
  });

  testWidgets('diagnostics button surfaces injected shortcut wiring issues', (
    tester,
  ) async {
    const shortcutRegistry = POSShellShortcutRegistry(
      specs: [
        POSShellShortcutSpec(
          id: 'hold_order',
          label: 'Hold order',
          activator: POSShellShortcutActivators.holdOrder,
          intent: POSShellShortcutIntent.holdOrder,
        ),
        POSShellShortcutSpec(
          id: 'resume_hold',
          label: 'Resume hold',
          activator: POSShellShortcutActivators.holdOrder,
          intent: POSShellShortcutIntent.openHeldOrders,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          posShellShortcutRegistryProvider.overrideWithValue(shortcutRegistry),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: POSExperienceDiagnosticsButton(
              viewportWidth: 1280,
              layoutPreference: POSLayoutPreference.auto,
              resolvedStrategy: POSLayoutStrategy.counter,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('POS diagnostics'));
    await tester.pumpAndSettle();

    expect(find.text('Needs attention'), findsWidgets);
    expect(find.text('Shortcut issues'), findsOneWidget);
    expect(find.text('Duplicate binding'), findsWidgets);
    expect(
      find.textContaining('Duplicate POS shell shortcut binding'),
      findsWidgets,
    );
  });

  testWidgets('diagnostics button surfaces injected command wiring issues', (
    tester,
  ) async {
    const commandRegistry = POSCommandActionRegistry(
      specs: [
        POSCommandActionSpec(
          id: 'scan',
          label: 'Scan',
          icon: Icons.qr_code_scanner,
          intent: POSCommandActionIntent.scan,
          requiredAction: POSExperienceAction.barcodeScanning,
        ),
        POSCommandActionSpec(
          id: 'scan',
          label: 'Scan again',
          icon: Icons.qr_code_scanner,
          intent: POSCommandActionIntent.scan,
          requiredAction: POSExperienceAction.barcodeScanning,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          posCommandActionRegistryProvider.overrideWithValue(commandRegistry),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: POSExperienceDiagnosticsButton(
              viewportWidth: 1280,
              layoutPreference: POSLayoutPreference.auto,
              resolvedStrategy: POSLayoutStrategy.counter,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('POS diagnostics'));
    await tester.pumpAndSettle();

    expect(find.text('Needs attention'), findsWidgets);
    expect(find.text('Command issues'), findsOneWidget);
    expect(find.text('Duplicate ID'), findsWidgets);
    expect(
      find.textContaining('Duplicate POS command action id'),
      findsWidgets,
    );
  });

  testWidgets('diagnostics button surfaces product profile catalog issues', (
    tester,
  ) async {
    final catalog = POSProductProfileCatalog(
      profiles: [corePOSProductProfiles.first.copyWith(id: '')],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          posProductProfileCatalogProvider.overrideWithValue(catalog),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: POSExperienceDiagnosticsButton(
              viewportWidth: 1280,
              layoutPreference: POSLayoutPreference.auto,
              resolvedStrategy: POSLayoutStrategy.counter,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('POS diagnostics'));
    await tester.pumpAndSettle();

    expect(find.text('Needs attention'), findsWidgets);
    expect(find.text('Product catalog issues'), findsOneWidget);
    expect(find.text('Blank profile ID'), findsOneWidget);
    expect(find.text('POS product profile id cannot be blank'), findsOneWidget);
  });

  testWidgets('diagnostics button surfaces runtime pack issues', (
    tester,
  ) async {
    final registry = POSProductRuntimePackRegistry(
      defaultPackId: 'missing_pack',
      packs: [defaultPOSProductRuntimePack],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          posProductRuntimePackRegistryProvider.overrideWithValue(registry),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: POSExperienceDiagnosticsButton(
              viewportWidth: 1280,
              layoutPreference: POSLayoutPreference.auto,
              resolvedStrategy: POSLayoutStrategy.counter,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('POS diagnostics'));
    await tester.pumpAndSettle();

    expect(find.text('Needs attention'), findsWidgets);
    expect(find.text('Runtime pack issues'), findsOneWidget);
    expect(find.text('Missing default'), findsOneWidget);
    expect(find.text('Default pack'), findsWidgets);
    expect(
      find.textContaining('Default POS product runtime pack "missing_pack"'),
      findsOneWidget,
    );
    expect(
      find.textContaining('POS product runtime pack "missing_pack"'),
      findsWidgets,
    );
  });
}
