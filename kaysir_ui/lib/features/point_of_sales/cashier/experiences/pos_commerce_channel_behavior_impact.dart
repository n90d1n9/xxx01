import 'pos_commerce_channel_behavior.dart';

enum POSCommerceChannelBehaviorImpactRole { added, removed, retained }

class POSCommerceChannelBehaviorImpactItem {
  final POSCommerceChannelBehaviorModule module;
  final POSCommerceChannelBehaviorImpactRole role;

  const POSCommerceChannelBehaviorImpactItem({
    required this.module,
    required this.role,
  });

  String get label {
    switch (role) {
      case POSCommerceChannelBehaviorImpactRole.added:
        return 'Adds ${module.label}';
      case POSCommerceChannelBehaviorImpactRole.removed:
        return 'Removes ${module.label}';
      case POSCommerceChannelBehaviorImpactRole.retained:
        return 'Keeps ${module.label}';
    }
  }

  Iterable<String> get searchTerms sync* {
    yield label;
    yield role.name;
    yield module.id;
    yield module.label;
    yield module.description;
    yield module.area.name;
    for (final trait in module.traits) {
      yield trait;
    }
  }
}

class POSCommerceChannelBehaviorImpact {
  final POSCommerceChannelBehaviorProfile? currentProfile;
  final POSCommerceChannelBehaviorProfile? targetProfile;
  final List<POSCommerceChannelBehaviorImpactItem> addedItems;
  final List<POSCommerceChannelBehaviorImpactItem> removedItems;
  final List<POSCommerceChannelBehaviorImpactItem> retainedItems;

  POSCommerceChannelBehaviorImpact({
    required this.currentProfile,
    required this.targetProfile,
    required Iterable<POSCommerceChannelBehaviorImpactItem> addedItems,
    required Iterable<POSCommerceChannelBehaviorImpactItem> removedItems,
    required Iterable<POSCommerceChannelBehaviorImpactItem> retainedItems,
  }) : addedItems = List.unmodifiable(addedItems),
       removedItems = List.unmodifiable(removedItems),
       retainedItems = List.unmodifiable(retainedItems);

  factory POSCommerceChannelBehaviorImpact.compare({
    required POSCommerceChannelBehaviorProfile? currentProfile,
    required POSCommerceChannelBehaviorProfile? targetProfile,
  }) {
    final currentModulesById = {
      for (final module
          in currentProfile?.modules ??
              const <POSCommerceChannelBehaviorModule>[])
        module.id: module,
    };
    final targetModulesById = {
      for (final module
          in targetProfile?.modules ??
              const <POSCommerceChannelBehaviorModule>[])
        module.id: module,
    };

    return POSCommerceChannelBehaviorImpact(
      currentProfile: currentProfile,
      targetProfile: targetProfile,
      addedItems: [
        for (final module in targetModulesById.values)
          if (!currentModulesById.containsKey(module.id))
            POSCommerceChannelBehaviorImpactItem(
              module: module,
              role: POSCommerceChannelBehaviorImpactRole.added,
            ),
      ],
      removedItems: [
        for (final module in currentModulesById.values)
          if (!targetModulesById.containsKey(module.id))
            POSCommerceChannelBehaviorImpactItem(
              module: module,
              role: POSCommerceChannelBehaviorImpactRole.removed,
            ),
      ],
      retainedItems: [
        for (final module in targetModulesById.values)
          if (currentModulesById.containsKey(module.id))
            POSCommerceChannelBehaviorImpactItem(
              module: module,
              role: POSCommerceChannelBehaviorImpactRole.retained,
            ),
      ],
    );
  }

  bool get isCurrentProfile {
    return currentProfile?.channelId.trim() == targetProfile?.channelId.trim();
  }

  bool get hasChanges {
    return addedItems.isNotEmpty || removedItems.isNotEmpty;
  }

  int get changeCount => addedItems.length + removedItems.length;

  String get summaryLabel {
    if (!hasChanges) return 'No behavior change';

    if (addedItems.isNotEmpty && removedItems.isEmpty) {
      return _countLabel('Adds', addedItems.length);
    }
    if (removedItems.isNotEmpty && addedItems.isEmpty) {
      return _countLabel('Removes', removedItems.length);
    }

    return '${_countLabel('Adds', addedItems.length)} and '
        '${_countLabel('removes', removedItems.length).toLowerCase()}';
  }

  Iterable<String> get searchTerms sync* {
    yield summaryLabel;
    yield currentProfile?.channelId ?? '';
    yield targetProfile?.channelId ?? '';

    for (final item in addedItems) {
      yield* item.searchTerms;
    }
    for (final item in removedItems) {
      yield* item.searchTerms;
    }
    for (final item in retainedItems) {
      yield* item.searchTerms;
    }
  }

  static String _countLabel(String verb, int count) {
    if (count == 1) return '$verb 1 behavior';
    return '$verb $count behaviors';
  }
}
