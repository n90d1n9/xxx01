import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/product_availability_rule_authoring.dart';
import '../models/product_availability_management.dart';
import '../product_routes.dart';
import '../states/product_availability_management_provider.dart';
import '../states/product_availability_rule_authoring_session_provider.dart';
import '../states/product_availability_rule_template_provider.dart';
import '../states/product_catalog_mutation_bridge.dart';
import '../utils/management_route_mode.dart';
import '../widgets/product_availability_rule_authoring_panel.dart';
import '../widgets/product_availability_rule_authoring_session_strip.dart';
import '../widgets/product_availability_management_panel.dart';
import '../widgets/product_availability_rule_template_source_panel.dart';
import '../widgets/management_suite_screen.dart';

class ProductAvailabilityManagementScreen extends ConsumerStatefulWidget {
  const ProductAvailabilityManagementScreen({super.key});

  @override
  ConsumerState<ProductAvailabilityManagementScreen> createState() =>
      _ProductAvailabilityManagementScreenState();
}

class _ProductAvailabilityManagementScreenState
    extends ConsumerState<ProductAvailabilityManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      unawaited(
        ref
            .read(productAvailabilityRuleAuthoringSessionControllerProvider)
            .hydrate(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProductManagementSuiteScreen(
      title: 'Availability Rules',
      activeDestination:
          ProductManagementSuiteDestination.availabilityManagement,
      modeControlConfig: ProductManagementSuiteModeControlConfig.focused,
      builder: (context, ref, suiteContext) {
        final overview = suiteContext.overview;
        final availabilityOverview = ref.watch(
          productAvailabilityManagementOverviewProvider,
        );
        final templateRegistry = ref.watch(
          productAvailabilityRuleTemplateRegistryProvider,
        );
        final selectedTemplateSourceId = ref.watch(
          productAvailabilityRuleAuthoringEffectiveSourceIdProvider,
        );
        final selectedTemplateId = ref.watch(
          productAvailabilityRuleAuthoringEffectiveTemplateIdProvider,
        );
        final selectedAuthoringTarget = ref.watch(
          productAvailabilityRuleAuthoringEffectiveTargetProvider,
        );
        final authoringSessionSummary = ref.watch(
          productAvailabilityRuleAuthoringSessionSummaryProvider,
        );
        final authoringSessionPersistence = ref.watch(
          productAvailabilityRuleAuthoringSessionPersistenceProvider,
        );
        final authoringSessionController = ref.read(
          productAvailabilityRuleAuthoringSessionControllerProvider,
        );

        return [
          ProductAvailabilityRuleTemplateSourcePanel(
            registry: templateRegistry,
            selectedSourceId: selectedTemplateSourceId,
            onSourceSelected: authoringSessionController.selectSource,
          ),
          ProductAvailabilityRuleAuthoringSessionStrip(
            summary: authoringSessionSummary,
            persistence: authoringSessionPersistence,
            onReset: authoringSessionController.reset,
          ),
          ProductAvailabilityRuleAuthoringPanel(
            records: overview.records,
            templateEntries: templateRegistry.entries,
            selectedSourceId: selectedTemplateSourceId,
            selectedTemplateId: selectedTemplateId,
            selectedTarget: selectedAuthoringTarget,
            onSourceChanged: authoringSessionController.selectSource,
            onTemplateChanged: authoringSessionController.selectTemplate,
            onTargetChanged: authoringSessionController.selectTarget,
            onApply: (plan) => _applyAuthoringPlan(context, ref, plan: plan),
          ),
          ProductAvailabilityManagementPanel(
            overview: availabilityOverview,
            onRuleSelected:
                (rule) => _openRule(
                  context,
                  rule: rule,
                  routeMode: suiteContext.routeMode,
                ),
          ),
        ];
      },
    );
  }
}

void _openRule(
  BuildContext context, {
  required ProductAvailabilityManagementEntry rule,
  required ProductManagementRouteMode routeMode,
}) {
  context.go(
    productRouteWithManagementMode(
      ProductRoutes.catalogUriForReviewTarget(rule.reviewTarget),
      mode: routeMode,
    ),
  );
}

void _applyAuthoringPlan(
  BuildContext context,
  WidgetRef ref, {
  required ProductAvailabilityRuleAuthoringPlan plan,
}) {
  if (!plan.canApply) return;

  final previousProducts = [
    for (final record in plan.changedRecords) record.product,
  ];
  final mutationBridge = ref.read(productCatalogMutationBridgeProvider);
  mutationBridge.upsertProducts(plan.updatedProducts);

  _showAvailabilityAuthoringSnackBar(
    context,
    plan.appliedMessage,
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () => mutationBridge.upsertProducts(previousProducts),
    ),
  );
}

void _showAvailabilityAuthoringSnackBar(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: const Duration(milliseconds: 1800),
      ),
    );
}
