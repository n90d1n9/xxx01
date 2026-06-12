import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/core/workspace/models/saved_workspace_shortcut.dart';

void main() {
  test('workspace shortcut definition bundles reusable operations', () {
    const delivery = _Shortcut(
      id: 'saved_delivery',
      label: 'Delivery',
      state: 'delivery',
    );
    const marketplace = _Shortcut(
      id: 'saved_marketplace',
      label: 'Marketplace',
      state: 'marketplace',
      isPinned: true,
    );
    const pickup = _Shortcut(
      id: 'saved_pickup',
      label: 'Pickup',
      state: 'pickup',
      isPinned: true,
    );

    final saved = _shortcutDefinition.save(
      shortcuts: const <_Shortcut>[],
      shortcut: delivery,
    );
    final savedTwice = _shortcutDefinition.save(
      shortcuts: saved,
      shortcut: delivery.copyWith(id: 'saved_delivery_duplicate'),
    );
    final updated = _shortcutDefinition.updateDistinct(
      shortcuts: [delivery, marketplace],
      updatedShortcut: delivery.copyWith(state: 'packed'),
    );
    final duplicated = _shortcutDefinition.duplicateIn(
      shortcuts: updated,
      shortcutId: delivery.id,
    );
    final duplicate = _shortcutDefinition.duplicate(
      shortcuts: updated,
      shortcutId: delivery.id,
    );
    final pinned = _shortcutDefinition.pin(
      shortcuts: duplicated,
      shortcutId: delivery.id,
      isPinned: true,
    );
    final renamed = _shortcutDefinition.rename(
      shortcuts: pinned,
      shortcutId: delivery.id,
      label: 'Courier',
    );
    final moved = _shortcutDefinition.move(
      shortcuts: [delivery, marketplace, pickup],
      shortcutId: pickup.id,
      direction: WorkspaceShortcutMoveDirection.earlier,
    );
    final display = _shortcutDefinition.forDisplay([delivery, marketplace]);
    final removed = _shortcutDefinition.remove(
      shortcuts: renamed,
      shortcutId: marketplace.id,
    );

    expect(savedTwice, hasLength(1));
    expect(
      _shortcutDefinition.byId(shortcuts: renamed, shortcutId: delivery.id),
      isNotNull,
    );
    expect(
      _shortcutDefinition.forState(
        shortcuts: renamed,
        matchesState: (shortcut) => shortcut.state == 'packed',
      ),
      isNotNull,
    );
    expect(updated.first.state, 'packed');
    expect(duplicate?.id, 'saved_delivery_copy');
    expect(duplicated.last.id, 'saved_delivery_copy');
    expect(pinned.first.isPinned, isTrue);
    expect(renamed.first.label, 'Courier');
    expect(moved.map((shortcut) => shortcut.id), [
      delivery.id,
      pickup.id,
      marketplace.id,
    ]);
    expect(
      _shortcutDefinition.canMove(
        shortcuts: moved,
        shortcutId: pickup.id,
        direction: WorkspaceShortcutMoveDirection.earlier,
      ),
      isFalse,
    );
    expect(display.map((shortcut) => shortcut.id), [
      marketplace.id,
      delivery.id,
    ]);
    expect(removed.map((shortcut) => shortcut.id), [
      delivery.id,
      'saved_delivery_copy',
    ]);
  });

  test(
    'workspace shortcut helpers dedupe, update, and duplicate generically',
    () {
      const delivery = _Shortcut(
        id: 'saved_delivery',
        label: 'Delivery',
        state: 'delivery',
        isPinned: true,
      );
      const marketplace = _Shortcut(
        id: 'saved_marketplace',
        label: 'Marketplace',
        state: 'marketplace',
      );

      final savedOnce = workspaceShortcutsWithSaved(
        shortcuts: const <_Shortcut>[],
        shortcut: delivery,
        matchesState: _sameState,
      );
      final savedTwice = workspaceShortcutsWithSaved(
        shortcuts: savedOnce,
        shortcut: delivery.copyWith(id: 'saved_delivery_duplicate'),
        matchesState: _sameState,
      );
      final updated = workspaceShortcutsWithDistinctUpdated(
        shortcuts: [delivery, marketplace],
        updatedShortcut: delivery.copyWith(state: 'packed'),
        idOf: _idOf,
        stateChanged: (current, next) => current.state != next.state,
        matchesState: _sameState,
      );
      final duplicateBlocked = workspaceShortcutsWithDistinctUpdated(
        shortcuts: updated,
        updatedShortcut: marketplace.copyWith(state: 'packed'),
        idOf: _idOf,
        stateChanged: (current, next) => current.state != next.state,
        matchesState: _sameState,
      );
      final duplicated = workspaceShortcutsWithDuplicated(
        shortcuts: [delivery, marketplace],
        shortcutId: delivery.id,
        idOf: _idOf,
        labelOf: _labelOf,
        duplicateBuilder:
            (shortcut, spec) => shortcut.copyWith(
              id: spec.id,
              label: spec.label,
              isPinned: spec.isPinned,
            ),
      );

      expect(savedOnce, hasLength(1));
      expect(savedTwice, hasLength(1));
      expect(updated.first.state, 'packed');
      expect(duplicateBlocked.last.state, 'marketplace');
      expect(duplicated.map((shortcut) => shortcut.id), [
        delivery.id,
        marketplace.id,
        'saved_delivery_copy',
      ]);
      expect(duplicated.last.label, 'Delivery copy');
      expect(duplicated.last.isPinned, isFalse);
    },
  );

  test('workspace shortcut helpers rename, pin, move, display, and remove', () {
    const first = _Shortcut(id: 'first', label: 'First', state: 'a');
    const second = _Shortcut(
      id: 'second',
      label: 'Second',
      state: 'b',
      isPinned: true,
    );
    const third = _Shortcut(
      id: 'third',
      label: 'Third',
      state: 'c',
      isPinned: true,
    );
    const fourth = _Shortcut(id: 'fourth', label: 'Fourth', state: 'd');

    final renamed = workspaceShortcutsWithRenamed(
      shortcuts: const [first, second],
      shortcutId: first.id,
      idOf: _idOf,
      labelBuilder: (shortcut, label) => shortcut.copyWith(label: label),
      label: '  New first  ',
    );
    final pinned = workspaceShortcutsWithPinned(
      shortcuts: renamed,
      shortcutId: first.id,
      idOf: _idOf,
      pinnedBuilder:
          (shortcut, isPinned) => shortcut.copyWith(isPinned: isPinned),
      isPinned: true,
    );
    final movedPinned = workspaceShortcutsWithMoved(
      shortcuts: [first, second, fourth, third],
      shortcutId: third.id,
      idOf: _idOf,
      isPinned: _isPinned,
      direction: WorkspaceShortcutMoveDirection.earlier,
    );
    final display = workspaceShortcutsForDisplay(
      shortcuts: [first, second, fourth, third],
      isPinned: _isPinned,
    );
    final removed = workspaceShortcutsWithout(
      shortcuts: display,
      shortcutId: second.id,
      idOf: _idOf,
    );

    expect(renamed.first.label, 'New first');
    expect(pinned.first.isPinned, isTrue);
    expect(movedPinned.map((shortcut) => shortcut.id), [
      first.id,
      third.id,
      fourth.id,
      second.id,
    ]);
    expect(
      workspaceShortcutCanMove(
        shortcuts: movedPinned,
        shortcutId: third.id,
        idOf: _idOf,
        isPinned: _isPinned,
        direction: WorkspaceShortcutMoveDirection.earlier,
      ),
      isFalse,
    );
    expect(display.map((shortcut) => shortcut.id), [
      second.id,
      third.id,
      first.id,
      fourth.id,
    ]);
    expect(removed.map((shortcut) => shortcut.id), [
      third.id,
      first.id,
      fourth.id,
    ]);
  });

  test(
    'workspace shortcut copy identity handles blank and duplicate labels',
    () {
      const blank = _Shortcut(id: '@@@', label: '   ', state: 'blank');
      const existingCopy = _Shortcut(
        id: 'copy',
        label: 'Saved workspace copy',
        state: 'copy',
      );

      final duplicated = workspaceShortcutsWithDuplicated(
        shortcuts: const [blank, existingCopy],
        shortcutId: blank.id,
        idOf: _idOf,
        labelOf: _labelOf,
        duplicateBuilder:
            (shortcut, spec) => shortcut.copyWith(
              id: spec.id,
              label: spec.label,
              isPinned: spec.isPinned,
            ),
      );

      expect(duplicated.last.id, 'copy_2');
      expect(duplicated.last.label, 'Saved workspace copy 2');
      expect(
        workspaceShortcutNormalizedId(' Delivery app / Ready '),
        'delivery_app_ready',
      );
    },
  );
}

class _Shortcut {
  final String id;
  final String label;
  final String state;
  final bool isPinned;

  const _Shortcut({
    required this.id,
    required this.label,
    required this.state,
    this.isPinned = false,
  });

  _Shortcut copyWith({
    String? id,
    String? label,
    String? state,
    bool? isPinned,
  }) {
    return _Shortcut(
      id: id ?? this.id,
      label: label ?? this.label,
      state: state ?? this.state,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

String _idOf(_Shortcut shortcut) => shortcut.id;

String _labelOf(_Shortcut shortcut) => shortcut.label;

bool _isPinned(_Shortcut shortcut) => shortcut.isPinned;

bool _sameState(_Shortcut existingShortcut, _Shortcut targetShortcut) {
  return existingShortcut.state == targetShortcut.state;
}

bool _stateChanged(_Shortcut currentShortcut, _Shortcut updatedShortcut) {
  return currentShortcut.state != updatedShortcut.state;
}

_Shortcut _duplicateBuilder(
  _Shortcut shortcut,
  WorkspaceShortcutDuplicateSpec duplicateSpec,
) {
  return shortcut.copyWith(
    id: duplicateSpec.id,
    label: duplicateSpec.label,
    isPinned: duplicateSpec.isPinned,
  );
}

_Shortcut _pinnedBuilder(_Shortcut shortcut, bool isPinned) {
  return shortcut.copyWith(isPinned: isPinned);
}

_Shortcut _labelBuilder(_Shortcut shortcut, String label) {
  return shortcut.copyWith(label: label);
}

final _shortcutDefinition = WorkspaceShortcutDefinition<_Shortcut>(
  idOf: _idOf,
  labelOf: _labelOf,
  isPinned: _isPinned,
  matchesState: _sameState,
  stateChanged: _stateChanged,
  duplicateBuilder: _duplicateBuilder,
  pinnedBuilder: _pinnedBuilder,
  labelBuilder: _labelBuilder,
);
