import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_import_models.dart';
import 'employee_directory_import_tiles.dart';

class EmployeeDirectoryImportPanel extends StatefulWidget {
  final String csvInput;
  final EmployeeDirectoryImportPreview preview;
  final ValueChanged<String> onCsvChanged;
  final VoidCallback onLoadTemplate;
  final VoidCallback onClear;
  final VoidCallback onImportValid;

  const EmployeeDirectoryImportPanel({
    super.key,
    required this.csvInput,
    required this.preview,
    required this.onCsvChanged,
    required this.onLoadTemplate,
    required this.onClear,
    required this.onImportValid,
  });

  @override
  State<EmployeeDirectoryImportPanel> createState() =>
      _EmployeeDirectoryImportPanelState();
}

class _EmployeeDirectoryImportPanelState
    extends State<EmployeeDirectoryImportPanel> {
  late final TextEditingController _csvController;

  @override
  void initState() {
    super.initState();
    _csvController = TextEditingController(text: widget.csvInput);
  }

  @override
  void didUpdateWidget(EmployeeDirectoryImportPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.csvInput != widget.csvInput &&
        _csvController.text != widget.csvInput) {
      _csvController.text = widget.csvInput;
    }
  }

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewRows = widget.preview.rows.take(4).toList();

    return HrisSectionPanel(
      key: const ValueKey('employee-directory-import-panel'),
      icon: Icons.upload_file_outlined,
      title: 'CSV import preview',
      subtitle:
          '${widget.preview.validCount} ready, ${widget.preview.errorCount} need review',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Rows',
              value: '${widget.preview.totalRows}',
            ),
            HrisMetricStripItem(
              label: 'Ready',
              value: '${widget.preview.validCount}',
            ),
            HrisMetricStripItem(
              label: 'Errors',
              value: '${widget.preview.errorCount}',
            ),
            HrisMetricStripItem(
              label: 'Duplicates',
              value: '${widget.preview.duplicateEmailCount}',
            ),
          ],
        ),
        TextField(
          key: const ValueKey('employee-directory-import-csv-field'),
          controller: _csvController,
          minLines: 4,
          maxLines: 7,
          onChanged: widget.onCsvChanged,
          decoration: const InputDecoration(
            labelText: 'Paste employee CSV',
            hintText:
                'name,email,phone,position,department,manager,location,joining_date,performance,status',
            prefixIcon: Icon(Icons.table_chart_outlined),
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              key: const ValueKey('employee-directory-import-template-button'),
              onPressed: widget.onLoadTemplate,
              icon: const Icon(Icons.content_paste_go_outlined),
              label: const Text('Use template'),
            ),
            OutlinedButton.icon(
              key: const ValueKey('employee-directory-import-clear-button'),
              onPressed: widget.csvInput.trim().isEmpty ? null : widget.onClear,
              icon: const Icon(Icons.clear_outlined),
              label: const Text('Clear'),
            ),
            FilledButton.icon(
              key: const ValueKey('employee-directory-import-submit-button'),
              onPressed: widget.preview.canImport ? widget.onImportValid : null,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: Text('Import ${widget.preview.validCount} valid'),
            ),
          ],
        ),
        if (widget.preview.rawCsv.trim().isEmpty)
          const HrisListSurface(
            child: Text(
              'Paste CSV rows or load the template to preview hires.',
            ),
          )
        else if (widget.preview.headerErrors.isNotEmpty)
          HrisListSurface(child: Text(widget.preview.headerErrors.join(' | ')))
        else if (previewRows.isEmpty)
          const HrisEmptyState(message: 'No employee rows found in CSV')
        else
          ...previewRows.map(
            (row) => EmployeeDirectoryImportRowTile(
              key: ValueKey('employee-directory-import-row-${row.rowNumber}'),
              row: row,
            ),
          ),
      ],
    );
  }
}
