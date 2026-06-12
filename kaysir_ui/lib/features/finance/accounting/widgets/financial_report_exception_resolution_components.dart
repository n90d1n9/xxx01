import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../widgets/ui/app_icon_badge.dart';
import '../../../../widgets/ui/app_info_row.dart';
import '../../../../widgets/ui/app_select_field.dart';
import '../../../../widgets/ui/app_status_pill.dart';
import '../../../../widgets/ui/app_surface.dart';
import '../../../../widgets/ui/app_text_cluster.dart';
import '../accounting_core/models/ledger_posting.dart';
import '../models/financial_report_exception_resolution.dart';
import '../models/financial_report_review_exception.dart';
import 'financial_report_resolution_form_components.dart';

class FinancialReportExceptionResolutionHeader extends StatelessWidget {
  const FinancialReportExceptionResolutionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconBadge(
          icon: Icons.verified_user_rounded,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppTextCluster(
            title: 'Resolve Report Exception',
            subtitle:
                'Attach approval, deferral, or posted adjustment evidence for close review.',
            titleStyle: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            subtitleMaxLines: 2,
          ),
        ),
      ],
    );
  }
}

class FinancialReportExceptionSummaryCard extends StatelessWidget {
  const FinancialReportExceptionSummaryCard({
    required this.exception,
    super.key,
  });

  final FinancialReportReviewException exception;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final varianceText = _varianceText(exception);

    return AppSurface(
      padding: const EdgeInsets.all(14),
      backgroundColor: colorScheme.surfaceContainerLow,
      borderColor: colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextCluster(
                  title: exception.title,
                  subtitle: exception.description,
                  titleStyle: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                  subtitleMaxLines: 3,
                ),
              ),
              const SizedBox(width: 10),
              AppStatusPill(
                label: exception.severity.label,
                color: exception.severity._color(colorScheme),
                icon: exception.severity._icon,
                maxWidth: 120,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ExceptionFact(
                title: 'Standard',
                value: exception.standardReference,
                icon: Icons.policy_outlined,
              ),
              if (varianceText != null)
                _ExceptionFact(
                  title: 'Variance',
                  value: varianceText,
                  icon: Icons.trending_up_rounded,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class FinancialReportExceptionStatusField extends StatelessWidget {
  const FinancialReportExceptionStatusField({
    required this.status,
    required this.onChanged,
    super.key,
  });

  final FinancialReportExceptionResolutionStatus status;
  final ValueChanged<FinancialReportExceptionResolutionStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<FinancialReportExceptionResolutionStatus>(
      label: 'Resolution status',
      icon: Icons.rule_rounded,
      value: status,
      options: [
        for (final value in FinancialReportExceptionResolutionStatus.values)
          AppSelectOption(value: value, label: value.label),
      ],
      onChanged: onChanged,
    );
  }
}

class FinancialReportExceptionEvidenceField extends StatelessWidget {
  const FinancialReportExceptionEvidenceField({
    required this.status,
    required this.referenceController,
    required this.adjustmentPostings,
    required this.selectedAdjustmentPostingId,
    required this.onAdjustmentPostingChanged,
    required this.postedAdjustmentValidator,
    super.key,
  });

  final FinancialReportExceptionResolutionStatus status;
  final TextEditingController referenceController;
  final List<LedgerPosting> adjustmentPostings;
  final String? selectedAdjustmentPostingId;
  final ValueChanged<String?> onAdjustmentPostingChanged;
  final FormFieldValidator<String> postedAdjustmentValidator;

  @override
  Widget build(BuildContext context) {
    if (status != FinancialReportExceptionResolutionStatus.adjusted) {
      return FinancialReportResolutionTextField(
        controller: referenceController,
        label: 'Approval or follow-up reference',
        hintText: 'Example: REV-001',
        icon: Icons.tag_rounded,
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: selectedAdjustmentPostingId,
      isExpanded: true,
      borderRadius: BorderRadius.circular(8),
      decoration: financialReportResolutionInputDecoration(
        context,
        label: 'Posted adjustment journal',
        helperText: 'Post the adjustment journal first, then attach it here.',
        icon: Icons.receipt_long_rounded,
      ),
      items: [
        for (final posting in adjustmentPostings)
          DropdownMenuItem(
            value: posting.id,
            child: Text(
              '${posting.reference} - ${posting.description}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: onAdjustmentPostingChanged,
      validator: postedAdjustmentValidator,
    );
  }
}

class _ExceptionFact extends StatelessWidget {
  const _ExceptionFact({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: AppInfoRow(
        title: value,
        subtitle: title,
        icon: icon,
        contained: true,
        iconStyle: AppInfoRowIconStyle.badge,
        titleMaxLines: 2,
        subtitleMaxLines: 1,
      ),
    );
  }
}

String? _varianceText(FinancialReportReviewException exception) {
  final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  final variance = exception.variance;
  final comparativeVariance = exception.comparativeVariance;

  if (variance == null && comparativeVariance == null) {
    return null;
  }
  if (variance != null && comparativeVariance != null) {
    return '${formatter.format(variance)} / ${formatter.format(comparativeVariance)}';
  }
  return formatter.format(variance ?? comparativeVariance);
}

extension _FinancialReportReviewExceptionSeverityVisuals
    on FinancialReportReviewExceptionSeverity {
  IconData get _icon {
    switch (this) {
      case FinancialReportReviewExceptionSeverity.material:
        return Icons.priority_high_rounded;
      case FinancialReportReviewExceptionSeverity.blocking:
        return Icons.block_rounded;
      case FinancialReportReviewExceptionSeverity.review:
        return Icons.rate_review_outlined;
    }
  }

  Color _color(ColorScheme colorScheme) {
    switch (this) {
      case FinancialReportReviewExceptionSeverity.material:
        return colorScheme.error;
      case FinancialReportReviewExceptionSeverity.blocking:
        return colorScheme.error;
      case FinancialReportReviewExceptionSeverity.review:
        return colorScheme.tertiary;
    }
  }
}
