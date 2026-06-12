import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import '../provider/responsive_preview_provider.dart';
import '../provider/review_state.dart';

const _maxRecentCustomPreviewSizeCount = 5;

final recentCustomPreviewSizePresets = <CustomPreviewSizePreset>[];

const _devicePreviewOptions = [
  KyBuilderSegmentOption(
    value: DeviceType.desktop,
    label: 'Desktop',
    icon: Icons.desktop_windows,
    tooltip: 'Desktop preview',
  ),
  KyBuilderSegmentOption(
    value: DeviceType.tablet,
    label: 'Tablet',
    icon: Icons.tablet,
    tooltip: 'Tablet preview',
  ),
  KyBuilderSegmentOption(
    value: DeviceType.mobile,
    label: 'Mobile',
    icon: Icons.smartphone,
    tooltip: 'Mobile preview',
  ),
  KyBuilderSegmentOption(
    value: DeviceType.custom,
    label: 'Custom',
    icon: Icons.aspect_ratio,
    tooltip: 'Custom preview size',
  ),
];

/// Switches the layout builder preview between responsive device sizes.
class DevicePreviewToggle extends ConsumerWidget {
  const DevicePreviewToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewState = ref.watch(responsivePreviewProvider);
    final previewSizeLabel =
        '${previewState.width.round()} x ${previewState.height.round()}';
    final previewSizeTooltip =
        '${_deviceTypeLabel(previewState.currentDevice)} preview size - click to edit';
    final rotateTooltip =
        previewState.currentDevice == DeviceType.custom
            ? 'Rotate custom preview size'
            : 'Rotate as custom preview size';
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        KyBuilderSegmentedSelector<DeviceType>(
          options: _devicePreviewOptions,
          selectedValue: previewState.currentDevice,
          showLabels: false,
          onChanged: (device) {
            if (device == DeviceType.custom) {
              showCustomPreviewSizeDialog(context, ref);
              return;
            }

            ref.read(responsivePreviewProvider.notifier).setDevice(device);
          },
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: previewSizeTooltip,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => showCustomPreviewSizeDialog(context, ref),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              child: Text(
                previewSizeLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 2),
        Tooltip(
          message: rotateTooltip,
          child: IconButton(
            icon: const Icon(Icons.screen_rotation, size: 18),
            visualDensity: VisualDensity.compact,
            onPressed: () {
              rememberRotatedPreviewSize(previewState);
              ref.read(responsivePreviewProvider.notifier).rotateCurrentSize();
            },
          ),
        ),
        if (previewState.currentDevice == DeviceType.custom) ...[
          Tooltip(
            message: 'Edit custom preview size',
            child: IconButton(
              icon: const Icon(Icons.tune, size: 18),
              visualDensity: VisualDensity.compact,
              onPressed: () => showCustomPreviewSizeDialog(context, ref),
            ),
          ),
        ],
      ],
    );
  }
}

@Preview(name: 'Device preview toggle')
Widget devicePreviewTogglePreview() {
  return const ProviderScope(
    child: MaterialApp(
      home: Scaffold(body: Center(child: DevicePreviewToggle())),
    ),
  );
}

String _deviceTypeLabel(DeviceType device) {
  switch (device) {
    case DeviceType.desktop:
      return 'Desktop';
    case DeviceType.tablet:
      return 'Tablet';
    case DeviceType.mobile:
      return 'Mobile';
    case DeviceType.custom:
      return 'Custom';
  }
}

Future<void> showCustomPreviewSizeDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final previewState = ref.read(responsivePreviewProvider);
  final widthController = TextEditingController(
    text: previewState.width.round().toString(),
  );
  final heightController = TextEditingController(
    text: previewState.height.round().toString(),
  );
  final formKey = GlobalKey<FormState>();

  try {
    await showDialog<void>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setDialogState) {
              final hasRecentPresets =
                  recentCustomPreviewSizePresets.isNotEmpty;

              void setDimensions(int width, int height) {
                widthController.text = width.toString();
                heightController.text = height.toString();
                setDialogState(() {});
              }

              void swapDimensions() {
                final width = widthController.text;
                widthController.text = heightController.text;
                heightController.text = width;
                setDialogState(() {});
              }

              final builtInPresets = builtInCustomPreviewSizePresets;
              final recentPresets = List<CustomPreviewSizePreset>.from(
                recentCustomPreviewSizePresets,
              );
              final availablePresets = [...builtInPresets, ...recentPresets];
              final activePreset = _activeCustomPreviewPreset(
                widthController.text,
                heightController.text,
                availablePresets,
              );

              return AlertDialog(
                title: const Text('Custom preview size'),
                content: SizedBox(
                  width: 420,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (recentPresets.isNotEmpty) ...[
                          _CustomPreviewPresetSection(
                            title: 'Recent',
                            children: [
                              for (final preset in recentPresets)
                                InputChip(
                                  avatar: Icon(preset.icon, size: 16),
                                  label: Text(preset.label),
                                  selected: activePreset == preset,
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    removeRecentCustomPreviewSize(
                                      preset.width,
                                      preset.height,
                                    );
                                    setDialogState(() {});
                                  },
                                  onSelected:
                                      (_) => setDimensions(
                                        preset.width,
                                        preset.height,
                                      ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        _CustomPreviewPresetSection(
                          title: 'Built-in',
                          children: [
                            for (final preset in builtInPresets)
                              ChoiceChip(
                                avatar: Icon(preset.icon, size: 16),
                                label: Text(preset.label),
                                selected: activePreset == preset,
                                onSelected:
                                    (_) => setDimensions(
                                      preset.width,
                                      preset.height,
                                    ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: widthController,
                                decoration: const InputDecoration(
                                  labelText: 'Width',
                                  suffixText: 'px',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) => _dimensionError(value),
                                onChanged: (_) => setDialogState(() {}),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Tooltip(
                              message: 'Swap width and height',
                              child: IconButton.outlined(
                                icon: const Icon(Icons.swap_horiz),
                                onPressed: swapDimensions,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: heightController,
                                decoration: const InputDecoration(
                                  labelText: 'Height',
                                  suffixText: 'px',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) => _dimensionError(value),
                                onChanged: (_) => setDialogState(() {}),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  if (hasRecentPresets)
                    TextButton.icon(
                      icon: const Icon(Icons.history_toggle_off),
                      label: const Text('Clear recent'),
                      onPressed: () {
                        clearRecentCustomPreviewSizes();
                        setDialogState(() {});
                      },
                    ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() != true) return;

                      final width = int.parse(widthController.text);
                      final height = int.parse(heightController.text);
                      rememberCustomPreviewSize(width, height);
                      ref
                          .read(responsivePreviewProvider.notifier)
                          .setCustomBreakpoint(
                            width.toDouble(),
                            height.toDouble(),
                          );
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Apply'),
                  ),
                ],
              );
            },
          ),
    );
  } finally {
    widthController.dispose();
    heightController.dispose();
  }
}

/// Groups custom preview size presets in the custom-size dialog.
class _CustomPreviewPresetSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _CustomPreviewPresetSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

List<CustomPreviewSizePreset> get allCustomPreviewSizePresets => [
  ...builtInCustomPreviewSizePresets,
  ...recentCustomPreviewSizePresets,
];

List<CustomPreviewSizePreset> get builtInCustomPreviewSizePresets => [
  ...customPreviewSizePresets,
  ...landscapeCustomPreviewSizePresets,
];

const customPreviewSizePresets = [
  CustomPreviewSizePreset(
    label: 'Phone',
    width: 390,
    height: 844,
    icon: Icons.smartphone,
  ),
  CustomPreviewSizePreset(
    label: 'Compact',
    width: 360,
    height: 800,
    icon: Icons.phone_android,
  ),
  CustomPreviewSizePreset(
    label: 'Tablet',
    width: 768,
    height: 1024,
    icon: Icons.tablet,
  ),
  CustomPreviewSizePreset(
    label: 'Laptop',
    width: 1366,
    height: 768,
    icon: Icons.laptop_mac,
  ),
  CustomPreviewSizePreset(
    label: 'Desktop',
    width: 1440,
    height: 900,
    icon: Icons.desktop_windows,
  ),
];

List<CustomPreviewSizePreset> get landscapeCustomPreviewSizePresets => [
  for (final preset in customPreviewSizePresets)
    if (preset.height > preset.width) CustomPreviewSizePreset.landscape(preset),
];

void rememberCustomPreviewSize(int width, int height) {
  if (_presetForSize(width, height, builtInCustomPreviewSizePresets) != null) {
    return;
  }

  recentCustomPreviewSizePresets.removeWhere(
    (preset) => preset.width == width && preset.height == height,
  );
  recentCustomPreviewSizePresets.insert(
    0,
    CustomPreviewSizePreset.recent(width: width, height: height),
  );

  if (recentCustomPreviewSizePresets.length >
      _maxRecentCustomPreviewSizeCount) {
    recentCustomPreviewSizePresets.removeRange(
      _maxRecentCustomPreviewSizeCount,
      recentCustomPreviewSizePresets.length,
    );
  }
}

void rememberRotatedPreviewSize(ResponsivePreviewState previewState) {
  rememberCustomPreviewSize(
    previewState.height.round(),
    previewState.width.round(),
  );
}

void removeRecentCustomPreviewSize(int width, int height) {
  recentCustomPreviewSizePresets.removeWhere(
    (preset) => preset.width == width && preset.height == height,
  );
}

void clearRecentCustomPreviewSizes() {
  recentCustomPreviewSizePresets.clear();
}

CustomPreviewSizePreset? _activeCustomPreviewPreset(
  String widthValue,
  String heightValue,
  Iterable<CustomPreviewSizePreset> presets,
) {
  final width = int.tryParse(widthValue);
  final height = int.tryParse(heightValue);
  if (width == null || height == null) return null;

  return _presetForSize(width, height, presets);
}

CustomPreviewSizePreset? _presetForSize(
  int width,
  int height,
  Iterable<CustomPreviewSizePreset> presets,
) {
  for (final preset in presets) {
    if (preset.width == width && preset.height == height) {
      return preset;
    }
  }

  return null;
}

/// Describes a named responsive preview size preset.
class CustomPreviewSizePreset {
  final String label;
  final int width;
  final int height;
  final IconData icon;

  const CustomPreviewSizePreset({
    required this.label,
    required this.width,
    required this.height,
    required this.icon,
  });

  CustomPreviewSizePreset.recent({required this.width, required this.height})
    : label = '$width x $height',
      icon = Icons.aspect_ratio;

  CustomPreviewSizePreset.landscape(CustomPreviewSizePreset preset)
    : label = '${preset.label} landscape',
      width = preset.height,
      height = preset.width,
      icon = preset.icon;
}

String? _dimensionError(String? value) {
  final dimension = int.tryParse(value ?? '');
  if (dimension == null) return 'Required';
  if (dimension < 240 || dimension > 2400) return '240-2400';
  return null;
}
