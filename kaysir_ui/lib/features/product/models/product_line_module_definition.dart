import '../../inventory/models/inventory_product_catalog.dart';
import '../product_routes.dart';
import 'management_pack.dart';
import 'management_module_brief.dart';
import 'management_suite_destination.dart';
import 'product_availability_rule_authoring.dart';
import 'product_module_contribution_manifest.dart';
import 'product_workspace_action_contribution.dart';
import 'product_workspace_action_group.dart';
import 'product_workspace_overview.dart';
import 'product_workspace_recommendation.dart';
import 'product_workspace_setup_readiness.dart';
import 'product_workspace_setup_readiness_contribution.dart';
import 'product_workspace_setup_target.dart';
import 'product_workspace_shortcut.dart';
import 'product_workspace_shortcut_intent.dart';

/// Declarative product-line module that generates reusable extension hooks.
class ProductLineModuleDefinition {
  const ProductLineModuleDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.setupTarget,
    required this.workspaceAction,
    required this.recommendation,
    required this.briefAction,
    this.availabilityTemplates = const [],
    this.readinessRules = const [],
    this.activePackIds = const [ProductManagementPackId.coreCatalog],
    this.activeCapabilities = const [],
    this.activeReasonLabel = '',
    this.inactiveReasonLabel = '',
  });

  final String id;
  final String title;
  final String description;
  final ProductWorkspaceSetupTarget setupTarget;
  final ProductLineWorkspaceActionSpec workspaceAction;
  final ProductLineRecommendationSpec recommendation;
  final ProductLineBriefActionSpec briefAction;
  final List<ProductLineAvailabilityTemplateSpec> availabilityTemplates;
  final List<ProductLineSetupReadinessRule> readinessRules;
  final List<ProductManagementPackId> activePackIds;
  final List<ProductManagementCapability> activeCapabilities;
  final String activeReasonLabel;
  final String inactiveReasonLabel;

  String get normalizedId => id.trim();

  String get titleLabel {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isNotEmpty) return normalizedTitle;

    return _readableId(normalizedId);
  }

  String get descriptionLabel => description.trim();
  String get actionContributionId => '${normalizedId}_actions';
  String get setupReadinessContributionId => '${normalizedId}_readiness';
  String get recommendationContributionId => '${normalizedId}_recommendations';
  String get moduleBriefResolverId => '${normalizedId}_brief_action';
  String get availabilityTemplateContributionId =>
      '${normalizedId}_availability_templates';

  bool isActiveFor(ProductManagementPack pack) {
    if (normalizedId.isEmpty) return false;
    if (activePackIds.contains(pack.id)) return true;

    return activeCapabilities.any(pack.hasCapability);
  }

  /// Builds a manifest that can be merged into the shared module registry.
  ProductModuleContributionManifest toManifest() {
    final setupReadinessContribution = toSetupReadinessContribution();

    return ProductModuleContributionManifest(
      id: normalizedId,
      title: titleLabel,
      description: descriptionLabel,
      isActive: isActiveFor,
      activeReasonLabel:
          activeReasonLabel.trim().isEmpty
              ? '$titleLabel product-line module enabled'
              : activeReasonLabel,
      inactiveReasonLabel:
          inactiveReasonLabel.trim().isEmpty
              ? '$titleLabel module is outside this pack scope'
              : inactiveReasonLabel,
      actionContributions: [
        toActionContribution(
          setupReadinessContribution: setupReadinessContribution,
        ),
      ],
      setupReadinessContributions: [setupReadinessContribution],
      recommendationContributions: [toRecommendationContribution()],
      moduleBriefResolvers: [toModuleBriefResolver()],
      availabilityRuleTemplateContributions:
          availabilityTemplates.isEmpty
              ? const []
              : [toAvailabilityTemplateContribution()],
    );
  }

  /// Builds the workspace action hook owned by this product-line module.
  ProductWorkspaceActionContribution toActionContribution({
    ProductWorkspaceSetupReadinessContribution? setupReadinessContribution,
  }) {
    return ProductWorkspaceActionContribution(
      id: actionContributionId,
      isActive: isActiveFor,
      setupTargets: [setupTarget],
      setupReadinessContributions: [
        setupReadinessContribution ?? toSetupReadinessContribution(),
      ],
      buildGroups:
          (pack, summary) => [
            ProductWorkspaceActionGroup(
              id: '${normalizedId}_workflow',
              title: workspaceAction.groupTitle,
              subtitle: workspaceAction.groupSubtitle,
              shortcuts: [
                ProductWorkspaceShortcut(
                  id: workspaceAction.shortcutId,
                  title: workspaceAction.shortcutTitle,
                  subtitle: workspaceAction.shortcutSubtitle,
                  status: workspaceAction.shortcutStatus,
                  intent: ProductWorkspaceShortcutIntent.route(
                    workspaceAction.routePathFor(
                      fallbackPath: ProductRoutes.workspaceSetupUri(
                        setupTarget,
                        pack: pack.id,
                        profile: pack.defaultChannelProfileId,
                      ),
                    ),
                  ),
                  setupIntent: ProductWorkspaceShortcutIntent.route(
                    ProductRoutes.workspaceSetupUri(
                      setupTarget,
                      pack: pack.id,
                      profile: pack.defaultChannelProfileId,
                    ),
                  ),
                ),
              ],
            ),
          ],
    );
  }

  /// Builds setup-readiness wiring for this product-line setup target.
  ProductWorkspaceSetupReadinessContribution toSetupReadinessContribution() {
    return ProductWorkspaceSetupReadinessContribution(
      id: setupReadinessContributionId,
      targetIds: [setupTarget.normalizedId],
      buildRegistry:
          (context) => buildProductLineSetupReadinessEvaluatorRegistry(
            target: setupTarget,
            rules: readinessRules,
            records: context.records,
          ),
    );
  }

  /// Builds the recommendation hook owned by this product-line module.
  ProductWorkspaceRecommendationContribution toRecommendationContribution() {
    return ProductWorkspaceRecommendationContribution(
      id: recommendationContributionId,
      isActive: (context) => isActiveFor(context.managementPack),
      buildRecommendations:
          (context) => [
            ProductWorkspaceRecommendation(
              id: recommendation.idFor(normalizedId),
              title: recommendation.title,
              subtitle: recommendation.subtitle,
              actionLabel: recommendation.actionLabel,
              statusLabel: recommendation.statusLabel,
              priority: recommendation.priority,
              sourceLabel: titleLabel,
              routePath: ProductRoutes.workspaceSetupUri(
                setupTarget,
                pack: context.managementPack.id,
                profile: context.managementPack.defaultChannelProfileId,
              ),
            ),
          ],
    );
  }

  /// Builds the module-brief hook owned by this product-line module.
  ProductManagementModuleBriefResolver toModuleBriefResolver() {
    return ProductManagementModuleBriefResolver(
      id: moduleBriefResolverId,
      title: briefAction.title,
      description: briefAction.description,
      destination: briefAction.destination,
      buildAction:
          (overview) => ProductManagementModuleBriefAction(
            id: briefAction.idFor(normalizedId),
            label: briefAction.label,
            detail: briefAction.detailFor(overview),
            destination: briefAction.actionDestination,
            tone: briefAction.tone,
            routePath: briefAction.routePath,
            contextLabel: titleLabel,
          ),
    );
  }

  /// Builds the availability template hook owned by this product-line module.
  ProductAvailabilityRuleTemplateContribution
  toAvailabilityTemplateContribution() {
    return ProductAvailabilityRuleTemplateContribution(
      id: availabilityTemplateContributionId,
      title: '$titleLabel availability templates',
      isActive: isActiveFor,
      templates: [
        for (final template in availabilityTemplates)
          template.toTemplate(moduleId: normalizedId),
      ],
    );
  }
}

/// Catalog signal that can satisfy a product-line setup requirement.
enum ProductLineSetupReadinessSignal {
  catalogProducts,
  categories,
  pricing,
  scanCodes,
  stockTracking,
  descriptions,
  customAttributes,
}

/// Declarative readiness rule for one product-line setup requirement.
class ProductLineSetupReadinessRule {
  const ProductLineSetupReadinessRule({
    required this.requirementId,
    required this.signal,
    this.attributeKeys = const [],
    this.readyReason = '',
    this.missingReason = '',
  });

  final String requirementId;
  final ProductLineSetupReadinessSignal signal;
  final List<String> attributeKeys;
  final String readyReason;
  final String missingReason;

  String get normalizedRequirementId => requirementId.trim();

  bool get isValid => normalizedRequirementId.isNotEmpty;

  String readyReasonFor(int matchCount) {
    final normalizedReason = readyReason.trim();
    if (normalizedReason.isNotEmpty) return normalizedReason;

    return '${_countLabel(matchCount, 'product')} matched ${signal.label}.';
  }

  String get missingReasonLabel {
    final normalizedReason = missingReason.trim();
    if (normalizedReason.isNotEmpty) return normalizedReason;

    return 'Add catalog data for ${signal.label}.';
  }
}

extension ProductLineSetupReadinessSignalLabels
    on ProductLineSetupReadinessSignal {
  String get label {
    return switch (this) {
      ProductLineSetupReadinessSignal.catalogProducts => 'catalog products',
      ProductLineSetupReadinessSignal.categories => 'category coverage',
      ProductLineSetupReadinessSignal.pricing => 'price coverage',
      ProductLineSetupReadinessSignal.scanCodes => 'scan code coverage',
      ProductLineSetupReadinessSignal.stockTracking => 'stock tracking',
      ProductLineSetupReadinessSignal.descriptions => 'product copy',
      ProductLineSetupReadinessSignal.customAttributes => 'module attributes',
    };
  }
}

/// Builds target-scoped readiness evaluators for a product-line module.
ProductWorkspaceSetupReadinessEvaluatorRegistry
buildProductLineSetupReadinessEvaluatorRegistry({
  required ProductWorkspaceSetupTarget target,
  required List<ProductLineSetupReadinessRule> rules,
  required List<InventoryProductCatalogRecord> records,
}) {
  final snapshot = ProductLineSetupReadinessSnapshot(records: records);
  final evaluators = <String, ProductWorkspaceSetupRequirementEvaluator>{};

  for (final rule in rules) {
    if (!rule.isValid) continue;

    evaluators[ProductWorkspaceSetupReadinessEvaluatorRegistry.targetRequirementKey(
          target.normalizedId,
          rule.normalizedRequirementId,
        )] =
        (context) => snapshot.evaluate(context: context, rule: rule);
  }

  return ProductWorkspaceSetupReadinessEvaluatorRegistry(
    targetRequirementEvaluators: Map.unmodifiable(evaluators),
  );
}

/// Catalog snapshot used by product-line readiness rules.
class ProductLineSetupReadinessSnapshot {
  ProductLineSetupReadinessSnapshot({
    required List<InventoryProductCatalogRecord> records,
  }) : records = List.unmodifiable(records);

  final List<InventoryProductCatalogRecord> records;

  ProductWorkspaceSetupRequirementEvaluation evaluate({
    required ProductWorkspaceSetupRequirementEvaluationContext context,
    required ProductLineSetupReadinessRule rule,
  }) {
    if (!context.requirement.required ||
        context.prompt.isInactive ||
        context.prompt.isCustom) {
      return defaultProductWorkspaceSetupRequirementEvaluator(context);
    }

    final matchCount = countMatches(rule);
    final isReady = matchCount > 0;

    return ProductWorkspaceSetupRequirementEvaluation.fromContext(
      context: context,
      status:
          isReady
              ? ProductWorkspaceSetupRequirementStatus.ready
              : ProductWorkspaceSetupRequirementStatus.missing,
      reason:
          isReady ? rule.readyReasonFor(matchCount) : rule.missingReasonLabel,
    );
  }

  int countMatches(ProductLineSetupReadinessRule rule) {
    return records.where((record) => _recordMatches(record, rule)).length;
  }

  bool _recordMatches(
    InventoryProductCatalogRecord record,
    ProductLineSetupReadinessRule rule,
  ) {
    final product = record.product;

    return switch (rule.signal) {
      ProductLineSetupReadinessSignal.catalogProducts => true,
      ProductLineSetupReadinessSignal.categories => _hasText(product.category),
      ProductLineSetupReadinessSignal.pricing => product.price > 0,
      ProductLineSetupReadinessSignal.scanCodes =>
        _hasText(product.barcode) || _hasText(product.shortcutKey),
      ProductLineSetupReadinessSignal.stockTracking =>
        record.stockLineCount > 0 ||
            (product.stockQuantity ?? 0) > 0 ||
            product.currentStock > 0 ||
            product.systemStock > 0,
      ProductLineSetupReadinessSignal.descriptions => _hasText(
        product.description,
      ),
      ProductLineSetupReadinessSignal.customAttributes => _hasMatchingAttribute(
        product.customAttributes,
        rule.attributeKeys,
      ),
    };
  }
}

/// Workspace shortcut and group copy for a product-line module.
class ProductLineWorkspaceActionSpec {
  const ProductLineWorkspaceActionSpec({
    required this.groupTitle,
    required this.groupSubtitle,
    required this.shortcutTitle,
    required this.shortcutSubtitle,
    required this.shortcutStatus,
    this.shortcutId = ProductWorkspaceShortcutId.setupTargets,
    this.routePath = '',
  });

  final String groupTitle;
  final String groupSubtitle;
  final String shortcutTitle;
  final String shortcutSubtitle;
  final String shortcutStatus;
  final ProductWorkspaceShortcutId shortcutId;
  final String routePath;

  String routePathFor({required String fallbackPath}) {
    final normalizedRoutePath = routePath.trim();
    if (normalizedRoutePath.isNotEmpty) return normalizedRoutePath;

    return fallbackPath;
  }
}

/// Recommendation copy and priority for a product-line module.
class ProductLineRecommendationSpec {
  const ProductLineRecommendationSpec({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.statusLabel,
    this.id = '',
    this.priority = ProductWorkspaceRecommendationPriority.medium,
  });

  final String id;
  final String title;
  final String subtitle;
  final String actionLabel;
  final String statusLabel;
  final ProductWorkspaceRecommendationPriority priority;

  String idFor(String moduleId) {
    final normalizedId = id.trim();
    if (normalizedId.isNotEmpty) return normalizedId;

    return '${moduleId}_setup';
  }
}

/// Product-line next action shown in the management-suite module brief.
class ProductLineBriefActionSpec {
  const ProductLineBriefActionSpec({
    required this.title,
    required this.description,
    required this.label,
    required this.detail,
    required this.destination,
    required this.actionDestination,
    this.id = '',
    this.routePath,
    this.tone = ProductManagementModuleBriefActionTone.info,
  });

  final String id;
  final String title;
  final String description;
  final String label;
  final String detail;
  final ProductManagementSuiteDestination destination;
  final ProductManagementSuiteDestination actionDestination;
  final String? routePath;
  final ProductManagementModuleBriefActionTone tone;

  String idFor(String moduleId) {
    final normalizedId = id.trim();
    if (normalizedId.isNotEmpty) return normalizedId;

    return '${moduleId}_next_step';
  }

  String detailFor(ProductWorkspaceOverview overview) {
    final normalizedDetail = detail.trim();
    if (normalizedDetail.isNotEmpty) return normalizedDetail;

    return overview.launchQueueLabel;
  }
}

/// Availability template descriptor scoped to a product-line module.
class ProductLineAvailabilityTemplateSpec {
  const ProductLineAvailabilityTemplateSpec({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.attributes,
  });

  final String id;
  final String title;
  final String subtitle;
  final Map<String, String> attributes;

  ProductAvailabilityRuleTemplate toTemplate({required String moduleId}) {
    return ProductAvailabilityRuleTemplate(
      id: ProductAvailabilityRuleTemplateId('${moduleId.trim()}_${id.trim()}'),
      title: title,
      subtitle: subtitle,
      attributes: Map.unmodifiable(attributes),
    );
  }
}

String _readableId(String id) {
  final words =
      id
          .split(RegExp(r'[_\-\s]+'))
          .where((part) => part.trim().isNotEmpty)
          .toList();
  if (words.isEmpty) return 'Product line module';

  return words.map(_capitalize).join(' ');
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}

String _capitalize(String value) {
  if (value.isEmpty) return value;

  return '${value[0].toUpperCase()}${value.substring(1)}';
}

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}

bool _hasMatchingAttribute(Map<String, String> attributes, List<String> keys) {
  if (attributes.isEmpty) return false;

  final normalizedKeys =
      keys
          .map((key) => key.trim().toLowerCase())
          .where((key) => key.isNotEmpty)
          .toSet();
  if (normalizedKeys.isEmpty) {
    return attributes.values.any(_hasText);
  }

  return attributes.entries.any((entry) {
    final normalizedKey = entry.key.trim().toLowerCase();

    return normalizedKeys.contains(normalizedKey) && _hasText(entry.value);
  });
}
