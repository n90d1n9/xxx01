import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../scrum_board_palette.dart';

/// Selection count and clear action for the bulk task toolbar.
class BulkSelectionSummary extends StatelessWidget {
  const BulkSelectionSummary({
    super.key,
    required this.selectedCount,
    required this.onClearSelection,
  });

  final int selectedCount;
  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Clear selection',
          visualDensity: VisualDensity.compact,
          onPressed: onClearSelection,
          icon: const Icon(Icons.close_rounded, size: 18),
        ),
        Text(
          '$selectedCount selected',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: ScrumBoardPalette.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

/// Preview for the bulk selection summary.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Bulk selection summary',
  size: Size(240, 90),
)
Widget bulkSelectionSummaryPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: BulkSelectionSummary(selectedCount: 4, onClearSelection: () {}),
      ),
    ),
  );
}
