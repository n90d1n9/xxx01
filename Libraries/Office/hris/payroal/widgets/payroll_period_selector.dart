import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

class PayrollPeriodSelector extends StatelessWidget {
  final List<PayrollRunPeriod> periods;
  final PayrollRunPeriod selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const PayrollPeriodSelector({
    super.key,
    required this.periods,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: hrisPanelDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final selector = _PeriodDropdown(
            periods: periods,
            selectedPeriod: selectedPeriod,
            onPeriodChanged: onPeriodChanged,
          );
          final details = _PeriodDetails(period: selectedPeriod);

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [selector, const SizedBox(height: 12), details],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: selector),
              const SizedBox(width: 16),
              Expanded(child: details),
            ],
          );
        },
      ),
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  final List<PayrollRunPeriod> periods;
  final PayrollRunPeriod selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const _PeriodDropdown({
    required this.periods,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedPeriod.id,
      decoration: const InputDecoration(
        labelText: 'Payroll period',
        prefixIcon: Icon(Icons.event_available_outlined),
        border: OutlineInputBorder(),
      ),
      items: [
        for (final period in periods)
          DropdownMenuItem(
            value: period.id,
            child: Text(period.label, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (value) {
        if (value == null) return;
        onPeriodChanged(value);
      },
    );
  }
}

class _PeriodDetails extends StatelessWidget {
  final PayrollRunPeriod period;

  const _PeriodDetails({required this.period});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        HrisStatusPill(
          label: period.statusLabel,
          color:
              period.isCurrent
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF64748B),
        ),
        _MetaChip(
          icon: Icons.payments_outlined,
          label: 'Pay ${DateFormat('MMM d, yyyy').format(period.payDate)}',
        ),
        _MetaChip(
          icon: Icons.update_outlined,
          label: 'As of ${DateFormat('MMM d').format(period.asOfDate)}',
        ),
      ],
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
