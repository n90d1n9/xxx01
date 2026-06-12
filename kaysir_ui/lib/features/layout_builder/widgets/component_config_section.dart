import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Provides the shared card-like shell for component-specific inspector panels.
class ComponentConfigSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ComponentConfigSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders the reusable component config section shell.
@Preview(name: 'Component config section')
Widget componentConfigSectionPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 320,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: ComponentConfigSection(
              title: 'Text appearance',
              children: [
                Text('Button label'),
                SizedBox(height: 8),
                Text('Font size 14'),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
