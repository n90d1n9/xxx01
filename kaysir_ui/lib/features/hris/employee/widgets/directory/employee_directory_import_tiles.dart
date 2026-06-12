import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_import_models.dart';
import '../../models/employee_directory_models.dart';

class EmployeeDirectoryImportRowTile extends StatelessWidget {
  final EmployeeDirectoryImportRow row;

  const EmployeeDirectoryImportRowTile({super.key, required this.row});

  @override
  Widget build(BuildContext context) {
    final color =
        row.isValid ? const Color(0xFF15803D) : const Color(0xFFB91C1C);
    final status = row.isValid ? 'Ready' : 'Needs review';

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              row.isValid ? Icons.check_circle_outline : Icons.error_outline,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Row ${row.rowNumber}: ${row.draft.name.isEmpty ? 'Unnamed employee' : row.draft.name}',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: status, color: color),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${row.draft.position} - ${row.draft.department}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      icon: Icons.email_outlined,
                      label: row.draft.email,
                    ),
                    _MetaChip(
                      icon: Icons.verified_user_outlined,
                      label: row.draft.status.label,
                    ),
                  ],
                ),
                if (row.errors.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    row.errors.join(' | '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFB91C1C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: HrisColors.muted),
          const SizedBox(width: 5),
          Text(
            label.isEmpty ? 'Missing' : label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}
