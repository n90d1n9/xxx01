import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/grid_setting.dart';
import '../models/layout_config.dart';
import '../models/layout_version.dart';
import '../models/layout_version_change.dart';
import '../provider/layout_state_provider.dart';

class VersionHistoryPanel extends ConsumerWidget {
  const VersionHistoryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layoutState = ref.watch(layoutStateProvider);
    final versions = layoutState.versions;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'History',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Save snapshot',
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showSaveSnapshotDialog(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _HistorySummary(
          currentIndex: layoutState.currentVersionIndex,
          versionCount: versions.length,
          currentVersion: layoutState.currentVersion,
        ),
        const SizedBox(height: 12),
        if (versions.isEmpty)
          const _EmptyHistory()
        else
          for (var index = versions.length - 1; index >= 0; index--)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _VersionTile(
                version: versions[index],
                previousVersion: index == 0 ? null : versions[index - 1],
                currentVersion: layoutState.currentVersion,
                index: index,
                isCurrent: index == layoutState.currentVersionIndex,
                canDelete: versions.length > 1,
              ),
            ),
      ],
    );
  }

  Future<void> _showSaveSnapshotDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController(text: 'Snapshot');

    await showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Save Snapshot'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Snapshot name',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                _saveSnapshot(dialogContext, ref, controller.text);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  _saveSnapshot(dialogContext, ref, controller.text);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );

    controller.dispose();
  }

  void _saveSnapshot(BuildContext context, WidgetRef ref, String rawName) {
    final name = rawName.trim();
    if (name.isEmpty) return;

    ref.read(layoutStateProvider.notifier).saveVersion(name);
    Navigator.pop(context);
  }
}

class _HistorySummary extends StatelessWidget {
  final int currentIndex;
  final int versionCount;
  final LayoutVersion? currentVersion;

  const _HistorySummary({
    required this.currentIndex,
    required this.versionCount,
    required this.currentVersion,
  });

  @override
  Widget build(BuildContext context) {
    final currentLabel = versionCount == 0 ? 0 : currentIndex + 1;
    final currentVersion = this.currentVersion;
    final summary =
        currentVersion == null
            ? '$versionCount versions - current $currentLabel'
            : '$versionCount versions - current $currentLabel - '
                '${currentVersion.config.layoutMechanism.label} - '
                '${_canvasSizeLabel(currentVersion.config.canvasSize)}';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: Text(summary)),
    );
  }
}

class _VersionTile extends ConsumerWidget {
  final LayoutVersion version;
  final LayoutVersion? previousVersion;
  final LayoutVersion? currentVersion;
  final int index;
  final bool isCurrent;
  final bool canDelete;

  const _VersionTile({
    required this.version,
    required this.previousVersion,
    required this.currentVersion,
    required this.index,
    required this.isCurrent,
    required this.canDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final config = version.config;
    final changes = describeLayoutVersionChanges(version, previousVersion);

    return Material(
      color: isCurrent ? colorScheme.primaryContainer : colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap:
            isCurrent
                ? null
                : () => ref
                    .read(layoutStateProvider.notifier)
                    .restoreVersion(version.id),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isCurrent ? colorScheme.primary : Colors.black12,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isCurrent ? Icons.radio_button_checked : Icons.history,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      version.name?.trim().isNotEmpty == true
                          ? version.name!.trim()
                          : 'Change ${index + 1}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (isCurrent)
                    Chip(
                      label: const Text('Current'),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  _VersionActionMenu(
                    version: version,
                    previousVersion: previousVersion,
                    currentVersion: currentVersion,
                    isCurrent: isCurrent,
                    canDelete: canDelete,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_componentCountLabel(version.components.length)} - '
                '${config.layoutMechanism.label} - '
                '${_canvasSizeLabel(config.canvasSize)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _VersionMetaPill(
                    icon: _layoutMechanismIcon(config.layoutMechanism),
                    label: config.layoutMechanism.label,
                  ),
                  _VersionMetaPill(
                    icon: Icons.crop_16_9,
                    label: _canvasSizeLabel(config.canvasSize),
                  ),
                  _VersionMetaPill(
                    icon: Icons.grid_3x3,
                    label: _layoutRuleLabel(config, version.gridSettings),
                  ),
                ],
              ),
              if (changes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final change in changes.take(3))
                      _VersionChangePill(change: change),
                    if (changes.length > 3)
                      _VersionChangePill(
                        change: LayoutVersionChange(
                          type: LayoutVersionChangeType.baseline,
                          label: '+${changes.length - 3} more',
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(version.timestamp),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '${value.year}-$month-$day $hour:$minute';
  }
}

enum _VersionAction { preview, compareCurrent, rename, duplicate, delete }

class _VersionActionMenu extends ConsumerWidget {
  final LayoutVersion version;
  final LayoutVersion? previousVersion;
  final LayoutVersion? currentVersion;
  final bool isCurrent;
  final bool canDelete;

  const _VersionActionMenu({
    required this.version,
    required this.previousVersion,
    required this.currentVersion,
    required this.isCurrent,
    required this.canDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_VersionAction>(
      tooltip: 'Snapshot actions',
      icon: const Icon(Icons.more_vert, size: 18),
      onSelected:
          (action) => switch (action) {
            _VersionAction.preview => _showVersionPreview(
              context,
              ref,
              version,
              previousVersion,
              isCurrent,
            ),
            _VersionAction.compareCurrent => _showVersionCompare(
              context,
              ref,
              version,
              currentVersion,
              isCurrent,
            ),
            _VersionAction.rename => _showRenameSnapshotDialog(
              context,
              ref,
              version,
            ),
            _VersionAction.duplicate => ref
                .read(layoutStateProvider.notifier)
                .duplicateVersion(version.id),
            _VersionAction.delete => _showDeleteSnapshotDialog(
              context,
              ref,
              version,
            ),
          },
      itemBuilder:
          (context) => [
            _versionActionItem(
              _VersionAction.preview,
              Icons.visibility_outlined,
              'Preview',
            ),
            _versionActionItem(
              _VersionAction.compareCurrent,
              Icons.compare_arrows_outlined,
              'Compare current',
              enabled: currentVersion != null,
            ),
            _versionActionItem(
              _VersionAction.rename,
              Icons.edit_outlined,
              'Rename',
            ),
            _versionActionItem(
              _VersionAction.duplicate,
              Icons.copy_outlined,
              'Duplicate',
            ),
            _versionActionItem(
              _VersionAction.delete,
              Icons.delete_outline,
              'Delete',
              enabled: canDelete,
            ),
          ],
    );
  }
}

PopupMenuItem<_VersionAction> _versionActionItem(
  _VersionAction action,
  IconData icon,
  String label, {
  bool enabled = true,
}) {
  return PopupMenuItem(
    value: action,
    enabled: enabled,
    child: Row(
      children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
    ),
  );
}

Future<void> _showVersionPreview(
  BuildContext context,
  WidgetRef ref,
  LayoutVersion version,
  LayoutVersion? previousVersion,
  bool isCurrent,
) async {
  final config = version.config;
  final changes = describeLayoutVersionChanges(version, previousVersion);

  await showDialog<void>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: const Text('Snapshot preview'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PreviewInfoRow(
                    label: 'Name',
                    value: _snapshotDisplayName(version),
                  ),
                  _PreviewInfoRow(
                    label: 'Mode',
                    value: config.layoutMechanism.label,
                  ),
                  _PreviewInfoRow(
                    label: 'Canvas',
                    value: _canvasSizeLabel(config.canvasSize),
                  ),
                  _PreviewInfoRow(
                    label: 'Components',
                    value: _componentCountLabel(version.components.length),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _VersionMetaPill(
                        icon: _layoutMechanismIcon(config.layoutMechanism),
                        label: config.layoutMechanism.label,
                      ),
                      _VersionMetaPill(
                        icon: Icons.crop_16_9,
                        label: _canvasSizeLabel(config.canvasSize),
                      ),
                      _VersionMetaPill(
                        icon: Icons.grid_3x3,
                        label: _layoutRuleLabel(config, version.gridSettings),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Changes',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final change in changes)
                        _VersionChangePill(change: change),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            if (!isCurrent)
              FilledButton.icon(
                onPressed: () {
                  ref
                      .read(layoutStateProvider.notifier)
                      .restoreVersion(version.id);
                  Navigator.pop(dialogContext);
                },
                icon: const Icon(Icons.restore),
                label: const Text('Restore'),
              ),
          ],
        ),
  );
}

Future<void> _showVersionCompare(
  BuildContext context,
  WidgetRef ref,
  LayoutVersion version,
  LayoutVersion? currentVersion,
  bool isCurrent,
) async {
  final current = currentVersion;
  if (current == null) return;

  final restoreImpact = describeLayoutVersionChanges(version, current);

  await showDialog<void>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: const Text('Compare with current'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CompareHeader(
                    snapshotName: _snapshotDisplayName(version),
                    currentName: _snapshotDisplayName(current),
                  ),
                  const SizedBox(height: 10),
                  _CompareInfoRow(
                    label: 'Mode',
                    snapshotValue: version.config.layoutMechanism.label,
                    currentValue: current.config.layoutMechanism.label,
                  ),
                  _CompareInfoRow(
                    label: 'Canvas',
                    snapshotValue: _canvasSizeLabel(version.config.canvasSize),
                    currentValue: _canvasSizeLabel(current.config.canvasSize),
                  ),
                  _CompareInfoRow(
                    label: 'Components',
                    snapshotValue: _componentCountLabel(
                      version.components.length,
                    ),
                    currentValue: _componentCountLabel(
                      current.components.length,
                    ),
                  ),
                  _CompareInfoRow(
                    label: 'Rules',
                    snapshotValue: _layoutRuleLabel(
                      version.config,
                      version.gridSettings,
                    ),
                    currentValue: _layoutRuleLabel(
                      current.config,
                      current.gridSettings,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Restore impact',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final change in restoreImpact)
                        _VersionChangePill(change: change),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            if (!isCurrent)
              FilledButton.icon(
                onPressed: () {
                  ref
                      .read(layoutStateProvider.notifier)
                      .restoreVersion(version.id);
                  Navigator.pop(dialogContext);
                },
                icon: const Icon(Icons.restore),
                label: const Text('Restore'),
              ),
          ],
        ),
  );
}

Future<void> _showRenameSnapshotDialog(
  BuildContext context,
  WidgetRef ref,
  LayoutVersion version,
) async {
  final controller = TextEditingController(text: _snapshotDisplayName(version));

  await showDialog<void>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: const Text('Rename snapshot'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Snapshot name',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              _renameSnapshot(dialogContext, ref, version.id, controller.text);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _renameSnapshot(
                  dialogContext,
                  ref,
                  version.id,
                  controller.text,
                );
              },
              child: const Text('Rename'),
            ),
          ],
        ),
  );

  controller.dispose();
}

void _renameSnapshot(
  BuildContext context,
  WidgetRef ref,
  String versionId,
  String rawName,
) {
  final name = rawName.trim();
  if (name.isEmpty) return;

  ref.read(layoutStateProvider.notifier).renameVersion(versionId, name);
  Navigator.pop(context);
}

Future<void> _showDeleteSnapshotDialog(
  BuildContext context,
  WidgetRef ref,
  LayoutVersion version,
) async {
  await showDialog<void>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: const Text('Delete snapshot'),
          content: Text('Delete "${_snapshotDisplayName(version)}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ref
                    .read(layoutStateProvider.notifier)
                    .deleteVersion(version.id);
                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
  );
}

class _PreviewInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _CompareHeader extends StatelessWidget {
  final String snapshotName;
  final String currentName;

  const _CompareHeader({required this.snapshotName, required this.currentName});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        const SizedBox(width: 84),
        Expanded(
          child: Text(
            snapshotName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            currentName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge,
          ),
        ),
      ],
    );
  }
}

class _CompareInfoRow extends StatelessWidget {
  final String label;
  final String snapshotValue;
  final String currentValue;

  const _CompareInfoRow({
    required this.label,
    required this.snapshotValue,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 84, child: Text(label, style: textTheme.bodySmall)),
          Expanded(child: Text(snapshotValue, style: textTheme.bodyMedium)),
          const SizedBox(width: 10),
          Expanded(child: Text(currentValue, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _VersionMetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _VersionMetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionChangePill extends StatelessWidget {
  final LayoutVersionChange change;

  const _VersionChangePill({required this.change});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 172),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _versionChangeIcon(change.type),
                size: 14,
                color: colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  change.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.history_toggle_off),
            SizedBox(height: 8),
            Text('No snapshots yet'),
          ],
        ),
      ),
    );
  }
}

String _componentCountLabel(int count) {
  return count == 1 ? '1 component' : '$count components';
}

String _snapshotDisplayName(LayoutVersion version) {
  final name = version.name?.trim();
  return name == null || name.isEmpty ? 'Snapshot' : name;
}

String _canvasSizeLabel(Size size) {
  return '${size.width.round()} x ${size.height.round()}';
}

String _layoutRuleLabel(LayoutConfig config, GridSettings gridSettings) {
  return switch (config.layoutMechanism) {
    LayoutMechanism.freeform =>
      gridSettings.snapToGrid
          ? '${gridSettings.gridSize.round()}px snap'
          : 'Free placement',
    LayoutMechanism.grid =>
      '${gridSettings.gridSize.round()}px grid - '
          '${gridSettings.snapToGrid ? 'snap on' : 'snap off'}',
    LayoutMechanism.tabularColumns =>
      '${config.tabularColumnCount} columns - '
          '${config.tabularColumnGap.round()}px gap',
    LayoutMechanism.autoGrid =>
      '${config.autoGridColumnCount} columns - '
          '${config.autoGridRowHeight.round()}px rows',
  };
}

IconData _layoutMechanismIcon(LayoutMechanism mechanism) {
  return switch (mechanism) {
    LayoutMechanism.freeform => Icons.open_with,
    LayoutMechanism.grid => Icons.grid_4x4,
    LayoutMechanism.tabularColumns => Icons.view_column_outlined,
    LayoutMechanism.autoGrid => Icons.dashboard_customize_outlined,
  };
}

IconData _versionChangeIcon(LayoutVersionChangeType type) {
  return switch (type) {
    LayoutVersionChangeType.baseline => Icons.flag_outlined,
    LayoutVersionChangeType.componentAdded => Icons.add_box_outlined,
    LayoutVersionChangeType.componentRemoved => Icons.indeterminate_check_box,
    LayoutVersionChangeType.componentMoved => Icons.open_with,
    LayoutVersionChangeType.componentResized => Icons.aspect_ratio,
    LayoutVersionChangeType.layoutMode => Icons.layers_outlined,
    LayoutVersionChangeType.canvas => Icons.crop_16_9,
    LayoutVersionChangeType.rules => Icons.tune,
  };
}
