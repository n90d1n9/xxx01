import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/component_type.dart';
import '../states/provider.dart';

class ComponentPalette extends ConsumerWidget {
  const ComponentPalette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(designerProvider);
    final notifier = ref.read(designerProvider.notifier);

    return Container(
      width: 220,
      color: state.isDarkMode ? Colors.grey.shade800 : Colors.white,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Components',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                _PaletteItem(
                  icon: Icons.crop_square,
                  label: 'Container',
                  onTap: () => notifier.addComponent(ComponentType.container),
                ),
                _PaletteItem(
                  icon: Icons.text_fields,
                  label: 'Text',
                  onTap: () => notifier.addComponent(ComponentType.text),
                ),
                _PaletteItem(
                  icon: Icons.smart_button,
                  label: 'Button',
                  onTap: () => notifier.addComponent(ComponentType.button),
                ),
                _PaletteItem(
                  icon: Icons.image,
                  label: 'Image',
                  onTap: () => notifier.addComponent(ComponentType.image),
                ),
                _PaletteItem(
                  icon: Icons.input,
                  label: 'Input',
                  onTap: () => notifier.addComponent(ComponentType.input),
                ),
                _PaletteItem(
                  icon: Icons.star,
                  label: 'Icon',
                  onTap: () => notifier.addComponent(ComponentType.icon),
                ),
                _PaletteItem(
                  icon: Icons.check_box,
                  label: 'Checkbox',
                  onTap: () => notifier.addComponent(ComponentType.checkbox),
                ),
                _PaletteItem(
                  icon: Icons.tune,
                  label: 'Slider',
                  onTap: () => notifier.addComponent(ComponentType.slider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PaletteItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 13)),
      onTap: onTap,
      dense: true,
    );
  }
}
