import 'package:flutter/material.dart';

import '../../form_designer/model/field_config.dart';

class DiffViewer extends StatelessWidget {
  final List<FieldConfig> oldFields;
  final List<FieldConfig> newFields;

  const DiffViewer({Key? key, required this.oldFields, required this.newFields})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final diffs = _computeDiffs();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildDiffStats(diffs),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView.builder(
              itemCount: diffs.length,
              itemBuilder: (context, index) {
                return _DiffItem(diff: diffs[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiffStats(List<FieldDiff> diffs) {
    final additions = diffs.where((d) => d.type == DiffType.added).length;
    final deletions = diffs.where((d) => d.type == DiffType.deleted).length;
    final modifications = diffs
        .where((d) => d.type == DiffType.modified)
        .length;

    return Row(
      children: [
        _DiffStatChip(
          icon: Icons.add_circle,
          count: additions,
          color: Colors.green,
          label: 'Added',
        ),
        const SizedBox(width: 8),
        _DiffStatChip(
          icon: Icons.remove_circle,
          count: deletions,
          color: Colors.red,
          label: 'Deleted',
        ),
        const SizedBox(width: 8),
        _DiffStatChip(
          icon: Icons.edit,
          count: modifications,
          color: Colors.blue,
          label: 'Modified',
        ),
      ],
    );
  }

  List<FieldDiff> _computeDiffs() {
    final diffs = <FieldDiff>[];

    // Find deleted and modified fields
    for (final oldField in oldFields) {
      final newField = newFields.firstWhere(
        (f) => f.id == oldField.id,
        orElse: () => FieldConfig(id: '', type: ''),
      );

      if (newField.id.isEmpty) {
        diffs.add(FieldDiff(type: DiffType.deleted, oldField: oldField));
      } else if (!_fieldsEqual(oldField, newField)) {
        diffs.add(
          FieldDiff(
            type: DiffType.modified,
            oldField: oldField,
            newField: newField,
          ),
        );
      }
    }

    // Find added fields
    for (final newField in newFields) {
      final exists = oldFields.any((f) => f.id == newField.id);
      if (!exists) {
        diffs.add(FieldDiff(type: DiffType.added, newField: newField));
      }
    }

    return diffs;
  }

  bool _fieldsEqual(FieldConfig a, FieldConfig b) {
    return a.label == b.label &&
        a.type == b.type &&
        a.required == b.required &&
        a.hint == b.hint;
  }
}

enum DiffType { added, deleted, modified }

class FieldDiff {
  final DiffType type;
  final FieldConfig? oldField;
  final FieldConfig? newField;

  const FieldDiff({required this.type, this.oldField, this.newField});
}

class _DiffItem extends StatelessWidget {
  final FieldDiff diff;

  const _DiffItem({required this.diff});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getIcon(), color: _getColor(), size: 20),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getTypeLabel(),
                  style: TextStyle(
                    color: _getColor(),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _getFieldLabel(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (diff.type == DiffType.modified) ...[
            _buildComparisonRow(
              'Label',
              diff.oldField!.label,
              diff.newField!.label,
            ),
            _buildComparisonRow(
              'Type',
              diff.oldField!.type,
              diff.newField!.type,
            ),
            _buildComparisonRow(
              'Required',
              diff.oldField!.required.toString(),
              diff.newField!.required.toString(),
            ),
          ] else if (diff.type == DiffType.added) ...[
            _buildFieldInfo(diff.newField!),
          ] else if (diff.type == DiffType.deleted) ...[
            _buildFieldInfo(diff.oldField!),
          ],
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String? oldValue, String? newValue) {
    if (oldValue == newValue) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                oldValue ?? 'null',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 16, color: Colors.white54),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                newValue ?? 'null',
                style: const TextStyle(color: Colors.green, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldInfo(FieldConfig field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(label: 'Type', value: field.type),
        if (field.label != null) _InfoRow(label: 'Label', value: field.label!),
        if (field.required) _InfoRow(label: 'Required', value: 'Yes'),
      ],
    );
  }

  Color _getColor() {
    switch (diff.type) {
      case DiffType.added:
        return Colors.green;
      case DiffType.deleted:
        return Colors.red;
      case DiffType.modified:
        return Colors.blue;
    }
  }

  Color _getBackgroundColor() {
    return _getColor();
  }

  Color _getBorderColor() {
    return _getColor().withOpacity(0.3);
  }

  IconData _getIcon() {
    switch (diff.type) {
      case DiffType.added:
        return Icons.add_circle;
      case DiffType.deleted:
        return Icons.remove_circle;
      case DiffType.modified:
        return Icons.edit;
    }
  }

  String _getTypeLabel() {
    switch (diff.type) {
      case DiffType.added:
        return 'ADDED';
      case DiffType.deleted:
        return 'DELETED';
      case DiffType.modified:
        return 'MODIFIED';
    }
  }

  String _getFieldLabel() {
    final field = diff.newField ?? diff.oldField!;
    return field.label ?? field.name ?? field.type;
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DiffStatChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final String label;

  const _DiffStatChip({
    required this.icon,
    required this.count,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
