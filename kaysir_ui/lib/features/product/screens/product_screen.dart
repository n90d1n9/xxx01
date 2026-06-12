import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../inventory/models/inventory_product_catalog.dart';
import '../../inventory/models/inventory_product_catalog_operation.dart';
import '../../inventory/models/inventory_product_catalog_presentation_state.dart';
import '../../inventory/models/inventory_product_catalog_saved_view.dart';
import '../../inventory/widgets/inventory_product_catalog_workspace.dart';
import '../../inventory/widgets/inventory_product_dialog.dart';
import '../models/product.dart';
import '../models/product_catalog_saved_view_deck.dart';
import '../models/product_catalog_starter_saved_views.dart';
import '../models/product_catalog_quality.dart';
import '../models/management_pack.dart';
import '../models/sales_channel_profile_readiness.dart';
import '../models/sales_channel_readiness.dart';
import '../models/sales_channel_strategy_brief.dart';
import '../repositories/management_pack_preferences_repository.dart';
import '../states/product_catalog_saved_view_contribution_provider.dart';
import '../states/product_catalog_mutation_bridge.dart';
import '../states/product_catalog_table_column_contribution_provider.dart';
import '../states/management_pack_provider.dart';
import '../states/management_workspace_preferences_controller.dart';
import '../states/sales_channel_definition_provider.dart';
import '../utils/product_catalog_review_target.dart';
import '../utils/management_mode_feedback.dart';
import '../utils/management_route_mode.dart';
import '../widgets/product_catalog_channel_readiness_badges.dart';
import '../widgets/product_catalog_quality_badges.dart';
import '../widgets/product_catalog_review_target_strip.dart';
import '../widgets/experience_profile_scope.dart';
import '../widgets/management_mode_status_panel.dart';
import '../widgets/management_suite_navigation.dart';
import '../widgets/sales_channel_profile_selector_panel.dart';
import '../widgets/sales_channel_profile_switch_dialog.dart';
import '../widgets/sales_channel_readiness_strip.dart';
import '../widgets/sales_channel_strategy_brief_panel.dart';
import 'add_edit_product_screen.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({
    super.key,
    this.initialFilter = InventoryProductCatalogFilter.all,
    this.initialQuery = '',
    this.initialReviewTarget,
    this.initialPackId,
    this.initialChannelProfileId,
    this.initialPresentationState,
    this.activeSuiteDestination = ProductManagementSuiteDestination.catalog,
  });

  final InventoryProductCatalogFilter initialFilter;
  final String initialQuery;
  final ProductCatalogReviewTarget? initialReviewTarget;
  final ProductManagementPackId? initialPackId;
  final ProductSalesChannelProfileId? initialChannelProfileId;
  final InventoryProductCatalogPresentationState? initialPresentationState;
  final ProductManagementSuiteDestination activeSuiteDestination;

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  ProductCatalogReviewTarget? _activeReviewTarget;
  late var _catalogPresentationState =
      widget.initialPresentationState?.normalized ??
      const InventoryProductCatalogPresentationState();
  var _catalogSavedViewDeck = ProductCatalogSavedViewDeck.empty;
  String? _activeCatalogSavedViewId;
  String? _defaultCatalogSavedViewId;
  late var _catalogPresentationStateChangedLocally =
      widget.initialPresentationState != null;

  ProductCatalogReviewTarget get _resolvedInitialReviewTarget {
    return widget.initialReviewTarget ??
        ProductCatalogReviewTarget(
          filter: widget.initialFilter,
          query: widget.initialQuery,
        );
  }

  @override
  void initState() {
    super.initState();
    unawaited(_syncInitialProductMode());
  }

  @override
  void didUpdateWidget(covariant ProductsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFilter != widget.initialFilter ||
        oldWidget.initialQuery != widget.initialQuery ||
        oldWidget.initialReviewTarget != widget.initialReviewTarget) {
      _activeReviewTarget = null;
    }
    if (oldWidget.initialPackId != widget.initialPackId ||
        oldWidget.initialChannelProfileId != widget.initialChannelProfileId) {
      unawaited(_syncInitialProductMode());
    }
    if (oldWidget.initialPresentationState != widget.initialPresentationState) {
      final initialPresentationState = widget.initialPresentationState;
      if (initialPresentationState != null) {
        _hydrateInitialCatalogPresentationState(initialPresentationState);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final channelProfiles = ref.watch(productSalesChannelProfilesProvider);
    final channelProfile = ref.watch(productSalesChannelProfileProvider);
    final managementPack = ref.watch(productManagementPackProvider);
    final defaultManagementPack =
        ref.watch(productManagementPackRegistryProvider).fallbackPack;
    final catalogMutationBridge = ref.watch(
      productCatalogMutationBridgeProvider,
    );
    final channelDefinitions = ref.watch(
      productSalesChannelDefinitionsProvider,
    );
    final tableColumnContributions = ref.watch(
      productCatalogTableColumnContributionsProvider,
    );
    final initialTarget = _resolvedInitialReviewTarget;

    return Scaffold(
      appBar: const _ProductsAppBar(),
      body: InventoryProductCatalogWorkspace(
        eyebrow: 'Product Operations',
        title: 'Product Directory',
        initialFilter: initialTarget.filter,
        initialQuery: initialTarget.query,
        onAddProduct: () => _openProductManagementEditor(context),
        onEditProduct:
            (product) =>
                _openProductManagementEditor(context, product: product),
        mutationSync: InventoryProductCatalogMutationSync(
          onProductsUpserted: catalogMutationBridge.upsertProducts,
          onProductIdsDeleted: catalogMutationBridge.deleteProductIds,
        ),
        onOperationCompleted:
            (result) => _showProductCatalogOperationResult(context, result),
        initialPresentationState: _catalogPresentationState,
        savedViews: _catalogSavedViewDeck.savedViews,
        activeSavedViewId: _activeCatalogSavedViewId,
        defaultSavedViewId: _defaultCatalogSavedViewId,
        onSavedViewSelected: _applySavedCatalogView,
        onSaveCurrentView: _saveCurrentCatalogView,
        onSavedViewCopied: _copySavedCatalogView,
        onSavedViewRenamed: _renameSavedCatalogView,
        onSavedViewUpdated: _updateSavedCatalogView,
        onSavedViewDeleted: _deleteSavedCatalogView,
        onDefaultSavedViewChanged: _setDefaultSavedCatalogView,
        canCopySavedView: _catalogSavedViewDeck.isStarter,
        canRenameSavedView: _catalogSavedViewDeck.canManage,
        canUpdateSavedView: _catalogSavedViewDeck.canManage,
        canDeleteSavedView: _catalogSavedViewDeck.canManage,
        savedViewSectionLabel: _catalogSavedViewDeck.sectionLabelFor,
        onPresentationStateChanged: _setCatalogPresentationState,
        tableColumnContributions: tableColumnContributions,
        filterAccessoryBuilder: (context, workspace) {
          final target = _reviewTargetForWorkspace(initialTarget, workspace);
          if (!target.hasCatalogState) return null;

          return ProductCatalogReviewTargetStrip(
            target: target,
            visibleCount: workspace.visibleRecords.length,
            totalCount: workspace.records.length,
            onClear: () => _clearProductCatalogReviewTarget(workspace),
          );
        },
        recordFooterBuilder:
            (context, workspace, record) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProductCatalogChannelReadinessBadges(
                  record: record,
                  definitions: channelDefinitions,
                  onSelected:
                      (item) => _openProductCatalogReviewTarget(
                        context,
                        workspace,
                        ProductCatalogReviewTarget.fromCatalogItem(item),
                      ),
                ),
                const SizedBox(height: 8),
                ProductCatalogQualityBadges(
                  record: record,
                  pack: managementPack,
                  onIssueSelected: (issue) {
                    final packField = issue.packField;
                    if (packField != null) {
                      _openProductManagementEditor(
                        context,
                        product: record.product,
                        focusFieldId: packField.id,
                      );
                      return;
                    }

                    workspace.openProductEditor(
                      record.product,
                      focusTarget: _focusTargetForCatalogQualityIssue(
                        issue.type,
                      ),
                    );
                  },
                ),
              ],
            ),
        extensionBuilder: (context, workspace) {
          final readiness = buildProductSalesChannelReadiness(
            workspace.records,
            definitions: channelDefinitions,
          );
          final profileReadinessSummary =
              summarizeProductSalesChannelProfileReadiness(readiness);
          final profileReadinessOptions =
              buildProductSalesChannelProfileReadinessOptions(
                workspace.records,
                profiles: channelProfiles,
                selectedProfileId: channelProfile.id,
              );
          final strategyBrief = buildProductSalesChannelStrategyBrief(
            profile: channelProfile,
            readiness: readiness,
            summary: profileReadinessSummary,
          );
          final routeMode = productManagementRouteModeFor(
            pack: managementPack,
            channelProfile: channelProfile,
          );
          final scopedExperienceProfile = ProductExperienceProfileScope.maybeOf(
            context,
          );
          final navigationProfile =
              scopedExperienceProfile == null
                  ? widget.activeSuiteDestination ==
                          ProductManagementSuiteDestination.freshnessReview
                      ? productManagementFreshGoodsNavigationProfile
                      : productManagementFullSuiteNavigationProfile
                  : productManagementSuiteNavigationProfileForExperienceProfile(
                    scopedExperienceProfile,
                    activeDestination: widget.activeSuiteDestination,
                  );

          return [
            ProductManagementSuiteNavigation(
              activeDestination: widget.activeSuiteDestination,
              sections: navigationProfile.sections,
              onSelected:
                  (destination) => context.go(
                    productManagementSuiteDestinationRoute(
                      destination,
                      mode: routeMode,
                    ),
                  ),
            ),
            ProductManagementModeStatusPanel(
              pack: managementPack,
              channelProfile: channelProfile,
              canReset: _canResetManagementMode(
                defaultPack: defaultManagementPack,
                activePack: managementPack,
                activeProfile: channelProfile,
              ),
              onReset: _resetManagementMode,
            ),
            ProductSalesChannelProfileSelectorPanel(
              profiles: channelProfiles,
              selectedProfile: channelProfile,
              readinessSummary: profileReadinessSummary,
              readinessOptions: profileReadinessOptions,
              onChanged: (profileId) {
                _requestProfileSwitch(profileId, profileReadinessOptions);
              },
            ),
            ProductSalesChannelStrategyBriefPanel(
              brief: strategyBrief,
              onPrioritySelected:
                  (priority) => _openProductCatalogReviewTarget(
                    context,
                    workspace,
                    ProductCatalogReviewTarget.fromReadiness(
                      priority.readiness,
                    ),
                  ),
            ),
            ProductSalesChannelReadinessStrip(
              readiness: readiness,
              onSelected:
                  (readiness) => _openProductCatalogReviewTarget(
                    context,
                    workspace,
                    ProductCatalogReviewTarget.fromReadiness(readiness),
                  ),
              onIssueSelected:
                  (readiness, issue) => _openProductCatalogReviewTarget(
                    context,
                    workspace,
                    ProductCatalogReviewTarget.fromReadinessIssue(
                      issue,
                      title: readiness.title,
                    ),
                  ),
            ),
          ];
        },
      ),
    );
  }

  void _setCatalogPresentationState(
    InventoryProductCatalogPresentationState presentationState,
  ) {
    final normalizedState = presentationState.normalized;
    if (_catalogPresentationState.matches(normalizedState)) return;

    setState(() {
      _catalogPresentationState = normalizedState;
      _activeCatalogSavedViewId = _catalogSavedViewDeck.matchingViewId(
        normalizedState,
      );
      _catalogPresentationStateChangedLocally = true;
    });
    unawaited(_saveCatalogPresentation());
  }

  void _saveCurrentCatalogView(
    InventoryProductCatalogPresentationState presentationState,
  ) {
    final normalizedState = presentationState.normalized;
    final existingView = _catalogSavedViewDeck.matchingView(
      normalizedState,
      editableOnly: true,
    );
    if (existingView != null) {
      setState(() {
        _catalogPresentationState = normalizedState;
        _activeCatalogSavedViewId = existingView.id;
        _catalogPresentationStateChangedLocally = true;
      });
      unawaited(_persistActiveCatalogSavedView(existingView));
      _showProductCatalogSnackBar(
        context,
        '${existingView.label} already saved',
      );
      return;
    }

    final savedView = _catalogSavedViewDeck.createSavedView(normalizedState);
    final nextDeck = _catalogSavedViewDeck.withEditableSavedView(savedView);

    setState(() {
      _catalogPresentationState = normalizedState;
      _catalogSavedViewDeck = nextDeck;
      _activeCatalogSavedViewId = savedView.id;
      _catalogPresentationStateChangedLocally = true;
    });
    unawaited(_persistCatalogSavedView(savedView));
    _showProductCatalogSnackBar(context, '${savedView.label} saved');
  }

  void _copySavedCatalogView(InventoryProductCatalogSavedView sourceView) {
    if (!_catalogSavedViewDeck.isStarter(sourceView)) return;

    final copiedView = _catalogSavedViewDeck.createEditableCopy(sourceView);
    final nextDeck = _catalogSavedViewDeck.withEditableSavedView(copiedView);

    setState(() {
      _catalogPresentationState = copiedView.presentationState.normalized;
      _catalogSavedViewDeck = nextDeck;
      _activeCatalogSavedViewId = copiedView.id;
      _catalogPresentationStateChangedLocally = true;
    });
    unawaited(_persistCatalogSavedView(copiedView));
    _showProductCatalogSnackBar(
      context,
      '${copiedView.label} saved as editable view',
    );
  }

  Future<void> _renameSavedCatalogView(
    InventoryProductCatalogSavedView savedView,
  ) async {
    if (!_catalogSavedViewDeck.canManage(savedView)) return;

    final nextLabel = await _showRenameSavedCatalogViewDialog(
      context,
      savedView,
    );
    if (!mounted || nextLabel == null) return;

    final normalizedLabel = nextLabel.trim();
    if (normalizedLabel.isEmpty || normalizedLabel == savedView.label) return;

    final renamedView = _catalogSavedViewDeck.renameEditableView(
      savedView,
      normalizedLabel,
    );
    final nextDeck = _catalogSavedViewDeck.withEditableSavedView(renamedView);

    setState(() {
      _catalogSavedViewDeck = nextDeck;
      _activeCatalogSavedViewId = nextDeck.idIfPresent(
        _activeCatalogSavedViewId,
      );
      _defaultCatalogSavedViewId = nextDeck.idIfPresent(
        _defaultCatalogSavedViewId,
      );
    });
    unawaited(_persistCatalogSavedViewMetadata(renamedView));
    _showProductCatalogSnackBar(context, '${renamedView.label} renamed');
  }

  void _updateSavedCatalogView(
    InventoryProductCatalogSavedView savedView,
    InventoryProductCatalogPresentationState presentationState,
  ) {
    if (!_catalogSavedViewDeck.canManage(savedView)) return;

    final normalizedState = presentationState.normalized;
    final updatedView = savedView.copyWith(
      description: productCatalogSavedViewDescription(normalizedState),
      presentationState: normalizedState,
    );
    final nextDeck = _catalogSavedViewDeck.withEditableSavedView(updatedView);

    setState(() {
      _catalogPresentationState = normalizedState;
      _catalogSavedViewDeck = nextDeck;
      _activeCatalogSavedViewId = updatedView.id;
      _defaultCatalogSavedViewId = nextDeck.idIfPresent(
        _defaultCatalogSavedViewId,
      );
      _catalogPresentationStateChangedLocally = true;
    });
    unawaited(_persistCatalogSavedView(updatedView));
    _showProductCatalogSnackBar(context, '${updatedView.label} updated');
  }

  Future<void> _persistCatalogSavedView(
    InventoryProductCatalogSavedView savedView,
  ) async {
    final preferences = await ref
        .read(productManagementWorkspacePreferencesControllerProvider)
        .saveCatalogSavedView(savedView);
    if (!mounted) return;

    _hydrateCatalogSavedViews(preferences);
  }

  Future<void> _persistCatalogSavedViewMetadata(
    InventoryProductCatalogSavedView savedView,
  ) async {
    final preferences = await ref
        .read(productManagementWorkspacePreferencesControllerProvider)
        .saveCatalogSavedViewMetadata(savedView);
    if (!mounted) return;

    _hydrateCatalogSavedViews(preferences);
  }

  void _applySavedCatalogView(InventoryProductCatalogSavedView savedView) {
    setState(() {
      _catalogPresentationState = savedView.presentationState.normalized;
      _activeCatalogSavedViewId = savedView.id;
      _catalogPresentationStateChangedLocally = true;
    });
    if (_catalogSavedViewDeck.isStarter(savedView)) {
      unawaited(_saveCatalogPresentation());
    } else {
      unawaited(_persistActiveCatalogSavedView(savedView));
    }
    _showProductCatalogSnackBar(context, '${savedView.label} applied');
  }

  void _deleteSavedCatalogView(InventoryProductCatalogSavedView savedView) {
    if (!_catalogSavedViewDeck.canManage(savedView)) return;

    final nextDeck = _catalogSavedViewDeck.withoutEditableSavedView(savedView);

    setState(() {
      _catalogSavedViewDeck = nextDeck;
      _activeCatalogSavedViewId = nextDeck.matchingViewId(
        _catalogPresentationState,
      );
      _defaultCatalogSavedViewId = nextDeck.idIfPresent(
        _defaultCatalogSavedViewId,
      );
      _catalogPresentationStateChangedLocally = true;
    });
    unawaited(_persistDeletedCatalogSavedView(savedView));
    _showProductCatalogSnackBar(context, '${savedView.label} deleted');
  }

  Future<void> _persistActiveCatalogSavedView(
    InventoryProductCatalogSavedView savedView,
  ) async {
    final preferences = await ref
        .read(productManagementWorkspacePreferencesControllerProvider)
        .selectCatalogSavedView(savedView);
    if (!mounted) return;

    _hydrateCatalogSavedViews(preferences);
  }

  Future<void> _persistDeletedCatalogSavedView(
    InventoryProductCatalogSavedView savedView,
  ) async {
    final preferences = await ref
        .read(productManagementWorkspacePreferencesControllerProvider)
        .deleteCatalogSavedView(savedView);
    if (!mounted) return;

    _hydrateCatalogSavedViews(preferences);
  }

  void _setDefaultSavedCatalogView(
    InventoryProductCatalogSavedView? savedView,
  ) {
    setState(() {
      _defaultCatalogSavedViewId = savedView?.id;
    });
    unawaited(_persistDefaultCatalogSavedView(savedView));
    _showProductCatalogSnackBar(
      context,
      savedView == null
          ? 'Default catalog view cleared'
          : '${savedView.label} set as startup view',
    );
  }

  Future<void> _persistDefaultCatalogSavedView(
    InventoryProductCatalogSavedView? savedView,
  ) async {
    final controller = ref.read(
      productManagementWorkspacePreferencesControllerProvider,
    );
    if (savedView != null && _catalogSavedViewDeck.isStarter(savedView)) {
      await controller.saveCatalogSavedView(savedView);
    }

    final preferences = await controller.setDefaultCatalogSavedView(savedView);
    if (!mounted) return;

    _hydrateCatalogSavedViews(preferences);
  }

  Future<void> _saveCatalogPresentation() async {
    await ref
        .read(productManagementWorkspacePreferencesControllerProvider)
        .saveCatalogPresentationState(_catalogPresentationState);
  }

  void _hydrateCatalogPresentationState(
    InventoryProductCatalogPresentationState presentationState,
  ) {
    if (_catalogPresentationStateChangedLocally) return;

    final normalizedState = presentationState.normalized;
    if (_catalogPresentationState.matches(normalizedState)) return;

    setState(() => _catalogPresentationState = normalizedState);
  }

  void _hydrateInitialCatalogPresentationState(
    InventoryProductCatalogPresentationState presentationState,
  ) {
    final normalizedState = presentationState.normalized;
    if (_catalogPresentationState.matches(normalizedState)) return;

    setState(() {
      _catalogPresentationState = normalizedState;
      _catalogPresentationStateChangedLocally = true;
    });
  }

  void _hydrateCatalogSavedViews(
    ProductManagementPackPreferences preferences, {
    ProductCatalogStarterSavedViewSet? starterSet,
    bool useDefaultStartup = false,
  }) {
    final nextDeck =
        starterSet == null
            ? ProductCatalogSavedViewDeck.fromStarterViews(
              savedViews: preferences.catalogSavedViews,
              starterSavedViews: _catalogSavedViewDeck.starterSavedViews,
              starterSavedViewIds: _catalogSavedViewDeck.starterSavedViewIds,
              starterSavedViewSectionLabels:
                  _catalogSavedViewDeck.starterSavedViewSectionLabels,
            )
            : ProductCatalogSavedViewDeck.from(
              savedViews: preferences.catalogSavedViews,
              starterSet: starterSet,
            );
    final activeSavedViewId =
        useDefaultStartup
            ? nextDeck.idIfPresent(preferences.startupCatalogSavedViewId)
            : nextDeck.idIfPresent(preferences.activeCatalogSavedViewId) ??
                nextDeck.matchingViewId(preferences.catalogPresentationState);

    setState(() {
      _catalogSavedViewDeck = nextDeck;
      _activeCatalogSavedViewId = activeSavedViewId;
      _defaultCatalogSavedViewId = nextDeck.idIfPresent(
        preferences.defaultCatalogSavedViewId,
      );
    });
  }

  ProductCatalogReviewTarget _reviewTargetForWorkspace(
    ProductCatalogReviewTarget initialTarget,
    InventoryProductCatalogWorkspaceContext workspace,
  ) {
    return ProductCatalogReviewTarget.resolveForCatalogState(
      initialTarget: initialTarget,
      activeTarget: _activeReviewTarget,
      filter: workspace.browserController.filter,
      query: workspace.browserController.query,
    );
  }

  void _openProductCatalogReviewTarget(
    BuildContext context,
    InventoryProductCatalogWorkspaceContext workspace,
    ProductCatalogReviewTarget target,
  ) {
    setState(() {
      _activeReviewTarget = target;
    });
    workspace.browserActions.reset(filter: target.filter, query: target.query);
    _showProductCatalogSnackBar(context, target.announcementLabel);
  }

  Future<void> _requestProfileSwitch(
    ProductSalesChannelProfileId profileId,
    List<ProductSalesChannelProfileReadinessOption> options,
  ) async {
    final option = productSalesChannelProfileReadinessOptionFor(
      options,
      profileId,
    );
    if (option?.isSelected ?? false) return;

    final confirmed =
        option == null
            ? true
            : await showProductSalesChannelProfileSwitchDialog(
              context,
              option: option,
            );
    if (!mounted || !confirmed) return;

    unawaited(
      _applyManagementModeChange(
        feedbackLabel: 'Channel strategy switched',
        apply: (controller) => controller.selectChannelProfile(profileId),
      ),
    );
  }

  void _resetManagementMode() {
    unawaited(_resetManagementModeWithFeedback());
  }

  Future<void> _resetManagementModeWithFeedback() async {
    final selection =
        await ref
            .read(productManagementWorkspacePreferencesControllerProvider)
            .resetToDefault();
    if (!mounted) return;

    _hydrateCatalogModeSelection(selection);
    showProductManagementModeFeedback(
      context,
      label: 'Product mode reset',
      selection: selection,
    );
  }

  Future<void> _applyManagementModeChange({
    required String feedbackLabel,
    required Future<ProductManagementWorkspaceSelection> Function(
      ProductManagementWorkspacePreferencesController controller,
    )
    apply,
  }) async {
    final selection = await apply(
      ref.read(productManagementWorkspacePreferencesControllerProvider),
    );
    if (!mounted) return;

    _hydrateCatalogModeSelection(selection);
    showProductManagementModeFeedback(
      context,
      label: feedbackLabel,
      selection: selection,
      action: SnackBarAction(label: 'Reset', onPressed: _resetManagementMode),
    );
  }

  void _clearProductCatalogReviewTarget(
    InventoryProductCatalogWorkspaceContext workspace,
  ) {
    setState(() {
      _activeReviewTarget = null;
    });
    workspace.browserActions.reset(filter: InventoryProductCatalogFilter.all);
  }

  Future<void> _openProductManagementEditor(
    BuildContext context, {
    Product? product,
    ProductManagementFieldId? focusFieldId,
  }) async {
    InventoryProductCatalogOperationResult? operationResult;
    final navigator = Navigator.of(context);

    await navigator.push(
      MaterialPageRoute(
        builder:
            (context) => AddEditProductScreen(
              product: product,
              initialFocusFieldId: focusFieldId,
              onProductSaved: (savedProduct, previousProduct) {
                final bridge = ref.read(productCatalogMutationBridgeProvider);
                if (previousProduct == null) {
                  operationResult = bridge.addProduct(savedProduct);
                  return;
                }

                operationResult = bridge.updateProduct(
                  savedProduct,
                  previousProduct: previousProduct,
                );
              },
            ),
      ),
    );

    if (!mounted || operationResult == null) return;
    _showProductCatalogOperationResult(this.context, operationResult!);
  }

  Future<void> _syncInitialProductMode() async {
    final initialPackId = widget.initialPackId;
    final initialProfileId = widget.initialChannelProfileId;
    final hasInitialProductMode =
        initialPackId != null || initialProfileId != null;
    final controller = ref.read(
      productManagementWorkspacePreferencesControllerProvider,
    );

    if (!hasInitialProductMode) {
      final selection = await controller.hydrate();
      if (!mounted) return;

      _hydrateCatalogModeSelection(selection);
      return;
    }

    await controller.hydrate(applyChannelProfile: false);
    if (!mounted) return;

    final selection = await controller.applyRouteSelection(
      packId: initialPackId,
      channelProfileId: initialProfileId,
    );
    if (!mounted) return;

    _hydrateCatalogModeSelection(selection);
  }

  void _hydrateCatalogModeSelection(
    ProductManagementWorkspaceSelection selection,
  ) {
    final starterSet = buildProductCatalogStarterSavedViewSet(
      pack: selection.pack,
      channelProfile: selection.channelProfile,
      registry: ref.read(productCatalogSavedViewContributionRegistryProvider),
    );

    _hydrateCatalogPresentationState(
      selection.preferences.startupCatalogPresentationState,
    );
    _hydrateCatalogSavedViews(
      selection.preferences,
      starterSet: starterSet,
      useDefaultStartup: true,
    );
  }
}

bool _canResetManagementMode({
  required ProductManagementPack defaultPack,
  required ProductManagementPack activePack,
  required ProductSalesChannelProfile activeProfile,
}) {
  return activePack.id != defaultPack.id ||
      activeProfile.id != defaultPack.defaultChannelProfileId;
}

InventoryProductDialogFocusTarget _focusTargetForCatalogQualityIssue(
  ProductCatalogQualityIssueType type,
) {
  switch (type) {
    case ProductCatalogQualityIssueType.missingSku:
      return InventoryProductDialogFocusTarget.sku;
    case ProductCatalogQualityIssueType.missingCategory:
      return InventoryProductDialogFocusTarget.category;
    case ProductCatalogQualityIssueType.missingDescription:
      return InventoryProductDialogFocusTarget.description;
    case ProductCatalogQualityIssueType.missingPrice:
      return InventoryProductDialogFocusTarget.price;
    case ProductCatalogQualityIssueType.missingScanCode:
      return InventoryProductDialogFocusTarget.barcode;
    case ProductCatalogQualityIssueType.missingRequiredPackField:
      return InventoryProductDialogFocusTarget.description;
  }
}

void _showProductCatalogOperationResult(
  BuildContext context,
  InventoryProductCatalogOperationResult result,
) {
  _showProductCatalogSnackBar(
    context,
    result.message,
    action:
        result.canUndo
            ? SnackBarAction(label: result.undoLabel, onPressed: result.undo!)
            : null,
  );
}

void _showProductCatalogSnackBar(
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
        duration: const Duration(milliseconds: 1600),
      ),
    );
}

Future<String?> _showRenameSavedCatalogViewDialog(
  BuildContext context,
  InventoryProductCatalogSavedView savedView,
) {
  return showDialog<String>(
    context: context,
    builder:
        (dialogContext) => _RenameSavedCatalogViewDialog(savedView: savedView),
  );
}

class _RenameSavedCatalogViewDialog extends StatefulWidget {
  const _RenameSavedCatalogViewDialog({required this.savedView});

  final InventoryProductCatalogSavedView savedView;

  @override
  State<_RenameSavedCatalogViewDialog> createState() =>
      _RenameSavedCatalogViewDialogState();
}

class _RenameSavedCatalogViewDialogState
    extends State<_RenameSavedCatalogViewDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.savedView.label);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename saved view'),
      content: TextField(
        key: const ValueKey('product-catalog-saved-view-name-field'),
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'View name'),
        textInputAction: TextInputAction.done,
        onSubmitted: _submit,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => _submit(_controller.text),
          child: const Text('Rename'),
        ),
      ],
    );
  }

  void _submit(String value) {
    Navigator.of(context).pop(value.trim());
  }
}

class _ProductsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ProductsAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Products'));
  }
}
