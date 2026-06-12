import '../states/pos_layout_provider.dart';
import '../utils/pos_command_actions.dart';
import '../utils/pos_shell_shortcuts.dart';
import '../widgets/pos_layout_strategy_pack.dart';
import 'default_pos_touch_layout_profiles.dart';
import 'pos_commerce_channel_behavior.dart';
import 'pos_commerce_channel_registry.dart';
import 'pos_product_profile.dart';
import '../models/pos_touch_layout_profile_catalog.dart';

enum POSProductRuntimePackIssueType {
  blankPackId,
  blankPackLabel,
  blankPackDescription,
  productProfileCatalogIssue,
  commerceChannelRegistryIssue,
  commerceChannelBehaviorIssue,
  layoutStrategyIssue,
  layoutRendererIssue,
  touchLayoutProfileIssue,
  commandActionIssue,
  shortcutIssue,
}

class POSProductRuntimePackIssue {
  final POSProductRuntimePackIssueType type;
  final String packId;
  final String message;
  final POSProductProfileIssue? productProfileIssue;
  final POSCommerceChannelRegistryIssue? commerceChannelIssue;
  final POSCommerceChannelBehaviorRegistryIssue? commerceChannelBehaviorIssue;
  final POSLayoutStrategyRegistryIssue? layoutStrategyIssue;
  final POSLayoutStrategyRendererRegistryIssue? layoutRendererIssue;
  final POSTouchLayoutProfileCatalogIssue? touchLayoutProfileIssue;
  final POSCommandActionRegistryIssue? commandActionIssue;
  final POSShellShortcutRegistryIssue? shortcutIssue;

  const POSProductRuntimePackIssue({
    required this.type,
    required this.packId,
    required this.message,
    this.productProfileIssue,
    this.commerceChannelIssue,
    this.commerceChannelBehaviorIssue,
    this.layoutStrategyIssue,
    this.layoutRendererIssue,
    this.touchLayoutProfileIssue,
    this.commandActionIssue,
    this.shortcutIssue,
  });

  @override
  String toString() => message;
}

class POSProductRuntimePack {
  final String id;
  final String label;
  final String description;
  final String productLine;
  final POSProductProfileCatalog productProfileCatalog;
  final POSCommerceChannelRegistry commerceChannelRegistry;
  final POSCommerceChannelBehaviorRegistry commerceChannelBehaviorRegistry;
  final POSLayoutStrategyPack layoutStrategyPack;
  final POSTouchLayoutProfileCatalog touchLayoutProfileCatalog;
  final POSCommandActionRegistry commandActionRegistry;
  final POSShellShortcutRegistry shortcutRegistry;

  const POSProductRuntimePack({
    required this.id,
    required this.label,
    required this.description,
    required this.productLine,
    required this.productProfileCatalog,
    required this.commerceChannelRegistry,
    required this.commerceChannelBehaviorRegistry,
    required this.layoutStrategyPack,
    this.touchLayoutProfileCatalog = defaultPOSTouchLayoutProfileCatalog,
    required this.commandActionRegistry,
    required this.shortcutRegistry,
  });

  List<POSProductRuntimePackIssue> validate() {
    final issues = <POSProductRuntimePackIssue>[];
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      issues.add(
        POSProductRuntimePackIssue(
          type: POSProductRuntimePackIssueType.blankPackId,
          packId: id,
          message: 'POS product runtime pack id cannot be blank.',
        ),
      );
    }

    if (label.trim().isEmpty) {
      issues.add(
        POSProductRuntimePackIssue(
          type: POSProductRuntimePackIssueType.blankPackLabel,
          packId: id,
          message:
              'POS product runtime pack "$_labelForMessage" label cannot be blank.',
        ),
      );
    }

    if (description.trim().isEmpty) {
      issues.add(
        POSProductRuntimePackIssue(
          type: POSProductRuntimePackIssueType.blankPackDescription,
          packId: id,
          message:
              'POS product runtime pack "$_labelForMessage" description cannot be blank.',
        ),
      );
    }

    for (final issue in productProfileCatalog.validationReport.issues) {
      issues.add(
        POSProductRuntimePackIssue(
          type: POSProductRuntimePackIssueType.productProfileCatalogIssue,
          packId: id,
          message: issue.message,
          productProfileIssue: issue,
        ),
      );
    }

    for (final issue in commerceChannelRegistry.validate()) {
      issues.add(
        POSProductRuntimePackIssue(
          type: POSProductRuntimePackIssueType.commerceChannelRegistryIssue,
          packId: id,
          message: issue.message,
          commerceChannelIssue: issue,
        ),
      );
    }

    for (final issue in commerceChannelBehaviorRegistry.validate(
      commerceChannelRegistry: commerceChannelRegistry,
    )) {
      issues.add(
        POSProductRuntimePackIssue(
          type: POSProductRuntimePackIssueType.commerceChannelBehaviorIssue,
          packId: id,
          message: issue.message,
          commerceChannelBehaviorIssue: issue,
        ),
      );
    }

    final layoutValidation = layoutStrategyPack.validate();
    for (final issue in layoutValidation.strategyIssues) {
      issues.add(
        POSProductRuntimePackIssue(
          type: POSProductRuntimePackIssueType.layoutStrategyIssue,
          packId: id,
          message: issue.message,
          layoutStrategyIssue: issue,
        ),
      );
    }
    for (final issue in layoutValidation.rendererIssues) {
      issues.add(
        POSProductRuntimePackIssue(
          type: POSProductRuntimePackIssueType.layoutRendererIssue,
          packId: id,
          message: issue.message,
          layoutRendererIssue: issue,
        ),
      );
    }

    for (final issue in touchLayoutProfileCatalog.validate()) {
      issues.add(
        POSProductRuntimePackIssue(
          type: POSProductRuntimePackIssueType.touchLayoutProfileIssue,
          packId: id,
          message: issue.message,
          touchLayoutProfileIssue: issue,
        ),
      );
    }

    for (final issue in commandActionRegistry.validate()) {
      issues.add(
        POSProductRuntimePackIssue(
          type: POSProductRuntimePackIssueType.commandActionIssue,
          packId: id,
          message: issue.message,
          commandActionIssue: issue,
        ),
      );
    }

    for (final issue in shortcutRegistry.validate()) {
      issues.add(
        POSProductRuntimePackIssue(
          type: POSProductRuntimePackIssueType.shortcutIssue,
          packId: id,
          message: issue.message,
          shortcutIssue: issue,
        ),
      );
    }

    return List.unmodifiable(issues);
  }

  bool get isValid => validate().isEmpty;

  void throwIfInvalid() {
    final issues = validate();
    if (issues.isEmpty) return;

    throw StateError(
      'Invalid POS product runtime pack "$id": '
      '${issues.map((issue) => issue.message).join('; ')}',
    );
  }

  String get _labelForMessage => id.trim().isEmpty ? '<blank>' : id.trim();

  POSProductRuntimePack copyWith({
    String? id,
    String? label,
    String? description,
    String? productLine,
    POSProductProfileCatalog? productProfileCatalog,
    POSCommerceChannelRegistry? commerceChannelRegistry,
    POSCommerceChannelBehaviorRegistry? commerceChannelBehaviorRegistry,
    POSLayoutStrategyPack? layoutStrategyPack,
    POSTouchLayoutProfileCatalog? touchLayoutProfileCatalog,
    POSCommandActionRegistry? commandActionRegistry,
    POSShellShortcutRegistry? shortcutRegistry,
  }) {
    return POSProductRuntimePack(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      productLine: productLine ?? this.productLine,
      productProfileCatalog:
          productProfileCatalog ?? this.productProfileCatalog,
      commerceChannelRegistry:
          commerceChannelRegistry ?? this.commerceChannelRegistry,
      commerceChannelBehaviorRegistry:
          commerceChannelBehaviorRegistry ??
          this.commerceChannelBehaviorRegistry,
      layoutStrategyPack: layoutStrategyPack ?? this.layoutStrategyPack,
      touchLayoutProfileCatalog:
          touchLayoutProfileCatalog ?? this.touchLayoutProfileCatalog,
      commandActionRegistry:
          commandActionRegistry ?? this.commandActionRegistry,
      shortcutRegistry: shortcutRegistry ?? this.shortcutRegistry,
    );
  }
}

enum POSProductRuntimePackRegistryIssueType {
  emptyRegistry,
  duplicatePackId,
  missingDefaultPack,
  packIssue,
}

class POSProductRuntimePackRegistryIssue {
  final POSProductRuntimePackRegistryIssueType type;
  final String? packId;
  final String message;
  final POSProductRuntimePackIssue? packIssue;

  const POSProductRuntimePackRegistryIssue({
    required this.type,
    required this.message,
    this.packId,
    this.packIssue,
  });

  @override
  String toString() => message;
}

class POSProductRuntimePackResolution {
  final String requestedId;
  final POSProductRuntimePack pack;
  final bool usedFallback;
  final String? fallbackReason;

  const POSProductRuntimePackResolution({
    required this.requestedId,
    required this.pack,
    required this.usedFallback,
    this.fallbackReason,
  });
}

class POSProductRuntimePackRegistry {
  final String defaultPackId;
  final List<POSProductRuntimePack> packs;

  POSProductRuntimePackRegistry({
    required this.defaultPackId,
    required Iterable<POSProductRuntimePack> packs,
  }) : packs = List.unmodifiable(packs);

  List<String> get packIds {
    return packs.map((pack) => pack.id).toList(growable: false);
  }

  POSProductRuntimePack get defaultPack {
    final pack = findById(defaultPackId);
    if (pack != null) return pack;

    if (packs.isEmpty) {
      throw StateError('POS product runtime pack registry is empty.');
    }

    return packs.first;
  }

  POSProductRuntimePack? findById(String id) {
    final normalizedId = id.trim();
    for (final pack in packs) {
      if (pack.id == normalizedId) return pack;
    }

    return null;
  }

  POSProductRuntimePackResolution resolveDetailed(String id) {
    final normalizedId = id.trim();
    final pack = findById(normalizedId);
    if (pack != null) {
      return POSProductRuntimePackResolution(
        requestedId: normalizedId,
        pack: pack,
        usedFallback: false,
      );
    }

    return POSProductRuntimePackResolution(
      requestedId: normalizedId,
      pack: defaultPack,
      usedFallback: true,
      fallbackReason:
          normalizedId.isEmpty
              ? 'No POS product runtime pack id was selected.'
              : 'POS product runtime pack "$normalizedId" is not registered.',
    );
  }

  List<POSProductRuntimePackRegistryIssue> validate() {
    final issues = <POSProductRuntimePackRegistryIssue>[];
    if (packs.isEmpty) {
      return const [
        POSProductRuntimePackRegistryIssue(
          type: POSProductRuntimePackRegistryIssueType.emptyRegistry,
          message:
              'POS product runtime pack registry must contain at least one pack.',
        ),
      ];
    }

    final idCounts = <String, int>{};
    for (final pack in packs) {
      final normalizedId = pack.id.trim();
      if (normalizedId.isEmpty) continue;
      idCounts[normalizedId] = (idCounts[normalizedId] ?? 0) + 1;
    }

    for (final entry in idCounts.entries) {
      if (entry.value <= 1) continue;
      issues.add(
        POSProductRuntimePackRegistryIssue(
          type: POSProductRuntimePackRegistryIssueType.duplicatePackId,
          packId: entry.key,
          message:
              'Duplicate POS product runtime pack id "${entry.key}" found.',
        ),
      );
    }

    if (findById(defaultPackId) == null) {
      issues.add(
        POSProductRuntimePackRegistryIssue(
          type: POSProductRuntimePackRegistryIssueType.missingDefaultPack,
          packId: defaultPackId,
          message:
              'Default POS product runtime pack "$defaultPackId" is not registered.',
        ),
      );
    }

    for (final pack in packs) {
      for (final issue in pack.validate()) {
        issues.add(
          POSProductRuntimePackRegistryIssue(
            type: POSProductRuntimePackRegistryIssueType.packIssue,
            packId: pack.id,
            message: issue.message,
            packIssue: issue,
          ),
        );
      }
    }

    return List.unmodifiable(issues);
  }

  bool get isValid => validate().isEmpty;

  void throwIfInvalid() {
    final issues = validate();
    if (issues.isEmpty) return;

    throw StateError(
      'Invalid POS product runtime pack registry: '
      '${issues.map((issue) => issue.message).join('; ')}',
    );
  }
}
