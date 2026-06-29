import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/field_config.dart';
import '../model/form_theme.dart';
import '../model/theme/border_style.dart' as b;
import '../states/dragDropManager_provider.dart';
import '../states/form_field_provider.dart';
import 'dragdrop/draggable_field_card.dart';
import 'grid/grid_sbap_system.dart';

class FormCanvasWidget extends ConsumerWidget {
  final FormTheme theme;
  const FormCanvasWidget({super.key, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fields = ref.watch(formFieldsProvider);
    final dragDropState = ref.watch(dragDropManagerProvider);
    final showGrid = ref.watch(showGridProvider);

    if (fields.isEmpty) {
      return Stack(
        children: [
          if (showGrid) GridSnapSystem.buildGridOverlay(theme),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox,
                  size: 80,
                  color: theme.colors.textSecondary.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Drag components here to start',
                  style: TextStyle(color: theme.colors.textSecondary),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.touch_app, color: theme.colors.primary),
                      const SizedBox(height: 8),
                      Text(
                        'Long press to drag',
                        style: TextStyle(
                          color: theme.colors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        // Grid overlay
        if (showGrid) GridSnapSystem.buildGridOverlay(theme),

        // Fields
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: fields.asMap().entries.map((entry) {
                  return DraggableFieldCard(
                    key: ValueKey(entry.value.id),
                    field: entry.value,
                    index: entry.key,
                    theme: theme,
                    child: _buildFieldPreview(entry.value),
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        // Drop zone at the end
        if (dragDropState.isDragging)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DragTarget<FieldConfig>(
              onWillAccept: (data) => true,
              onAccept: (field) {
                ref.read(formFieldsProvider.notifier).deleteField(field.id);
                ref.read(formFieldsProvider.notifier).addField(field);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  height: candidateData.isNotEmpty ? 80 : 40,
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? theme.colors.primary.withOpacity(0.3)
                        : theme.colors.border.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: candidateData.isNotEmpty
                          ? theme.colors.primary
                          : theme.colors.border,
                      width: 2,
                      //style: BorderStyle.dashed,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: candidateData.isNotEmpty
                              ? theme.colors.primary
                              : theme.colors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          candidateData.isNotEmpty
                              ? 'Drop here to add at end'
                              : 'Drop zone',
                          style: TextStyle(
                            color: candidateData.isNotEmpty
                                ? theme.colors.primary
                                : theme.colors.textSecondary,
                            fontWeight: candidateData.isNotEmpty
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        // Drag indicator overlay
        if (dragDropState.isDragging)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: theme.colors.background.withOpacity(0.1)),
            ),
          ),
      ],
    );
  }

  Widget _buildFieldPreview(FieldConfig field) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.drag_indicator,
            color: theme.colors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.label ?? field.name ?? field.type,
                  style: TextStyle(
                    color: theme.colors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    field.type,
                    style: TextStyle(
                      color: theme.colors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
