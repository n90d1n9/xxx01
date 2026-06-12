import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../widgets/ui/app_dialog_actions.dart';
import '../../../../widgets/ui/app_surface.dart';
import '../models/financial_report_management_measure.dart';

class FinancialReportManagementMeasureDialog extends StatefulWidget {
  const FinancialReportManagementMeasureDialog({
    super.key,
    this.initialMeasure,
  });

  final FinancialReportManagementMeasure? initialMeasure;

  @override
  State<FinancialReportManagementMeasureDialog> createState() =>
      _FinancialReportManagementMeasureDialogState();
}

class _FinancialReportManagementMeasureDialogState
    extends State<FinancialReportManagementMeasureDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _ownerController;
  late final TextEditingController _closestSubtotalController;
  late final TextEditingController _closestSubtotalShortController;
  late final TextEditingController _amountOverrideController;
  late final TextEditingController _comparativeAmountOverrideController;
  late final TextEditingController _adjustmentLabelController;
  late final TextEditingController _adjustmentSourceController;
  late final TextEditingController _adjustmentAmountController;
  late final TextEditingController _comparativeAdjustmentAmountController;

  @override
  void initState() {
    super.initState();
    final measure = widget.initialMeasure;
    final adjustment =
        measure?.adjustments.isEmpty ?? true
            ? null
            : measure!.adjustments.first;

    _labelController = TextEditingController(
      text: measure?.label ?? 'adjusted operating performance',
    );
    _ownerController = TextEditingController(
      text: measure?.owner ?? 'Financial reporting lead',
    );
    _closestSubtotalController = TextEditingController(
      text:
          measure?.closestSubtotalLabel ??
          'Profit (loss) before financing and income tax',
    );
    _closestSubtotalShortController = TextEditingController(
      text: measure?.closestSubtotalShortLabel ?? 'Before financing and tax',
    );
    _amountOverrideController = TextEditingController(
      text: _amountText(measure?.amountOverride),
    );
    _comparativeAmountOverrideController = TextEditingController(
      text: _amountText(measure?.comparativeAmountOverride),
    );
    _adjustmentLabelController = TextEditingController(
      text: adjustment?.label ?? '',
    );
    _adjustmentSourceController = TextEditingController(
      text: adjustment?.sourceReference ?? '',
    );
    _adjustmentAmountController = TextEditingController(
      text: _amountText(adjustment?.amount),
    );
    _comparativeAdjustmentAmountController = TextEditingController(
      text: _amountText(adjustment?.comparativeAmount),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _ownerController.dispose();
    _closestSubtotalController.dispose();
    _closestSubtotalShortController.dispose();
    _amountOverrideController.dispose();
    _comparativeAmountOverrideController.dispose();
    _adjustmentLabelController.dispose();
    _adjustmentSourceController.dispose();
    _adjustmentAmountController.dispose();
    _comparativeAdjustmentAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.initialMeasure != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit UKTM Measure' : 'Add UKTM Measure'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Measure',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                _FieldWrap(
                  children: [
                    _textField(
                      controller: _labelController,
                      label: 'Measure label',
                      icon: Icons.speed_rounded,
                      validator: _required,
                    ),
                    _textField(
                      controller: _ownerController,
                      label: 'Owner',
                      icon: Icons.person_outline_rounded,
                      validator: _required,
                    ),
                    _textField(
                      controller: _amountOverrideController,
                      label: 'Measure amount override',
                      icon: Icons.calculate_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_amountInputFormatter],
                      validator: _optionalAmount,
                    ),
                    _textField(
                      controller: _comparativeAmountOverrideController,
                      label: 'Comparative override',
                      icon: Icons.history_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_amountInputFormatter],
                      validator: _optionalAmount,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Closest SAK Subtotal',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                _FieldWrap(
                  children: [
                    _textField(
                      controller: _closestSubtotalController,
                      label: 'Closest SAK subtotal',
                      icon: Icons.summarize_outlined,
                      validator: _required,
                    ),
                    _textField(
                      controller: _closestSubtotalShortController,
                      label: 'Subtotal short label',
                      icon: Icons.short_text_rounded,
                      validator: _required,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                AppSurface(
                  padding: const EdgeInsets.all(12),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  borderColor: colorScheme.outlineVariant,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Primary Adjustment',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _FieldWrap(
                        children: [
                          _textField(
                            controller: _adjustmentLabelController,
                            label: 'Adjustment label',
                            icon: Icons.edit_note_outlined,
                            validator: _adjustmentLabel,
                          ),
                          _textField(
                            controller: _adjustmentSourceController,
                            label: 'Source reference',
                            icon: Icons.source_outlined,
                            validator: _adjustmentSource,
                          ),
                          _textField(
                            controller: _adjustmentAmountController,
                            label: 'Adjustment amount',
                            icon: Icons.add_card_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_amountInputFormatter],
                            validator: _adjustmentAmount,
                          ),
                          _textField(
                            controller: _comparativeAdjustmentAmountController,
                            label: 'Comparative adjustment',
                            icon: Icons.history_toggle_off_rounded,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_amountInputFormatter],
                            validator: _optionalAmount,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        AppDialogActions(
          cancelLabel: 'Cancel',
          confirmLabel: isEditing ? 'Save Measure' : 'Add Measure',
          cancelIcon: Icons.close_rounded,
          confirmIcon: Icons.save_outlined,
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: _submit,
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final adjustment = _buildAdjustment();
    final initial = widget.initialMeasure;
    Navigator.of(context).pop(
      FinancialReportManagementMeasure(
        id: initial?.id ?? _measureId(_labelController.text),
        label: _labelController.text.trim(),
        closestSubtotalLabel: _closestSubtotalController.text.trim(),
        closestSubtotalShortLabel: _closestSubtotalShortController.text.trim(),
        amountOverride: _parseOptionalAmount(_amountOverrideController.text),
        comparativeAmountOverride: _parseOptionalAmount(
          _comparativeAmountOverrideController.text,
        ),
        adjustments: adjustment == null ? const [] : [adjustment],
        owner: _ownerController.text.trim(),
        approvalStatus: FinancialReportManagementMeasureApprovalStatus.draft,
        reviewNote:
            initial == null
                ? 'New management measure captured for review.'
                : 'Updated - submit for review before release.',
      ),
    );
  }

  FinancialReportManagementMeasureAdjustment? _buildAdjustment() {
    if (!_hasAdjustmentInput) {
      return null;
    }

    return FinancialReportManagementMeasureAdjustment(
      label: _adjustmentLabelController.text.trim(),
      amount: _parseOptionalAmount(_adjustmentAmountController.text)!,
      comparativeAmount: _parseOptionalAmount(
        _comparativeAdjustmentAmountController.text,
      ),
      sourceReference: _adjustmentSourceController.text.trim(),
    );
  }

  bool get _hasAdjustmentInput {
    return _adjustmentLabelController.text.trim().isNotEmpty ||
        _adjustmentSourceController.text.trim().isNotEmpty ||
        _adjustmentAmountController.text.trim().isNotEmpty ||
        _comparativeAdjustmentAmountController.text.trim().isNotEmpty;
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _optionalAmount(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    return _parseOptionalAmount(text) == null ? 'Use a valid amount' : null;
  }

  String? _adjustmentLabel(String? value) {
    if (!_hasAdjustmentInput) {
      return null;
    }
    return _required(value);
  }

  String? _adjustmentSource(String? value) {
    if (!_hasAdjustmentInput) {
      return null;
    }
    return _required(value);
  }

  String? _adjustmentAmount(String? value) {
    if (!_hasAdjustmentInput) {
      return null;
    }
    return _optionalAmount(value) ?? _required(value);
  }
}

class _FieldWrap extends StatelessWidget {
  const _FieldWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 12, runSpacing: 12, children: children);
  }
}

final _amountInputFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'[-0-9., ]'),
);

String _amountText(double? value) {
  if (value == null) {
    return '';
  }
  final rounded = value.round();
  if ((value - rounded).abs() < 0.01) {
    return rounded.toString();
  }
  return value.toStringAsFixed(2);
}

double? _parseOptionalAmount(String value) {
  final text = value.trim().replaceAll(',', '').replaceAll(' ', '');
  if (text.isEmpty) {
    return null;
  }
  return double.tryParse(text);
}

String _measureId(String label) {
  final slug = label
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return 'uktm-${slug.isEmpty ? 'measure' : slug}';
}
