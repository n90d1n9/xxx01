import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/profile_comparison.dart';
import 'profile_comparison_row_tile.dart';

class ProfileComparisonMatrix extends StatelessWidget {
  final List<ProfileComparisonRow> rows;
  final String activeProfileId;
  final int? totalProfileCount;
  final String query;
  final ValueChanged<String> onProfileSelected;
  final ValueChanged<String>? onProfileDetailsRequested;

  const ProfileComparisonMatrix({
    super.key,
    required this.rows,
    required this.activeProfileId,
    this.totalProfileCount,
    this.query = '',
    required this.onProfileSelected,
    this.onProfileDetailsRequested,
  }) : assert(totalProfileCount == null || totalProfileCount >= 0);

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final totalCount = totalProfileCount ?? rows.length;

    return Column(
      key: const ValueKey('profile_comparison_matrix'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Profile matrix',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: POSUiTokens.gap),
            Text(
              _comparisonCountLabel(
                visibleCount: rows.length,
                totalCount: totalCount,
                query: query,
              ),
              key: const ValueKey('profile_comparison_count'),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: POSUiTokens.gap),
        ...rows.map(
          (row) => ProfileComparisonRowTile(
            key: ValueKey('profile_comparison_row_${row.profileId}'),
            row: row,
            selected: row.profileId == activeProfileId,
            onSelected:
                row.profileId == activeProfileId
                    ? null
                    : () => onProfileSelected(row.profileId),
            onDetailsRequested:
                onProfileDetailsRequested == null
                    ? null
                    : () => onProfileDetailsRequested!(row.profileId),
          ),
        ),
      ],
    );
  }
}

String _comparisonCountLabel({
  required int visibleCount,
  required int totalCount,
  required String query,
}) {
  return query.trim().isEmpty
      ? '$visibleCount profiles compared'
      : '$visibleCount of $totalCount compared';
}
