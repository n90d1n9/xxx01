import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/cell/cell_selection.dart';
import '../state/spreadsheet_provider.dart';
import '../state/toolbar_provider.dart';
import 'color_button.dart';
import 'tool_button.dart';

class ToolbarWidget extends ConsumerWidget {
  const ToolbarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(selectedCellProvider);
    final hasSelection = selection != null;
    final controller = ref.watch(toolbarControllerProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Formatting buttons
            _buildFormattingButtons(controller, selection, hasSelection),

            // Alignment buttons
            _buildAlignmentButtons(controller, selection, hasSelection),

            // Clipboard buttons
            _buildClipboardButtons(controller, selection, hasSelection, ref),

            // Row/Column operations
            _buildRowColumnTools(
              controller,
              selection,
              hasSelection,
              context,
              ref,
            ),

            // Advanced tools
            _buildAdvancedTools(
              controller,
              selection,
              hasSelection,
              context,
              ref,
            ),

            // Data tools
            _buildDataTools(controller, selection, hasSelection, context, ref),

            // Color buttons
            _buildColorButtons(controller, selection, hasSelection),

            // Text color buttons
            _buildTextColorButtons(controller, selection, hasSelection),

            // Zoom controls
            _buildZoomControls(controller, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattingButtons(
    ToolbarController controller,
    CellSelection? selection,
    bool hasSelection,
  ) {
    return Row(
      children: [
        ToolButton(
          icon: Icons.format_bold,
          onPressed: hasSelection
              ? () => controller.toggleBold(selection!)
              : null,
          tooltip: 'Bold (Ctrl+B)',
        ),
        ToolButton(
          icon: Icons.format_italic,
          onPressed: hasSelection
              ? () => controller.toggleItalic(selection!)
              : null,
          tooltip: 'Italic (Ctrl+I)',
        ),
        ToolButton(
          icon: Icons.format_underline,
          onPressed: hasSelection
              ? () => controller.toggleUnderline(selection!)
              : null,
          tooltip: 'Underline (Ctrl+U)',
        ),
        ToolButton(
          icon: Icons.format_clear,
          onPressed: hasSelection
              ? () => controller.clearFormatting(selection!)
              : null,
          tooltip: 'Clear Formatting',
        ),
        const SizedBox(width: 4, child: VerticalDivider()),
      ],
    );
  }

  Widget _buildAlignmentButtons(
    ToolbarController controller,
    CellSelection? selection,
    bool hasSelection,
  ) {
    return Row(
      children: [
        ToolButton(
          icon: Icons.format_align_left,
          onPressed: hasSelection
              ? () => controller.setAlign(selection!, TextAlign.left)
              : null,
          tooltip: 'Align Left',
        ),
        ToolButton(
          icon: Icons.format_align_center,
          onPressed: hasSelection
              ? () => controller.setAlign(selection!, TextAlign.center)
              : null,
          tooltip: 'Align Center',
        ),
        ToolButton(
          icon: Icons.format_align_right,
          onPressed: hasSelection
              ? () => controller.setAlign(selection!, TextAlign.right)
              : null,
          tooltip: 'Align Right',
        ),
        const SizedBox(width: 4, child: VerticalDivider()),
      ],
    );
  }

  Widget _buildClipboardButtons(
    ToolbarController controller,
    CellSelection? selection,
    bool hasSelection,
    WidgetRef ref,
  ) {
    return Row(
      children: [
        ToolButton(
          icon: Icons.content_copy,
          onPressed: hasSelection ? () => controller.copy(selection!) : null,
          tooltip: 'Copy (Ctrl+C)',
        ),
        ToolButton(
          icon: Icons.content_cut,
          onPressed: hasSelection ? () => controller.cut(selection!) : null,
          tooltip: 'Cut (Ctrl+X)',
        ),
        ToolButton(
          icon: Icons.content_paste,
          onPressed: hasSelection && ref.watch(clipboardProvider) != null
              ? () => controller.paste(selection!)
              : null,
          tooltip: 'Paste (Ctrl+V)',
        ),
        const SizedBox(width: 4, child: VerticalDivider()),
      ],
    );
  }

  Widget _buildRowColumnTools(
    ToolbarController controller,
    CellSelection? selection,
    bool hasSelection,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Row(
      children: [
        // Insert rows
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Insert Row Above'),
              onTap: hasSelection
                  ? () => controller.insertRowsAbove(selection!)
                  : null,
            ),
            PopupMenuItem(
              child: const Text('Insert Row Below'),
              onTap: hasSelection
                  ? () => controller.insertRowsBelow(selection!)
                  : null,
            ),
          ],
          child: ToolButton(
            icon: Icons.add_box,
            onPressed: hasSelection ? () {} : null,
            tooltip: 'Insert Rows',
          ),
        ),

        // Insert columns
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Insert Column Left'),
              onTap: hasSelection
                  ? () => controller.insertColumnsLeft(selection!)
                  : null,
            ),
            PopupMenuItem(
              child: const Text('Insert Column Right'),
              onTap: hasSelection
                  ? () => controller.insertColumnsRight(selection!)
                  : null,
            ),
          ],
          child: ToolButton(
            icon: Icons.view_column,
            onPressed: hasSelection ? () {} : null,
            tooltip: 'Insert Columns',
          ),
        ),

        // Delete rows/columns
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Delete Rows'),
              onTap: hasSelection
                  ? () => controller.deleteRows(selection!)
                  : null,
            ),
            PopupMenuItem(
              child: const Text('Delete Columns'),
              onTap: hasSelection
                  ? () => controller.deleteColumns(selection!)
                  : null,
            ),
          ],
          child: ToolButton(
            icon: Icons.delete,
            onPressed: hasSelection ? () {} : null,
            tooltip: 'Delete Rows/Columns',
          ),
        ),

        // Hide/Show
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Hide Rows'),
              onTap: hasSelection
                  ? () => controller.hideRows(selection!)
                  : null,
            ),
            PopupMenuItem(
              child: const Text('Hide Columns'),
              onTap: hasSelection
                  ? () => controller.hideColumns(selection!)
                  : null,
            ),
            PopupMenuItem(
              child: const Text('Show Rows'),
              onTap: hasSelection
                  ? () => controller.showRows(selection!)
                  : null,
            ),
            PopupMenuItem(
              child: const Text('Show Columns'),
              onTap: hasSelection
                  ? () => controller.showColumns(selection!)
                  : null,
            ),
          ],
          child: ToolButton(
            icon: Icons.visibility_off,
            onPressed: hasSelection ? () {} : null,
            tooltip: 'Hide/Show Rows/Columns',
          ),
        ),

        // Auto-fit
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Auto-fit Row Height'),
              onTap: hasSelection
                  ? () => controller.autoFitRow(selection!)
                  : null,
            ),
            PopupMenuItem(
              child: const Text('Auto-fit Column Width'),
              onTap: hasSelection
                  ? () => controller.autoFitColumn(selection!)
                  : null,
            ),
          ],
          child: ToolButton(
            icon: Icons.fit_screen,
            onPressed: hasSelection ? () {} : null,
            tooltip: 'Auto-fit Rows/Columns',
          ),
        ),

        const SizedBox(width: 4, child: VerticalDivider()),
      ],
    );
  }

  Widget _buildAdvancedTools(
    ToolbarController controller,
    CellSelection? selection,
    bool hasSelection,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Row(
      children: [
        ToolButton(
          icon: Icons.functions,
          onPressed: hasSelection
              ? () => _showFunctionMenu(context, ref, selection!, controller)
              : null,
          tooltip: 'Insert Function',
        ),
        ToolButton(
          icon: Icons.merge_type,
          onPressed: hasSelection
              ? () => controller.mergeCells(selection!)
              : null,
          tooltip: 'Merge Cells',
        ),
        ToolButton(
          icon: Icons.wrap_text,
          onPressed: hasSelection
              ? () => controller.toggleWrapText(selection!)
              : null,
          tooltip: 'Wrap Text',
        ),
        ToolButton(
          icon: Icons.filter_alt,
          onPressed: hasSelection
              ? () => _showFilterMenu(context, selection!, controller)
              : null,
          tooltip: 'Filters',
        ),
        ToolButton(
          icon: Icons.sort,
          onPressed: hasSelection
              ? () => _showSortMenu(context, selection!, controller)
              : null,
          tooltip: 'Sort',
        ),
        ToolButton(
          icon: Icons.icecream,
          onPressed: hasSelection
              ? () => _showFreezeMenu(context, selection!, controller)
              : null,
          tooltip: 'Freeze Panes',
        ),
        const SizedBox(width: 4, child: VerticalDivider()),
      ],
    );
  }

  Widget _buildDataTools(
    ToolbarController controller,
    CellSelection? selection,
    bool hasSelection,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Row(
      children: [
        ToolButton(
          icon: Icons.search,
          onPressed: () => _showSearchDialog(context, controller),
          tooltip: 'Search',
        ),
        ToolButton(
          icon: Icons.find_replace,
          onPressed: () => _showReplaceDialog(context, controller),
          tooltip: 'Find and Replace',
        ),
        ToolButton(
          icon: Icons.rule,
          onPressed: hasSelection
              ? () => _showValidationMenu(context, selection!, controller)
              : null,
          tooltip: 'Data Validation',
        ),
        const SizedBox(width: 4, child: VerticalDivider()),
      ],
    );
  }

  Widget _buildColorButtons(
    ToolbarController controller,
    CellSelection? selection,
    bool hasSelection,
  ) {
    return Row(
      children: [
        const Text('Fill: ', style: TextStyle(fontSize: 12)),
        ColorButton(
          color: Colors.yellow[100]!,
          onPressed: hasSelection
              ? () => controller.setBackground(selection!, Colors.yellow[100]!)
              : null,
        ),
        ColorButton(
          color: Colors.green[100]!,
          onPressed: hasSelection
              ? () => controller.setBackground(selection!, Colors.green[100]!)
              : null,
        ),
        ColorButton(
          color: Colors.blue[100]!,
          onPressed: hasSelection
              ? () => controller.setBackground(selection!, Colors.blue[100]!)
              : null,
        ),
        ColorButton(
          color: Colors.red[100]!,
          onPressed: hasSelection
              ? () => controller.setBackground(selection!, Colors.red[100]!)
              : null,
        ),
        ColorButton(
          color: Colors.white,
          onPressed: hasSelection
              ? () => controller.setBackground(selection!, Colors.white)
              : null,
        ),
        const SizedBox(width: 4, child: VerticalDivider()),
      ],
    );
  }

  Widget _buildTextColorButtons(
    ToolbarController controller,
    CellSelection? selection,
    bool hasSelection,
  ) {
    return Row(
      children: [
        const Text('Text: ', style: TextStyle(fontSize: 12)),
        ColorButton(
          color: Colors.black,
          onPressed: hasSelection
              ? () => controller.setTextColor(selection!, Colors.black)
              : null,
        ),
        ColorButton(
          color: Colors.red,
          onPressed: hasSelection
              ? () => controller.setTextColor(selection!, Colors.red)
              : null,
        ),
        ColorButton(
          color: Colors.blue,
          onPressed: hasSelection
              ? () => controller.setTextColor(selection!, Colors.blue)
              : null,
        ),
        ColorButton(
          color: Colors.green,
          onPressed: hasSelection
              ? () => controller.setTextColor(selection!, Colors.green)
              : null,
        ),
        const SizedBox(width: 4, child: VerticalDivider()),
      ],
    );
  }

  Widget _buildZoomControls(ToolbarController controller, WidgetRef ref) {
    final zoomLevel = ref.watch(zoomLevelProvider);

    return Row(
      children: [
        ToolButton(
          icon: Icons.zoom_out,
          onPressed: () => controller.zoomOut(),
          tooltip: 'Zoom Out',
        ),
        SizedBox(
          width: 60,
          child: Text(
            '${(zoomLevel * 100).round()}%',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        ToolButton(
          icon: Icons.zoom_in,
          onPressed: () => controller.zoomIn(),
          tooltip: 'Zoom In',
        ),
        ToolButton(
          icon: Icons.fullscreen,
          onPressed: () => controller.resetZoom(),
          tooltip: 'Reset Zoom',
        ),
      ],
    );
  }

  // Menu dialog methods
  void _showFunctionMenu(
    BuildContext context,
    WidgetRef ref,
    CellSelection selection,
    ToolbarController controller,
  ) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 100, 100),
      items: _buildFunctionMenuItems(),
    ).then((value) {
      if (value != null) {
        controller.insertFunction(selection.start, value);
      }
    });
  }

  void _showFilterMenu(
    BuildContext context,
    CellSelection selection,
    ToolbarController controller,
  ) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 100, 100),
      items: [
        PopupMenuItem(
          child: const Text('Apply Filter'),
          onTap: () => controller.applyFilter(selection),
        ),
        PopupMenuItem(
          child: const Text('Remove Filter'),
          onTap: () => controller.removeFilter(selection),
        ),
      ],
    );
  }

  void _showSortMenu(
    BuildContext context,
    CellSelection selection,
    ToolbarController controller,
  ) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 100, 100),
      items: [
        PopupMenuItem(
          child: const Text('Sort A → Z'),
          onTap: () => controller.sortSelection(selection, ascending: true),
        ),
        PopupMenuItem(
          child: const Text('Sort Z → A'),
          onTap: () => controller.sortSelection(selection, ascending: false),
        ),
      ],
    );
  }

  void _showFreezeMenu(
    BuildContext context,
    CellSelection selection,
    ToolbarController controller,
  ) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 100, 100),
      items: [
        PopupMenuItem(
          child: const Text('Freeze at Selection'),
          onTap: () => controller.freezePanesAt(selection),
        ),
        PopupMenuItem(
          child: const Text('Unfreeze Panes'),
          onTap: () => controller.unfreezePanes(),
        ),
      ],
    );
  }

  void _showValidationMenu(
    BuildContext context,
    CellSelection selection,
    ToolbarController controller,
  ) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 100, 100),
      items: [
        PopupMenuItem(
          child: const Text('Required Field'),
          onTap: () => controller.applyRequiredValidation(selection),
        ),
        PopupMenuItem(
          child: const Text('Number Range'),
          onTap: () =>
              _showNumberValidationDialog(context, selection, controller),
        ),
        PopupMenuItem(
          child: const Text('List of Values'),
          onTap: () =>
              _showListValidationDialog(context, selection, controller),
        ),
        PopupMenuItem(
          child: const Text('Email Address'),
          onTap: () => controller.applyEmailValidation(selection),
        ),
        PopupMenuItem(
          child: const Text('Clear Validation'),
          onTap: () => controller.clearValidation(selection),
        ),
      ],
    );
  }

  void _showSearchDialog(BuildContext context, ToolbarController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter search term'),
          onChanged: (value) => controller.search(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.nextSearchResult();
              Navigator.pop(context);
            },
            child: const Text('Find Next'),
          ),
        ],
      ),
    );
  }

  void _showReplaceDialog(BuildContext context, ToolbarController controller) {
    final findController = TextEditingController();
    final replaceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Find and Replace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: findController,
              decoration: const InputDecoration(labelText: 'Find'),
            ),
            TextField(
              controller: replaceController,
              decoration: const InputDecoration(labelText: 'Replace with'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.replaceAll(
                findController.text,
                replaceController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Replace All'),
          ),
        ],
      ),
    );
  }

  void _showNumberValidationDialog(
    BuildContext context,
    CellSelection selection,
    ToolbarController controller,
  ) {
    final minController = TextEditingController();
    final maxController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Number Validation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minController,
              decoration: const InputDecoration(labelText: 'Minimum value'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: maxController,
              decoration: const InputDecoration(labelText: 'Maximum value'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final min = double.tryParse(minController.text);
              final max = double.tryParse(maxController.text);
              controller.applyNumberValidation(selection, min: min, max: max);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showListValidationDialog(
    BuildContext context,
    CellSelection selection,
    ToolbarController controller,
  ) {
    final optionsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('List Validation'),
        content: TextField(
          controller: optionsController,
          decoration: const InputDecoration(
            labelText: 'Options (comma separated)',
            hintText: 'Yes,No,Maybe',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final options = optionsController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              if (options.isNotEmpty) {
                controller.applyListValidation(selection, options);
              }
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  List<PopupMenuItem<String>> _buildFunctionMenuItems() {
    return [
      const PopupMenuItem(value: 'SUM', child: Text('SUM - Sum range')),
      const PopupMenuItem(value: 'AVERAGE', child: Text('AVERAGE - Average')),
      const PopupMenuItem(value: 'COUNT', child: Text('COUNT - Count cells')),
      const PopupMenuItem(value: 'MIN', child: Text('MIN - Minimum')),
      const PopupMenuItem(value: 'MAX', child: Text('MAX - Maximum')),
      const PopupMenuItem(value: 'IF', child: Text('IF - Conditional')),
      const PopupMenuItem(
        value: 'SUMIF',
        child: Text('SUMIF - Conditional sum'),
      ),
      const PopupMenuItem(
        value: 'COUNTIF',
        child: Text('COUNTIF - Conditional count'),
      ),
      const PopupMenuItem(value: 'VLOOKUP', child: Text('VLOOKUP - Lookup')),
      const PopupMenuItem(value: 'CONCAT', child: Text('CONCAT - Concatenate')),
      const PopupMenuItem(value: 'UPPER', child: Text('UPPER - Uppercase')),
      const PopupMenuItem(value: 'LOWER', child: Text('LOWER - Lowercase')),
      const PopupMenuItem(value: 'LEN', child: Text('LEN - Length')),
    ];
  }
}
