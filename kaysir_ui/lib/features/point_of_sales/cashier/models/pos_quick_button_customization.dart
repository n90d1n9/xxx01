import 'pos_quick_button.dart';
import 'pos_touch_layout_profile.dart';

/// Operator-level preference overlay for POS quick-button presets.
///
/// It never mutates product-line layout definitions; it only filters and
/// promotes button IDs at render time so presets stay reusable and syncable.
class POSQuickButtonCustomization {
  static const _unchangedDensityOverride = Object();
  static const _hiddenButtonIdsJsonKey = 'hiddenButtonIds';
  static const _pinnedButtonIdsJsonKey = 'pinnedButtonIds';
  static const _densityOverrideJsonKey = 'densityOverride';

  final List<String> hiddenButtonIds;
  final List<String> pinnedButtonIds;
  final POSTouchLayoutDensity? densityOverride;

  const POSQuickButtonCustomization({
    this.hiddenButtonIds = const [],
    this.pinnedButtonIds = const [],
    this.densityOverride,
  });

  static const empty = POSQuickButtonCustomization();

  factory POSQuickButtonCustomization.fromJson(Map<String, Object?> json) {
    final hiddenButtonIds = _normalizedUniqueIds(
      _decodeIdList(json[_hiddenButtonIdsJsonKey]),
    );
    final hiddenButtonIdSet = hiddenButtonIds.toSet();
    final pinnedButtonIds = _normalizedUniqueIds(
      _decodeIdList(
        json[_pinnedButtonIdsJsonKey],
      ).where((id) => !hiddenButtonIdSet.contains(id.trim())),
    );

    return POSQuickButtonCustomization(
      hiddenButtonIds: hiddenButtonIds,
      pinnedButtonIds: pinnedButtonIds,
      densityOverride: decodePOSTouchLayoutDensity(
        json[_densityOverrideJsonKey],
      ),
    );
  }

  bool get isEmpty {
    return hiddenButtonIds.isEmpty &&
        pinnedButtonIds.isEmpty &&
        densityOverride == null;
  }

  POSTouchLayoutDensity effectiveDensityFor(
    POSTouchLayoutDensity profileDensity,
  ) {
    return densityOverride ?? profileDensity;
  }

  bool isHidden(String buttonId) {
    return _containsId(hiddenButtonIds, buttonId);
  }

  bool isPinned(String buttonId) {
    return _containsId(pinnedButtonIds, buttonId);
  }

  POSQuickButtonCustomization toggleHidden(String buttonId) {
    final normalizedId = buttonId.trim();
    if (normalizedId.isEmpty) return this;

    if (isHidden(normalizedId)) {
      return copyWith(
        hiddenButtonIds: _withoutId(hiddenButtonIds, normalizedId),
      );
    }

    return copyWith(
      hiddenButtonIds: [...hiddenButtonIds, normalizedId],
      pinnedButtonIds: _withoutId(pinnedButtonIds, normalizedId),
    );
  }

  POSQuickButtonCustomization togglePinned(String buttonId) {
    final normalizedId = buttonId.trim();
    if (normalizedId.isEmpty || isHidden(normalizedId)) return this;

    if (isPinned(normalizedId)) {
      return copyWith(
        pinnedButtonIds: _withoutId(pinnedButtonIds, normalizedId),
      );
    }

    return copyWith(pinnedButtonIds: [normalizedId, ...pinnedButtonIds]);
  }

  POSQuickButtonCustomization movePinned(String buttonId, int offset) {
    final normalizedId = buttonId.trim();
    if (normalizedId.isEmpty || offset == 0) return this;

    final currentIndex = pinnedButtonIds.indexWhere(
      (id) => id.trim() == normalizedId,
    );
    if (currentIndex < 0) return this;

    final targetIndex = (currentIndex + offset).clamp(
      0,
      pinnedButtonIds.length - 1,
    );
    if (targetIndex == currentIndex) return this;

    final nextPinnedButtonIds = [...pinnedButtonIds];
    final pinnedButtonId = nextPinnedButtonIds.removeAt(currentIndex);
    nextPinnedButtonIds.insert(targetIndex, pinnedButtonId);

    return copyWith(pinnedButtonIds: nextPinnedButtonIds);
  }

  POSQuickButtonCustomization reset() => empty;

  POSQuickButtonCustomization withDensityOverride(
    POSTouchLayoutDensity? densityOverride,
  ) {
    return copyWith(densityOverride: densityOverride);
  }

  Map<String, Object?> toJson() {
    final snapshot = <String, Object?>{};
    if (hiddenButtonIds.isNotEmpty) {
      snapshot[_hiddenButtonIdsJsonKey] = hiddenButtonIds;
    }
    if (pinnedButtonIds.isNotEmpty) {
      snapshot[_pinnedButtonIdsJsonKey] = pinnedButtonIds;
    }
    if (densityOverride != null) {
      snapshot[_densityOverrideJsonKey] = densityOverride!.name;
    }

    return snapshot;
  }

  List<POSQuickButton> applyTo(Iterable<POSQuickButton> buttons) {
    final visible = buttons
        .where((button) => !isHidden(button.id))
        .toList(growable: false);
    final byId = {for (final button in visible) button.id.trim(): button};
    final pinned = <POSQuickButton>[];
    final pinnedIds = <String>{};

    for (final buttonId in pinnedButtonIds) {
      final normalizedId = buttonId.trim();
      final button = byId[normalizedId];
      if (button == null) continue;
      pinned.add(button);
      pinnedIds.add(normalizedId);
    }

    return List.unmodifiable([
      ...pinned,
      ...visible.where((button) => !pinnedIds.contains(button.id.trim())),
    ]);
  }

  POSQuickButtonCustomization copyWith({
    List<String>? hiddenButtonIds,
    List<String>? pinnedButtonIds,
    Object? densityOverride = _unchangedDensityOverride,
  }) {
    final nextHiddenButtonIds = _normalizedUniqueIds(
      hiddenButtonIds ?? this.hiddenButtonIds,
    );
    final hiddenButtonIdSet = nextHiddenButtonIds.toSet();

    return POSQuickButtonCustomization(
      hiddenButtonIds: nextHiddenButtonIds,
      pinnedButtonIds: _normalizedUniqueIds(
        (pinnedButtonIds ?? this.pinnedButtonIds).where(
          (id) => !hiddenButtonIdSet.contains(id.trim()),
        ),
      ),
      densityOverride:
          identical(densityOverride, _unchangedDensityOverride)
              ? this.densityOverride
              : densityOverride as POSTouchLayoutDensity?,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is POSQuickButtonCustomization &&
            _sameIds(hiddenButtonIds, other.hiddenButtonIds) &&
            _sameIds(pinnedButtonIds, other.pinnedButtonIds) &&
            densityOverride == other.densityOverride;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(hiddenButtonIds),
      Object.hashAll(pinnedButtonIds),
      densityOverride,
    );
  }
}

List<String> _normalizedUniqueIds(Iterable<String> ids) {
  final result = <String>[];
  final seen = <String>{};
  for (final id in ids) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty || seen.contains(normalizedId)) continue;
    result.add(normalizedId);
    seen.add(normalizedId);
  }

  return List.unmodifiable(result);
}

List<String> _withoutId(Iterable<String> ids, String buttonId) {
  final normalizedButtonId = buttonId.trim();
  return [
    for (final id in ids)
      if (id.trim() != normalizedButtonId) id.trim(),
  ];
}

bool _containsId(Iterable<String> ids, String buttonId) {
  final normalizedButtonId = buttonId.trim();
  if (normalizedButtonId.isEmpty) return false;

  return ids.any((id) => id.trim() == normalizedButtonId);
}

Iterable<String> _decodeIdList(Object? value) {
  if (value is! Iterable) return const <String>[];

  return value.map((id) => id.toString());
}

bool _sameIds(List<String> left, List<String> right) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;

  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) return false;
  }

  return true;
}
