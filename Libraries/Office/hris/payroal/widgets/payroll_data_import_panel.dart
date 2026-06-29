import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollDataImportPanel extends StatefulWidget {
  final PayrollDataImportDraft draft;
  final PayrollDataImportPreview preview;
  final List<PayrollDataImportBatch> batches;
  final ValueChanged<PayrollDataImportType> onTypeChanged;
  final ValueChanged<String> onSourceLabelChanged;
  final ValueChanged<String> onCsvTextChanged;
  final VoidCallback onLoadSample;
  final VoidCallback onApplyPreview;
  final VoidCallback onClear;
  final ValueChanged<String> onRemoveBatch;

  const PayrollDataImportPanel({
    super.key,
    required this.draft,
    required this.preview,
    required this.batches,
    required this.onTypeChanged,
    required this.onSourceLabelChanged,
    required this.onCsvTextChanged,
    required this.onLoadSample,
    required this.onApplyPreview,
    required this.onClear,
    required this.onRemoveBatch,
  });

  @override
  State<PayrollDataImportPanel> createState() => _PayrollDataImportPanelState();
}

class _PayrollDataImportPanelState extends State<PayrollDataImportPanel> {
  late final TextEditingController _sourceController;
  late final TextEditingController _csvController;

  @override
  void initState() {
    super.initState();
    _sourceController = TextEditingController(text: widget.draft.sourceLabel);
    _csvController = TextEditingController(text: widget.draft.csvText);
  }

  @override
  void didUpdateWidget(covariant PayrollDataImportPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_sourceController, widget.draft.sourceLabel);
    _sync(_csvController, widget.draft.csvText);
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _csvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor =
        widget.preview.errorCount > 0
            ? const Color(0xFFB91C1C)
            : widget.preview.canImport
            ? const Color(0xFF15803D)
            : const Color(0xFF2563EB);

    return HrisSectionPanel(
      icon: Icons.upload_file_outlined,
      title: 'Payroll data import',
      subtitle: 'Validate imported payroll rows before approval workflow',
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final typeField =
                      DropdownButtonFormField<PayrollDataImportType>(
                        initialValue: widget.draft.type,
                        decoration: const InputDecoration(
                          labelText: 'Import type',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items:
                            PayrollDataImportType.values
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type.label),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) widget.onTypeChanged(value);
                        },
                      );
                  final sourceField = TextField(
                    controller: _sourceController,
                    decoration: const InputDecoration(
                      labelText: 'Source label',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.source_outlined),
                    ),
                    onChanged: widget.onSourceLabelChanged,
                  );

                  if (constraints.maxWidth < 760) {
                    return Column(
                      children: [
                        typeField,
                        const SizedBox(height: 12),
                        sourceField,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: typeField),
                      const SizedBox(width: 12),
                      Expanded(child: sourceField),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _csvController,
                minLines: 5,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'CSV payload',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.table_rows_outlined),
                ),
                onChanged: widget.onCsvTextChanged,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  HrisStatusPill(
                    label:
                        widget.preview.errorCount > 0
                            ? 'Needs fixes'
                            : widget.preview.canImport
                            ? 'Ready'
                            : 'Draft',
                    color: statusColor,
                  ),
                  _MetaChip(
                    icon: Icons.task_alt_outlined,
                    label: '${widget.preview.validCount} valid',
                  ),
                  _MetaChip(
                    icon: Icons.warning_amber_outlined,
                    label: '${widget.preview.errorCount} errors',
                  ),
                  _MetaChip(
                    icon: Icons.payments_outlined,
                    label: payrollCurrencyFormat.format(
                      widget.preview.totalAmount,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.flag_circle_outlined, color: statusColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.preview.nextAction,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: widget.onLoadSample,
                    icon: const Icon(Icons.auto_fix_high_outlined),
                    label: const Text('Sample'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: widget.onClear,
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed:
                        widget.preview.canImport ? widget.onApplyPreview : null,
                    icon: const Icon(Icons.playlist_add_check_outlined),
                    label: const Text('Import rows'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.preview.lines.isEmpty)
          const HrisEmptyState(message: 'No import rows to preview')
        else
          for (final line in widget.preview.lines.take(6))
            _ImportPreviewLineTile(line: line),
        if (widget.batches.isNotEmpty)
          _ImportBatchHistory(
            batches: widget.batches,
            onRemoveBatch: widget.onRemoveBatch,
          ),
      ],
    );
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}

class _ImportPreviewLineTile extends StatelessWidget {
  final PayrollDataImportLine line;

  const _ImportPreviewLineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final color =
        line.isValid ? const Color(0xFF15803D) : const Color(0xFFB91C1C);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              line.isValid ? Icons.task_alt_outlined : Icons.error_outline,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Row ${line.rowNumber} - ${line.employeeName}',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(
                      label: line.isValid ? 'Valid' : 'Error',
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetaChip(
                      icon: Icons.payments_outlined,
                      label: payrollCurrencyFormat.format(line.requestedAmount),
                    ),
                    _MetaChip(
                      icon: Icons.event_outlined,
                      label:
                          line.effectiveDate == null
                              ? 'Invalid date'
                              : '${line.effectiveDate!.month}/${line.effectiveDate!.day}/${line.effectiveDate!.year}',
                    ),
                    _MetaChip(
                      icon: Icons.notes_outlined,
                      label: line.reason.isEmpty ? 'No reason' : line.reason,
                    ),
                  ],
                ),
                if (line.errors.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    line.errors.join(' • '),
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

class _ImportBatchHistory extends StatelessWidget {
  final List<PayrollDataImportBatch> batches;
  final ValueChanged<String> onRemoveBatch;

  const _ImportBatchHistory({
    required this.batches,
    required this.onRemoveBatch,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Applied batches',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          for (final batch in batches) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _MetaChip(icon: Icons.tag_outlined, label: batch.id),
                      _MetaChip(
                        icon: Icons.category_outlined,
                        label: batch.type.label,
                      ),
                      _MetaChip(
                        icon: Icons.task_alt_outlined,
                        label: '${batch.validCount} rows',
                      ),
                      _MetaChip(
                        icon: Icons.payments_outlined,
                        label: payrollCurrencyFormat.format(batch.totalAmount),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remove batch',
                  onPressed: () => onRemoveBatch(batch.id),
                  icon: const Icon(Icons.close_outlined),
                ),
              ],
            ),
            if (batch != batches.last) const Divider(height: 18),
          ],
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: HrisColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
