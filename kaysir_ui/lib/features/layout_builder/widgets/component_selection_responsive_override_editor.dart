import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../provider/layout_state_provider.dart';
import '../provider/review_state.dart';
import 'component_inspector_controls.dart';

/// Edits responsive override actions for a multi-component selection.
class ComponentSelectionResponsiveOverrideEditor extends ConsumerWidget {
  final List<ComponentData> components;
  final ResponsivePreviewState previewState;

  const ComponentSelectionResponsiveOverrideEditor({
    super.key,
    required this.components,
    required this.previewState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(layoutStateProvider.notifier);
    final currentDevice = previewState.currentDevice;
    final currentDeviceKey = currentDevice.name;
    final currentOverrideCount =
        components
            .where(
              (component) =>
                  component.responsiveProperties.containsKey(currentDeviceKey),
            )
            .length;
    final anyOverrideCount =
        components
            .where((component) => component.responsiveProperties.isNotEmpty)
            .length;
    final constrainedCount =
        components
            .where(
              (component) =>
                  !component.isLocked && component.constraints.hasCustomRules,
            )
            .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Responsive overrides',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ComponentInspectorChip(
              icon: _deviceIcon(currentDevice),
              label: _deviceLabel(currentDevice),
            ),
            if (currentOverrideCount > 0)
              ComponentInspectorChip(
                icon: Icons.devices_outlined,
                label: '$currentOverrideCount current',
              ),
            if (anyOverrideCount > 0)
              ComponentInspectorChip(
                icon: Icons.layers_outlined,
                label: '$anyOverrideCount with overrides',
              ),
            if (constrainedCount > 0)
              ComponentInspectorChip(
                icon: Icons.anchor_outlined,
                label: '$constrainedCount constrained',
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ResponsiveSelectionActionButton(
              icon: Icons.copy_all_outlined,
              label: 'Copy base',
              onPressed:
                  () => notifier.setSelectedResponsivePropertiesFromBase(
                    currentDeviceKey,
                  ),
            ),
            _ResponsiveSelectionActionButton(
              icon: Icons.devices_outlined,
              label: 'Base to all',
              onPressed:
                  () => notifier
                      .setSelectedResponsivePropertiesFromBaseForDevices(
                        _responsiveDeviceKeys,
                      ),
            ),
            _ResponsiveSelectionActionButton(
              icon: Icons.compare_arrows,
              label: 'Current to all',
              onPressed:
                  () => notifier.copySelectedResponsivePropertiesToDevices(
                    currentDeviceKey,
                    _responsiveDeviceKeys,
                  ),
            ),
            _ResponsiveSelectionActionButton(
              icon: Icons.auto_fix_high_outlined,
              label: 'Apply rules',
              onPressed:
                  constrainedCount == 0
                      ? null
                      : () => notifier.applySelectedResponsiveConstraints(
                        currentDeviceKey,
                        _responsiveDeviceSize(currentDevice, previewState),
                      ),
            ),
            _ResponsiveSelectionActionButton(
              icon: Icons.fit_screen_outlined,
              label: 'Rules to all',
              onPressed:
                  constrainedCount == 0
                      ? null
                      : () =>
                          notifier.applySelectedResponsiveConstraintsForDevices(
                            _responsiveDeviceSizes(previewState),
                          ),
            ),
            if (currentOverrideCount > 0)
              _ResponsiveSelectionActionButton(
                icon: Icons.publish_outlined,
                label: 'Use as base',
                onPressed:
                    () => notifier.promoteSelectedResponsivePropertiesToBase(
                      currentDeviceKey,
                    ),
              ),
            if (currentOverrideCount > 0)
              _ResponsiveSelectionActionButton(
                icon: Icons.restart_alt,
                label: 'Reset device',
                onPressed:
                    () => notifier.clearSelectedResponsiveProperties(
                      currentDeviceKey,
                    ),
              ),
            if (anyOverrideCount > 0)
              _ResponsiveSelectionActionButton(
                icon: Icons.layers_clear_outlined,
                label: 'Reset all',
                onPressed: notifier.clearAllSelectedResponsiveProperties,
              ),
          ],
        ),
      ],
    );
  }
}

/// Displays one responsive selection action.
class _ResponsiveSelectionActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ResponsiveSelectionActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}

/// Renders the multi-selection responsive override editor with sample data.
@Preview(name: 'Component selection responsive override editor')
Widget componentSelectionResponsiveOverrideEditorPreview() {
  final components = [
    ComponentData.create(
      id: 'preview-selection-responsive-a',
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
    ),
    ComponentData.create(
      id: 'preview-selection-responsive-b',
      type: ComponentType.customButton,
      position: const Offset(240, 48),
      size: const Size(180, 64),
    ),
  ];

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ComponentSelectionResponsiveOverrideEditor(
                components: components,
                previewState: ResponsivePreviewState.mobile,
              ),
            ),
          ),
        ),
      ),
    ),
  );
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
