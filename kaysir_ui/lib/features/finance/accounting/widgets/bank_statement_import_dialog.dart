import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';

import '../models/bank_reconciliation.dart';
import '../services/bank_statement_import_service.dart';
import 'bank_statement_dialog_components.dart';

class BankStatementImportDialog extends StatefulWidget {
  final BankStatementImportService service;
  final List<BankStatementLine> existingLines;

  const BankStatementImportDialog({
    super.key,
    required this.service,
    this.existingLines = const [],
  });

  @override
  State<BankStatementImportDialog> createState() =>
      _BankStatementImportDialogState();
}

class _BankStatementImportDialogState extends State<BankStatementImportDialog> {
  final _csvController = TextEditingController();
  late BankStatementImportResult _result;

  @override
  void initState() {
    super.initState();
    _result = widget.service.parseCsv('', existingLines: widget.existingLines);
    _csvController.addListener(_parse);
  }

  @override
  void dispose() {
    _csvController
      ..removeListener(_parse)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewLines = _result.lines.take(5).toList();
    final reviewIssues = _result.issues.take(4).toList();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BankStatementDialogHeader(
                title: 'Import Bank Statement CSV',
                subtitle: 'Paste statement rows and review import readiness',
                icon: Icons.upload_file_outlined,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _csvController,
                        decoration: bankStatementInputDecoration(
                          context,
                          label: 'CSV Data',
                          hintText:
                              'date,description,reference,amount\n2026-01-05,Customer transfer,BNK-001,1200',
                          icon: Icons.dataset_outlined,
                          alignLabelWithHint: true,
                        ),
                        minLines: 7,
                        maxLines: 10,
                      ),
                      const SizedBox(height: 12),
                      BankStatementImportSummary(result: _result),
                      if (previewLines.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        BankStatementImportPreview(lines: previewLines),
                      ],
                      if (reviewIssues.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        BankStatementImportIssues(issues: reviewIssues),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppDialogActions(
                cancelLabel: 'Cancel',
                onCancel: () => Navigator.of(context).pop(),
                confirmLabel:
                    _result.lines.isEmpty
                        ? 'Import'
                        : 'Import ${_result.lines.length}',
                confirmIcon: Icons.upload_file_rounded,
                onConfirm: _result.lines.isEmpty ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _parse() {
    setState(() {
      _result = widget.service.parseCsv(
        _csvController.text,
        importId: 'csv-${DateTime.now().microsecondsSinceEpoch}',
        existingLines: widget.existingLines,
      );
    });
  }

  void _submit() {
    Navigator.of(context).pop(_result.lines);
  }
}
