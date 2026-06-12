import 'registry_health_export_options.dart';

class RegistryHealthExportPresetDescriptor {
  const RegistryHealthExportPresetDescriptor({
    required this.id,
    required this.label,
    required this.options,
  });

  final String id;
  final String label;
  final RegistryHealthExportOptions options;

  String get copyLabel =>
      id == 'full' ? 'Copy Health JSON' : 'Copy $label JSON';

  String get copiedLabel => id == 'full'
      ? 'Registry health JSON copied'
      : '$label registry health JSON copied';
}

const registryHealthExportPresetDescriptors =
    <RegistryHealthExportPresetDescriptor>[
      RegistryHealthExportPresetDescriptor(
        id: 'full',
        label: 'Full',
        options: RegistryHealthExportOptions.full,
      ),
      RegistryHealthExportPresetDescriptor(
        id: 'compact',
        label: 'Compact',
        options: RegistryHealthExportOptions.compact,
      ),
      RegistryHealthExportPresetDescriptor(
        id: 'release',
        label: 'Release',
        options: RegistryHealthExportOptions.release,
      ),
      RegistryHealthExportPresetDescriptor(
        id: 'planning',
        label: 'Planning',
        options: RegistryHealthExportOptions.planning,
      ),
    ];

RegistryHealthExportPresetDescriptor? registryHealthExportPresetById(
  String id,
) {
  final normalized = id.trim().toLowerCase();
  for (final preset in registryHealthExportPresetDescriptors) {
    if (preset.id == normalized) {
      return preset;
    }
  }
  return null;
}

RegistryHealthExportPresetDescriptor? registryHealthExportPresetForOptions(
  RegistryHealthExportOptions options,
) {
  return registryHealthExportPresetById(options.name);
}

RegistryHealthExportOptions registryHealthExportOptionsForPresetId(String id) {
  return registryHealthExportPresetById(id)?.options ??
      RegistryHealthExportOptions.full;
}

String registryHealthExportPresetLabelForOptions(
  RegistryHealthExportOptions options,
) {
  return registryHealthExportPresetForOptions(options)?.label ??
      _titleCaseName(options.name);
}

String registryHealthExportPresetCopyLabelForOptions(
  RegistryHealthExportOptions options,
) {
  return registryHealthExportPresetForOptions(options)?.copyLabel ??
      'Copy ${registryHealthExportPresetLabelForOptions(options)} JSON';
}

String registryHealthExportPresetCopiedLabelForOptions(
  RegistryHealthExportOptions options,
) {
  return registryHealthExportPresetForOptions(options)?.copiedLabel ??
      '${registryHealthExportPresetLabelForOptions(options)} registry health JSON copied';
}

String _titleCaseName(String value) {
  final words = value
      .trim()
      .split(RegExp(r'[\s_-]+'))
      .where((word) => word.isNotEmpty);
  final title = words
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
  return title.isEmpty ? 'Custom' : title;
}
