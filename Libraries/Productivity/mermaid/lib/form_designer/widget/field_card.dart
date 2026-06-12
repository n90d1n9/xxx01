import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/field_config.dart';
import '../states/form_field_provider.dart';

class FieldCard extends ConsumerWidget {
  final FieldConfig field;
  final int index;
  final int depth;

  const FieldCard({
    Key? key,
    required this.field,
    required this.index,
    this.depth = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedField = ref.watch(selectedFieldProvider);
    final isSelected = selectedField?.id == field.id;
    final previewMode = ref.watch(previewModeProvider);

    return Container(
      margin: EdgeInsets.only(bottom: 12, left: depth > 0 ? 0 : 0),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        border: Border.all(
          color: isSelected ? Colors.blue : const Color(0xFF3D3D3D),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: previewMode
            ? null
            : () {
                ref.read(selectedFieldProvider.notifier).state = field;
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!previewMode)
                Icon(
                  Icons.drag_indicator,
                  color: Colors.white.withOpacity(0.3),
                  size: 20,
                ),
              if (!previewMode) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (field.label != null || field.title != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text(
                              field.label ?? field.title ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (field.required)
                              const Text(
                                ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    _buildFieldPreview(field),
                    if (field.helperText != null &&
                        field.helperText!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          field.helperText!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (field.visibleIf != null &&
                        field.visibleIf!.isNotEmpty &&
                        !previewMode)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.visibility,
                                size: 14,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Visible if: ${field.visibleIf}',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!previewMode) ...[
                const SizedBox(width: 12),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.content_copy, size: 18),
                      color: Colors.white70,
                      tooltip: 'Duplicate',
                      onPressed: () {
                        ref
                            .read(formFieldsProvider.notifier)
                            .duplicateField(field);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      color: Colors.red,
                      tooltip: 'Delete',
                      onPressed: () {
                        ref
                            .read(formFieldsProvider.notifier)
                            .deleteField(field.id);
                        if (selectedField?.id == field.id) {
                          ref.read(selectedFieldProvider.notifier).state = null;
                        }
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldPreview(FieldConfig field) {
    switch (field.type) {
      case 'text':
      case 'email':
      case 'password':
      case 'url':
      case 'tel':
      case 'number':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border.all(color: const Color(0xFF3D3D3D)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            field.hint ?? 'Enter ${field.label?.toLowerCase()}',
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        );

      case 'textarea':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          height: (field.maxLines ?? 4) * 24.0,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border.all(color: const Color(0xFF3D3D3D)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            field.hint ?? 'Enter text...',
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        );

      case 'select':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border.all(color: const Color(0xFF3D3D3D)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select an option',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.white70),
            ],
          ),
        );

      case 'checkbox':
        return Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              field.label ?? 'Checkbox',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        );

      case 'switch':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              field.label ?? 'Switch',
              style: const TextStyle(color: Colors.white),
            ),
            Container(
              width: 48,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        );

      case 'radio':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              field.options?.map<Widget>((option) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        option.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              }).toList() ??
              [],
        );

      case 'chips':
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              field.options?.map<Widget>((option) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    option.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                );
              }).toList() ??
              [],
        );

      case 'slider':
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${field.min ?? 0}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '${field.max ?? 100}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                widthFactor: 0.5,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        );

      case 'date':
      case 'time':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border.all(color: const Color(0xFF3D3D3D)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                field.type == 'date' ? 'Select date' : 'Select time',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
              Icon(
                field.type == 'date' ? Icons.calendar_today : Icons.access_time,
                color: Colors.white70,
                size: 18,
              ),
            ],
          ),
        );

      case 'rating':
        return Row(
          children: List.generate(
            field.maxRating ?? 5,
            (index) =>
                const Icon(Icons.star_border, color: Colors.amber, size: 28),
          ),
        );

      case 'tags':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: const Text('Tag 1', style: TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {},
                  backgroundColor: const Color(0xFF3D3D3D),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                border: Border.all(color: const Color(0xFF3D3D3D)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Add tag...',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ),
          ],
        );

      case 'section':
        return Container(
          padding: const EdgeInsets.only(left: 12),
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: Colors.blue, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.title ?? 'Section Title',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (field.description != null && field.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    field.description!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        );

      case 'divider':
        return const Divider(color: Color(0xFF3D3D3D), thickness: 1);

      case 'html':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            field.content ?? 'HTML content',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        );

      default:
        return Text(
          'Unknown type: ${field.type}',
          style: const TextStyle(color: Colors.red),
        );
    }
  }
}
