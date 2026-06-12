import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../provider/layout_state_provider.dart';
import '../provider/review_state.dart';
import 'number_field.dart';
import 'size_editor.dart';

/// Edits device-specific component geometry and visibility overrides.
class ComponentResponsiveOverrideEditor extends ConsumerWidget {
  final ComponentData component;
  final ResponsivePreviewState previewState;

  const ComponentResponsiveOverrideEditor({
    super.key,
    required this.component,
    required this.previewState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = previewState.currentDevice;
    final deviceKey = device.name;
    final override = component.responsiveProperties[deviceKey];
    final effectivePosition = override?.position ?? component.position;
    final effectiveSize = override?.size ?? component.size;
    final effectiveVisibility = override?.isVisible ?? component.isVisible;
    final hasOverride = override != null;
    final hasAnyOverride = component.responsiveProperties.isNotEmpty;
    final canApplyConstraints =
        !component.isLocked && component.constraints.hasCustomRules;
    final layoutConfig = ref.watch(
      layoutStateProvider.select((state) => state.config),
    );
    final notifier = ref.read(layoutStateProvider.notifier);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.devices_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_deviceLabel(device)} override',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (hasOverride)
                  IconButton(
                    tooltip: 'Reset override',
                    icon: const Icon(Icons.restart_alt),
                    onPressed:
                        () => notifier.clearResponsiveProperties(
                          component.id,
                          deviceKey,
                        ),
                  ),
                if (hasAnyOverride)
                  IconButton(
                    tooltip: 'Reset all overrides',
                    icon: const Icon(Icons.layers_clear_outlined),
                    onPressed:
                        () =>
                            notifier.clearAllResponsiveProperties(component.id),
                  ),
              ],
            ),
            if (hasAnyOverride) ...[
              const SizedBox(height: 8),
              _ResponsiveOverrideSummary(
                overrideKeys: component.responsiveProperties.keys,
                currentDevice: device,
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.copy_all_outlined, size: 18),
                    label: Text(
                      hasOverride ? 'Refresh from base' : 'Create from base',
                    ),
                    onPressed:
                        () => notifier.setResponsivePropertiesFromBase(
                          component.id,
                          deviceKey,
                        ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.devices_outlined, size: 18),
                    label: const Text('Base to all'),
                    onPressed:
                        () =>
                            notifier.setResponsivePropertiesFromBaseForDevices(
                              component.id,
                              _responsiveDeviceKeys,
                            ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.compare_arrows, size: 18),
                    label: const Text('Current to all'),
                    onPressed:
                        () => notifier.copyResponsivePropertiesToDevices(
                          component.id,
                          deviceKey,
                          _responsiveDeviceKeys,
                        ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.auto_fix_high_outlined, size: 18),
                    label: const Text('Apply constraints'),
                    onPressed:
                        canApplyConstraints
                            ? () => notifier.applyResponsiveConstraints(
                              component.id,
                              deviceKey,
                              _responsiveDeviceSize(device, previewState),
                            )
                            : null,
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.fit_screen_outlined, size: 18),
                    label: const Text('Constraints to all'),
                    onPressed:
                        canApplyConstraints
                            ? () =>
                                notifier.applyResponsiveConstraintsForDevices(
                                  component.id,
                                  _responsiveDeviceSizes(previewState),
                                )
                            : null,
                  ),
                  if (hasOverride)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.publish_outlined, size: 18),
                      label: const Text('Use as base'),
                      onPressed:
                          () => notifier.promoteResponsivePropertiesToBase(
                            component.id,
                            deviceKey,
                          ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Visible on this device'),
              value: effectiveVisibility,
              onChanged: (value) {
                _updateOverride(ref, deviceKey, override, isVisible: value);
              },
            ),
            _ResponsiveFieldPair(
              first: NumberField(
                label: 'X',
                value: effectivePosition.dx,
                onChanged: (value) {
                  _updateOverride(
                    ref,
                    deviceKey,
                    override,
                    position: Offset(value, effectivePosition.dy),
                  );
                },
              ),
              second: NumberField(
                label: 'Y',
                value: effectivePosition.dy,
                onChanged: (value) {
                  _updateOverride(
                    ref,
                    deviceKey,
                    override,
                    position: Offset(effectivePosition.dx, value),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            SizeEditor(
              size: effectiveSize,
              minSize: Size(
                layoutConfig.minComponentWidth,
                layoutConfig.minComponentHeight,
              ),
              step: layoutConfig.gridSize,
              onSizeChanged: (size) {
                _updateOverride(ref, deviceKey, override, size: size);
              },
            ),
            const SizedBox(height: 8),
            Text(
              hasOverride
                  ? 'Preview uses these values for ${_deviceLabel(device).toLowerCase()}.'
                  : 'Editing a value creates a ${_deviceLabel(device).toLowerCase()} override.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _updateOverride(
    WidgetRef ref,
    String deviceKey,
    ComponentResponsiveProperties? current, {
    Offset? position,
    Size? size,
    bool? isVisible,
  }) {
    final nextOverride = ComponentResponsiveProperties(
      position: position ?? current?.position,
      size: size ?? current?.size,
      isVisible: isVisible ?? current?.isVisible,
    );

    ref
        .read(layoutStateProvider.notifier)
        .updateResponsiveProperties(component.id, deviceKey, nextOverride);
  }
}

/// Renders the responsive override editor with a sample mobile override.
@Preview(name: 'Component responsive override editor')
Widget componentResponsiveOverrideEditorPreview() {
  final component = ComponentData.create(
    id: 'preview-responsive-button',
    type: ComponentType.customButton,
    position: const Offset(32, 48),
    size: const Size(180, 64),
  ).copyWith(
    responsiveProperties: const {
      'mobile': ComponentResponsiveProperties(
        position: Offset(12, 20),
        size: Size(220, 72),
        isVisible: true,
      ),
    },
  );

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 340,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ComponentResponsiveOverrideEditor(
                component: component,
                previewState: ResponsivePreviewState.mobile,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Shows which devices currently have responsive overrides.
class _ResponsiveOverrideSummary extends StatelessWidget {
  final Iterable<String> overrideKeys;
  final DeviceType currentDevice;

  const _ResponsiveOverrideSummary({
    required this.overrideKeys,
    required this.currentDevice,
  });

  @override
  Widget build(BuildContext context) {
    final devices =
        overrideKeys
            .map(_deviceFromKey)
            .whereType<DeviceType>()
            .toSet()
            .toList()
          ..sort((a, b) => a.index.compareTo(b.index));

    if (devices.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final device in devices)
          _ResponsiveOverrideChip(
            device: device,
            isCurrent: device == currentDevice,
          ),
      ],
    );
  }
}

/// Displays one responsive override device chip.
class _ResponsiveOverrideChip extends StatelessWidget {
  final DeviceType device;
  final bool isCurrent;

  const _ResponsiveOverrideChip({
    required this.device,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      avatar: Icon(_deviceIcon(device), size: 16),
      label: Text(_deviceLabel(device)),
      backgroundColor:
          isCurrent ? colorScheme.primaryContainer : colorScheme.surface,
      side: BorderSide(
        color: isCurrent ? colorScheme.primary : colorScheme.outlineVariant,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Lays out two responsive number fields while preserving compact behavior.
class _ResponsiveFieldPair extends StatelessWidget {
  static const _stackedBreakpoint = 260.0;

  final Widget first;
  final Widget second;

  const _ResponsiveFieldPair({required this.first, required this.second});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStack =
            constraints.hasBoundedWidth &&
            constraints.maxWidth < _stackedBreakpoint;

        if (shouldStack) {
          return Column(children: [first, const SizedBox(height: 8), second]);
        }

        return Row(
          children: [
            Expanded(child: first),
            const SizedBox(width: 8),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

final List<String> _responsiveDeviceKeys = DeviceType.values
    .map((device) => device.name)
    .toList(growable: false);

Map<String, Size> _responsiveDeviceSizes(ResponsivePreviewState previewState) {
  return {
    for (final device in DeviceType.values)
      device.name: _responsiveDeviceSize(device, previewState),
  };
}

Size _responsiveDeviceSize(
  DeviceType device,
  ResponsivePreviewState previewState,
) {
  final state = ResponsivePreviewState(
    currentDevice: device,
    customSize: device == DeviceType.custom ? previewState.customSize : null,
  );

  return Size(state.width, state.height);
}

DeviceType? _deviceFromKey(String key) {
  for (final device in DeviceType.values) {
    if (device.name == key) return device;
  }

  return null;
}

IconData _deviceIcon(DeviceType device) {
  switch (device) {
    case DeviceType.mobile:
      return Icons.phone_iphone;
    case DeviceType.tablet:
      return Icons.tablet_mac;
    case DeviceType.desktop:
      return Icons.desktop_windows_outlined;
    case DeviceType.custom:
      return Icons.tune;
  }
}

String _deviceLabel(DeviceType device) {
  switch (device) {
    case DeviceType.mobile:
      return 'Mobile';
    case DeviceType.tablet:
      return 'Tablet';
    case DeviceType.desktop:
      return 'Desktop';
    case DeviceType.custom:
      return 'Custom';
  }
}
