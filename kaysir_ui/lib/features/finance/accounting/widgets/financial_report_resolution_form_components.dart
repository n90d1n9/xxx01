import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';

class FinancialReportResolutionDialogFrame extends StatelessWidget {
  const FinancialReportResolutionDialogFrame({
    required this.header,
    required this.formKey,
    required this.children,
    required this.onCancel,
    required this.onConfirm,
    this.cancelLabel = 'Cancel',
    this.confirmLabel = 'Save Evidence',
    this.cancelIcon = Icons.close_rounded,
    this.confirmIcon = Icons.check_rounded,
    this.insetPadding = const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 24,
    ),
    this.constraints = const BoxConstraints(maxWidth: 560, maxHeight: 700),
    this.padding = const EdgeInsets.all(24),
    super.key,
  });

  final Widget header;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final String cancelLabel;
  final String confirmLabel;
  final IconData cancelIcon;
  final IconData confirmIcon;
  final EdgeInsets insetPadding;
  final BoxConstraints constraints;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: insetPadding,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: constraints,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 18),
              Expanded(
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppDialogActions(
                cancelLabel: cancelLabel,
                cancelIcon: cancelIcon,
                onCancel: onCancel,
                confirmLabel: confirmLabel,
                confirmIcon: confirmIcon,
                onConfirm: onConfirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FinancialReportResolutionTextField extends StatelessWidget {
  const FinancialReportResolutionTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hintText,
    this.helperText,
    this.alignLabelWithHint = false,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.textInputAction,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hintText;
  final String? helperText;
  final bool alignLabelWithHint;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final bool enabled;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      textInputAction: textInputAction,
      decoration: financialReportResolutionInputDecoration(
        context,
        label: label,
        hintText: hintText,
        helperText: helperText,
        icon: icon,
        alignLabelWithHint: alignLabelWithHint,
      ),
      validator: validator,
    );
  }
}

InputDecoration financialReportResolutionInputDecoration(
  BuildContext context, {
  required String label,
  required IconData icon,
  String? hintText,
  String? helperText,
  bool alignLabelWithHint = false,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: colorScheme.outlineVariant),
  );

  return InputDecoration(
    labelText: label,
    hintText: hintText,
    helperText: helperText,
    prefixIcon: Icon(icon, size: 18),
    alignLabelWithHint: alignLabelWithHint,
    filled: true,
    fillColor: colorScheme.surface,
    border: border,
    enabledBorder: border,
  );
}

String? financialReportResolutionRequiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  return null;
}
