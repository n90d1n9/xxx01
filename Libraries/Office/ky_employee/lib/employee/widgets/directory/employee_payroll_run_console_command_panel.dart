import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_run_console_command_models.dart';

/// Compact command surface for directory-level payroll run operations.
class EmployeePayrollRunConsoleCommandPanel extends StatelessWidget {
  final EmployeePayrollRunConsoleCommandPlan plan;
  final EmployeePayrollRunConsoleCommandResult? lastResult;
  final ValueChanged<EmployeePayrollRunConsoleCommandType>? onRunCommand;

  const EmployeePayrollRunConsoleCommandPanel({
    super.key,
    required this.plan,
    required this.lastResult,
    required this.onRunCommand,
  });

  @override
  Widget build(BuildContext context) {
    final primaryCommand = plan.primaryCommand;

    if (plan.commands.isEmpty) {
      return const HrisListSurface(
        child: Text('Launch payroll run before console actions.'),
      );
    }

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Guided payroll actions',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (primaryCommand != null)
                HrisStatusPill(
                  label: primaryCommand.type.label,
                  color: const Color(0xFF2563EB),
                )
              else
                const HrisStatusPill(
                  label: 'Complete',
                  color: Color(0xFF15803D),
                ),
              const SizedBox(width: 8),
              HrisStatusPill(label: plan.scopeLabel, color: HrisColors.muted),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            plan.scopeDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;
              return Column(
                children: [
                  for (
                    var index = 0;
                    index < plan.commands.length;
                    index++
                  ) ...[
                    if (index > 0) const Divider(height: 18),
                    _PayrollRunConsoleCommandRow(
                      command: plan.commands[index],
                      compact: compact,
                      onRunCommand: onRunCommand,
                    ),
                  ],
                ],
              );
            },
          ),
          if (lastResult != null) ...[
            const SizedBox(height: 12),
            _PayrollRunConsoleCommandResultBanner(result: lastResult!),
          ],
        ],
      ),
    );
  }
}

/// Row for one available payroll console command.
class _PayrollRunConsoleCommandRow extends StatelessWidget {
  final EmployeePayrollRunConsoleCommand command;
  final bool compact;
  final ValueChanged<EmployeePayrollRunConsoleCommandType>? onRunCommand;

  const _PayrollRunConsoleCommandRow({
    required this.command,
    required this.compact,
    required this.onRunCommand,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Icon(_iconFor(command.type), size: 20, color: _colorFor(command)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                command.type.label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                command.type.description,
                maxLines: compact ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ),
      ],
    );

    final controls = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: compact ? WrapAlignment.start : WrapAlignment.end,
      children: [
        HrisStatusPill(
          label: command.readinessLabel,
          color: _colorFor(command),
        ),
        SizedBox(
          width: 136,
          height: 36,
          child: FilledButton.tonalIcon(
            key: ValueKey(
              'employee-payroll-run-console-command-${command.type.name}',
            ),
            icon: Icon(_iconFor(command.type), size: 17),
            label: Text(
              command.type.actionLabel,
              overflow: TextOverflow.ellipsis,
            ),
            onPressed:
                command.isEnabled && onRunCommand != null
                    ? () => onRunCommand!(command.type)
                    : null,
          ),
        ),
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [content, const SizedBox(height: 8), controls],
      );
    }

    return Row(
      children: [Expanded(child: content), const SizedBox(width: 12), controls],
    );
  }
}

/// Latest command outcome shown below the payroll console commands.
class _PayrollRunConsoleCommandResultBanner extends StatelessWidget {
  final EmployeePayrollRunConsoleCommandResult result;

  const _PayrollRunConsoleCommandResultBanner({required this.result});

  @override
  Widget build(BuildContext context) {
    final color =
        result.hasChanges ? const Color(0xFF15803D) : const Color(0xFFB45309);

    return Container(
      key: const ValueKey('employee-payroll-run-console-command-result'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            result.hasChanges ? Icons.check_circle_outline : Icons.info_outline,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.message,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  result.supportingLabel,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee payroll run console commands')
Widget employeePayrollRunConsoleCommandPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeePayrollRunConsoleCommandPanel(
          plan: const EmployeePayrollRunConsoleCommandPlan(
            runReference: 'RUN-202605-001',
            selectedEmployeeCount: 3,
            targetEmployeeCount: 3,
            commands: [
              EmployeePayrollRunConsoleCommand(
                type: EmployeePayrollRunConsoleCommandType.prepareExport,
                eligibleCount: 2,
                blockedCount: 1,
                completedCount: 5,
              ),
              EmployeePayrollRunConsoleCommand(
                type: EmployeePayrollRunConsoleCommandType.settlePayment,
                eligibleCount: 4,
                blockedCount: 0,
                completedCount: 3,
              ),
              EmployeePayrollRunConsoleCommand(
                type: EmployeePayrollRunConsoleCommandType.publishPayslip,
                eligibleCount: 2,
                blockedCount: 2,
                completedCount: 3,
              ),
              EmployeePayrollRunConsoleCommand(
                type: EmployeePayrollRunConsoleCommandType.closePeriod,
                eligibleCount: 0,
                blockedCount: 4,
                completedCount: 1,
              ),
            ],
          ),
          lastResult: const EmployeePayrollRunConsoleCommandResult(
            type: EmployeePayrollRunConsoleCommandType.settlePayment,
            completedCount: 4,
            skippedCount: 1,
            errors: [],
            message: '4 employees settled, 1 skipped.',
          ),
          onRunCommand: (_) {},
        ),
      ),
    ),
  );
}

IconData _iconFor(EmployeePayrollRunConsoleCommandType type) {
  return switch (type) {
    EmployeePayrollRunConsoleCommandType.prepareExport =>
      Icons.upload_file_outlined,
    EmployeePayrollRunConsoleCommandType.settlePayment =>
      Icons.payments_outlined,
    EmployeePayrollRunConsoleCommandType.publishPayslip =>
      Icons.receipt_long_outlined,
    EmployeePayrollRunConsoleCommandType.closePeriod =>
      Icons.lock_clock_outlined,
  };
}

Color _colorFor(EmployeePayrollRunConsoleCommand command) {
  if (command.isEnabled) return const Color(0xFF2563EB);
  if (command.blockedCount > 0) return const Color(0xFFB45309);
  if (command.completedCount > 0) return const Color(0xFF15803D);
  return HrisColors.muted;
}
