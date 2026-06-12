import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';

import '../models/bank_reconciliation.dart';
import 'bank_statement_dialog_components.dart';

class BankStatementLineDialog extends StatefulWidget {
  const BankStatementLineDialog({super.key});

  @override
  State<BankStatementLineDialog> createState() =>
      _BankStatementLineDialogState();
}

class _BankStatementLineDialogState extends State<BankStatementLineDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();
  BankStatementLineDirection _direction = BankStatementLineDirection.deposit;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BankStatementDialogHeader(
                title: 'Add Bank Statement Line',
                subtitle: 'Capture bank evidence for reconciliation matching',
                icon: Icons.add_card_outlined,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _dateController,
                          decoration: bankStatementInputDecoration(
                            context,
                            label: 'Date',
                            hintText: 'YYYY-MM-DD',
                            icon: Icons.event_outlined,
                          ),
                          validator: _validateDate,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: bankStatementInputDecoration(
                            context,
                            label: 'Description',
                            icon: Icons.notes_outlined,
                          ),
                          validator: _required,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _referenceController,
                          decoration: bankStatementInputDecoration(
                            context,
                            label: 'Reference',
                            icon: Icons.tag_outlined,
                          ),
                        ),
                        const SizedBox(height: 12),
                        BankStatementLineAmountFields(
                          direction: _direction,
                          amountController: _amountController,
                          enabled: true,
                          onDirectionChanged:
                              (value) => setState(() => _direction = value),
                          amountValidator: _validateAmount,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppDialogActions(
                cancelLabel: 'Cancel',
                onCancel: () => Navigator.of(context).pop(),
                confirmLabel: 'Add Line',
                confirmIcon: Icons.add_rounded,
                onConfirm: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final absoluteAmount = double.parse(_amountController.text.trim());
    final signedAmount =
        _direction == BankStatementLineDirection.deposit
            ? absoluteAmount
            : -absoluteAmount;
    Navigator.of(context).pop(
      BankStatementLine(
        id: 'bank-stmt-${DateTime.now().microsecondsSinceEpoch}',
        date: DateTime.parse(_dateController.text.trim()),
        description: _descriptionController.text.trim(),
        amount: signedAmount,
        reference: _emptyToNull(_referenceController.text),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null) {
      return 'Use YYYY-MM-DD';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Enter a positive amount';
    }
    return null;
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
