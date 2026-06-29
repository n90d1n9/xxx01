import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component_template.dart';

class ComponentDetailsDialog extends ConsumerWidget {
  final ComponentTemplate component;

  const ComponentDetailsDialog({super.key, required this.component});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, theme, colorScheme),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Info
                    _buildBasicInfo(theme),
                    const SizedBox(height: 24),

                    // Description
                    _buildDescription(theme),
                    const SizedBox(height: 24),

                    // Configuration
                    _buildConfiguration(theme),
                    const SizedBox(height: 24),

                    // Examples
                    _buildExamples(theme),
                    const SizedBox(height: 24),

                    // Properties Table
                    _buildPropertiesTable(theme),
                  ],
                ),
              ),
            ),

            // Footer Actions
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: component.color.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: component.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(component.icon, color: component.color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  component.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (component.eipPattern != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    component.eipPattern!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: component.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(ThemeData theme) {
    return Row(
      children: [
        // Category
        _buildInfoChip(
          label: component.categoryId ?? 'Uncategorized',
          icon: Icons.category,
          theme: theme,
        ),
        const SizedBox(width: 12),

        // Type
        _buildInfoChip(
          label: component.type.name,
          icon: Icons.type_specimen,
          theme: theme,
        ),

        const Spacer(),

        // Version if available
        if (component.version != null)
          Text(
            'v${component.version}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.disabledColor,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoChip({
    required String label,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.disabledColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          component.description,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ],
    );
  }

  Widget _buildConfiguration(ThemeData theme) {
    if (component.configuration!.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuration',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              component.configuration!.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh.withOpacity(
                      0.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: component.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.value.toString(),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildExamples(ThemeData theme) {
    if (component.examples!.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Examples',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...component.examples!.asMap().entries.map((entry) {
          final index = entry.key;
          final example = entry.value;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Example ${index + 1}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  example,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'Monospace',
                    backgroundColor: theme.colorScheme.surfaceVariant
                        .withOpacity(0.3),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPropertiesTable(ThemeData theme) {
    final properties = component.properties;
    if (properties.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Properties',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Property',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Type',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Required',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Table Rows
              ...properties.map((prop) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: theme.dividerColor)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          prop.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(flex: 3, child: Text(prop.description!)),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(prop.type, theme),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            prop.type,
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          prop.required ? 'Yes' : 'No',
                          style: TextStyle(
                            color: prop.required ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(String type, ThemeData theme) {
    final typeColors = {
      'string': Colors.blue,
      'number': Colors.green,
      'boolean': Colors.orange,
      'object': Colors.purple,
      'array': Colors.teal,
      'enum': Colors.pink,
    };

    return typeColors[type.toLowerCase()] ?? theme.primaryColor;
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          // Documentation Link
          if (component.documentationUrl != null)
            TextButton.icon(
              onPressed: () {
                // Open documentation URL
                _launchUrl(component.documentationUrl!);
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Documentation'),
            ),

          const Spacer(),

          // Cancel Button
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),

          const SizedBox(width: 12),

          // Use Component Button
          ElevatedButton(
            onPressed: () {
              // Add component to canvas or trigger usage
              _useComponent(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: component.color,
              foregroundColor: Colors.white,
            ),
            child: const Text('Use Component'),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    // Implement URL launching logic
    // You might use url_launcher package for this
    try {
      // Example with url_launcher:
      // if (await canLaunch(url)) {
      //   await launch(url);
      // }
      print('Launching URL: $url');
    } catch (e) {
      print('Failed to launch URL: $e');
    }
  }

  void _useComponent(BuildContext context) {
    // Implement component usage logic
    // This could add the component to a canvas or trigger some action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${component.name} component selected'),
        backgroundColor: component.color,
      ),
    );

    Navigator.of(context).pop(component);
  }
}
