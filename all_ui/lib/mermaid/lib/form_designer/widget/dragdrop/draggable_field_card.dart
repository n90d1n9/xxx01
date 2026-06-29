import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/drag_drop_state.dart';
import '../../model/field_config.dart';
import '../../model/form_theme.dart';
import '../../states/dragDropManager_provider.dart';
import '../../states/form_field_provider.dart';
import 'drop_zone_indicator.dart';

class DraggableFieldCard extends ConsumerWidget {
  final FieldConfig field;
  final int index;
  final FormTheme theme;
  final Widget child;

  const DraggableFieldCard({
    super.key,
    required this.field,
    required this.index,
    required this.theme,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dragDropState = ref.watch(dragDropManagerProvider);
    final isDragging = dragDropState.draggedFieldId == field.id;
    final isHoverTarget = dragDropState.hoverTargetId == field.id;

    return Column(
      children: [
        // Drop zone before
        if (dragDropState.isDragging &&
            dragDropState.draggedFieldId != field.id)
          DropZoneIndicator(
            isActive:
                isHoverTarget &&
                dragDropState.dropPosition == DropPosition.before,
            position: DropPosition.before,
            theme: theme,
          ),

        // Draggable field
        LongPressDraggable<FieldConfig>(
          data: field,
          feedback: _buildDragFeedback(),
          childWhenDragging: _buildGhostPlaceholder(),
          onDragStarted: () {
            ref
                .read(dragDropManagerProvider.notifier)
                .startDrag(field.id, index);
          },
          onDragEnd: (details) {
            ref.read(dragDropManagerProvider.notifier).endDrag();
          },
          child: DragTarget<FieldConfig>(
            onWillAccept: (data) {
              if (data?.id == field.id) return false;
              ref
                  .read(dragDropManagerProvider.notifier)
                  .updateHover(
                    field.id,
                    field.isContainer
                        ? DropPosition.inside
                        : DropPosition.after,
                  );
              return true;
            },
            onAccept: (draggedField) {
              _handleDrop(ref, draggedField);
            },
            onLeave: (data) {
              ref
                  .read(dragDropManagerProvider.notifier)
                  .updateHover(null, null);
            },
            builder: (context, candidateData, rejectedData) {
              return AnimatedOpacity(
                opacity: isDragging ? 0.3 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    border: isHoverTarget
                        ? Border.all(color: theme.colors.primary, width: 2)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: child,
                ),
              );
            },
          ),
        ),

        // Drop zone after
        if (dragDropState.isDragging &&
            dragDropState.draggedFieldId != field.id)
          DropZoneIndicator(
            isActive:
                isHoverTarget &&
                dragDropState.dropPosition == DropPosition.after,
            position: DropPosition.after,
            theme: theme,
          ),

        // Drop zone inside (for containers)
        if (field.isContainer && dragDropState.isDragging)
          DropZoneIndicator(
            isActive:
                isHoverTarget &&
                dragDropState.dropPosition == DropPosition.inside,
            position: DropPosition.inside,
            theme: theme,
          ),
      ],
    );
  }

  Widget _buildDragFeedback() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colors.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colors.primary, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_indicator, color: theme.colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.label ?? field.name ?? field.type,
                    style: TextStyle(
                      color: theme.colors.text,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    field.type,
                    style: TextStyle(
                      color: theme.colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGhostPlaceholder() {
    return Opacity(
      opacity: 0.3,
      child: Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colors.primary,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.motion_photos_on,
            color: theme.colors.primary,
            size: 32,
          ),
        ),
      ),
    );
  }

  void _handleDrop(WidgetRef ref, FieldConfig draggedField) {
    final dragDropState = ref.read(dragDropManagerProvider);
    final position = dragDropState.dropPosition;

    if (position == DropPosition.inside && field.isContainer) {
      // Add to container
      ref
          .read(formFieldsProvider.notifier)
          .addField(draggedField, parentId: field.id);
      ref.read(formFieldsProvider.notifier).deleteField(draggedField.id);
    } else if (position == DropPosition.before) {
      // Insert before
      final fields = ref.read(formFieldsProvider);
      final targetIndex = fields.indexWhere((f) => f.id == field.id);
      if (targetIndex != -1) {
        ref.read(formFieldsProvider.notifier).deleteField(draggedField.id);
        ref
            .read(formFieldsProvider.notifier)
            .insertFieldAt(draggedField, targetIndex);
      }
    } else if (position == DropPosition.after) {
      // Insert after
      final fields = ref.read(formFieldsProvider);
      final targetIndex = fields.indexWhere((f) => f.id == field.id);
      if (targetIndex != -1) {
        ref.read(formFieldsProvider.notifier).deleteField(draggedField.id);
        ref
            .read(formFieldsProvider.notifier)
            .insertFieldAt(draggedField, targetIndex + 1);
      }
    }
  }
}
