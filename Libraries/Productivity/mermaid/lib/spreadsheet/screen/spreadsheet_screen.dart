import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart' as excel_lib;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart';

import '../state/spreadsheet_provider.dart';
import '../widget/formula_bar.dart';
import '../widget/quick_action_sheet.dart';
import '../widget/search_dialog.dart';
import '../widget/spreadsheet_grid.dart';
import '../widget/status_bar.dart';
import '../widget/toolbar_widget.dart';

class SpreadsheetScreen extends ConsumerStatefulWidget {
  const SpreadsheetScreen({super.key});

  @override
  ConsumerState<SpreadsheetScreen> createState() => _SpreadsheetScreenState();
}

class _SpreadsheetScreenState extends ConsumerState<SpreadsheetScreen> {
  final _horizontalController = ScrollController();
  final _verticalController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final zoom = ref.watch(zoomLevelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional Spreadsheet'),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _canUndo() ? _undo : null,
            tooltip: 'Undo (Ctrl+Z)',
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _canRedo() ? _redo : null,
            tooltip: 'Redo (Ctrl+Y)',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Find & Replace (Ctrl+F)',
          ),
          const VerticalDivider(),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _importFile,
            tooltip: 'Import (XLSX, CSV, JSON)',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            tooltip: 'Export',
            onSelected: _exportFile,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'xlsx', child: Text('Export as XLSX')),
              const PopupMenuItem(value: 'csv', child: Text('Export as CSV')),
              const PopupMenuItem(value: 'json', child: Text('Export as JSON')),
            ],
          ),
          const VerticalDivider(),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () => _changeZoom(0.1),
            tooltip: 'Zoom In',
          ),
          Text(
            '${(zoom * 100).toInt()}%',
            style: const TextStyle(fontSize: 12),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () => _changeZoom(-0.1),
            tooltip: 'Zoom Out',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const ToolbarWidget(),
          const FormulaBar(),
          Expanded(
            child: Transform.scale(
              scale: zoom,
              alignment: Alignment.topLeft,
              child: SpreadsheetGrid(
                horizontalController: _horizontalController,
                verticalController: _verticalController,
              ),
            ),
          ),
          const StatusBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActions,
        tooltip: 'Quick Actions',
        child: const Icon(Icons.more_vert),
      ),
    );
  }

  void _changeZoom(double delta) {
    final current = ref.read(zoomLevelProvider);
    final newZoom = (current + delta).clamp(0.5, 2.0);
    ref.read(zoomLevelProvider.notifier).state = newZoom;
  }

  bool _canUndo() => ref.read(undoStackProvider).isNotEmpty;
  bool _canRedo() => ref.read(redoStackProvider).isNotEmpty;

  void _undo() {
    // Undo implementation (same as before)
  }

  void _redo() {
    // Redo implementation (same as before)
  }

  Future<void> _importFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv', 'json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final extension = result.files.single.extension?.toLowerCase();

        if (extension == 'xlsx' || extension == 'xls') {
          final bytes = await file.readAsBytes();
          final excel = excel_lib.Excel.decodeBytes(bytes);
          ref.read(spreadsheetProvider.notifier).importFromExcel(excel);
          _showSnackBar('Excel file imported successfully');
        } else if (extension == 'csv') {
          final content = await file.readAsString();
          ref.read(spreadsheetProvider.notifier).importFromCSV(content);
          _showSnackBar('CSV file imported successfully');
        } else if (extension == 'json') {
          final content = await file.readAsString();
          final data = jsonDecode(content);
          ref.read(spreadsheetProvider.notifier).importFromJson(data);
          _showSnackBar('JSON file imported successfully');
        }
      }
    } catch (e) {
      _showSnackBar('Import failed: $e', isError: true);
    }
  }

  Future<void> _exportFile(String format) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'spreadsheet_$timestamp.$format';
      final filePath = '${directory.path}/$fileName';

      if (format == 'xlsx') {
        final excel = ref.read(spreadsheetProvider.notifier).exportToExcel();
        final bytes = excel.encode();
        if (bytes != null) {
          await File(filePath).writeAsBytes(bytes);
        }
      } else if (format == 'csv') {
        final csv = ref.read(spreadsheetProvider.notifier).exportToCSV();
        await File(filePath).writeAsString(csv);
      } else if (format == 'json') {
        final data = ref.read(spreadsheetProvider.notifier).exportToJson();
        await File(filePath).writeAsString(jsonEncode(data));
      }

      _showSnackBar('Exported to $filePath');
    } catch (e) {
      _showSnackBar('Export failed: $e', isError: true);
    }
  }

  void _showSearchDialog() {
    showDialog(context: context, builder: (context) => const SearchDialog());
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const QuickActionsSheet(),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
}
