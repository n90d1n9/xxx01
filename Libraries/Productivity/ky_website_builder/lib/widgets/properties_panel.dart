import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/component_animation.dart';
import '../models/design_component.dart';
import '../states/component_provider.dart';
import '../states/provider.dart';

class PropertiesPanel extends ConsumerWidget {
  const PropertiesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(designerProvider);
    final selected = ref.watch(selectedComponentProvider);

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: state.isDarkMode ? Colors.grey.shade900 : Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: selected == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Select a component',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(selected),
                  const SizedBox(height: 24),
                  _PropertySection(title: 'General', component: selected),
                  const SizedBox(height: 16),
                  _DimensionSection(component: selected),
                  const SizedBox(height: 16),
                  _StyleSection(component: selected),
                  const SizedBox(height: 16),
                  _AnimationSection(component: selected),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(DesignComponent component) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.widgets, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  component.name!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  component.type.name,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          if (component.locked)
            const Icon(Icons.lock, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}

class _PropertySection extends ConsumerWidget {
  final String title;
  final DesignComponent component;

  const _PropertySection({required this.title, required this.component});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(designerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          title: const Text('Locked', style: TextStyle(fontSize: 13)),
          value: component.locked,
          onChanged: (v) => notifier.updateComponent(
            component.id,
            component.copyWith(locked: v),
          ),
          dense: true,
        ),
        CheckboxListTile(
          title: const Text('Visible', style: TextStyle(fontSize: 13)),
          value: component.visible,
          onChanged: (v) => notifier.updateComponent(
            component.id,
            component.copyWith(visible: v),
          ),
          dense: true,
        ),
      ],
    );
  }
}

class _DimensionSection extends ConsumerWidget {
  final DesignComponent component;

  const _DimensionSection({required this.component});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Position & Size',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildField('X', component.position.dx)),
            const SizedBox(width: 8),
            Expanded(child: _buildField('Y', component.position.dy)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildField('W', component.size.width)),
            const SizedBox(width: 8),
            Expanded(child: _buildField('H', component.size.height)),
          ],
        ),
      ],
    );
  }

  Widget _buildField(String label, double value) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      controller: TextEditingController(text: value.toStringAsFixed(0)),
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 12),
    );
  }
}

class _StyleSection extends StatelessWidget {
  final DesignComponent component;

  const _StyleSection({required this.component});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Style',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Style properties here',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _AnimationSection extends StatelessWidget {
  final DesignComponent component;

  const _AnimationSection({required this.component});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Animation',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<AnimationType>(
          value: component.animation.type,
          decoration: const InputDecoration(
            labelText: 'Type',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: AnimationType.values.take(15).map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.name, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
          onChanged: (v) {},
        ),
      ],
    );
  }
}
