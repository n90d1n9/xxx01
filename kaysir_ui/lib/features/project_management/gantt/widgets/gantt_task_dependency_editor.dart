import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_task_dependency_option_service.dart';

const _noDependencyValue = '__no_dependency__';

class GanttTaskDependencyEditor extends StatelessWidget {
  const GanttTaskDependencyEditor({
    required this.task,
    required this.dependencyTasks,
    this.dependencyTitle,
    this.onDependencyChanged,
    super.key,
  });

  final gantt.GanttTask task;
  final List<gantt.GanttTask> dependencyTasks;
  final String? dependencyTitle;
  final ValueChanged<String?>? onDependencyChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final options = buildGanttTaskDependencyOptions(
      task: task,
      dependencyTasks: dependencyTasks,
    );
    final currentDependencyId = options.currentDependencyId;
    final subtitle =
        currentDependencyId == null
            ? 'This item can start without a predecessor.'
            : options.hasMissingDependency
            ? 'Current predecessor is missing from this roadmap.'
            : options.hasGuardedCurrentDependency
            ? 'Current predecessor is protected by dependency guards.'
            : 'Current predecessor: ${dependencyTitle ?? currentDependencyId}';
    final guardSummary = _DependencyGuardSummary(options: options);
    final field = SizedBox(
      width: 240,
      child: _DependencySelectField(
        options: options,
        enabled: onDependencyChanged != null,
        onChanged: onDependencyChanged,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final infoRow = AppInfoRow(
          title: 'Predecessor',
          subtitle: subtitle,
          icon: Icons.link_rounded,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: colorScheme.secondaryContainer,
          iconForegroundColor: colorScheme.onSecondaryContainer,
          subtitleMaxLines: 2,
          trailing: constraints.maxWidth >= 560 ? field : null,
        );

        if (constraints.maxWidth >= 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [infoRow, const SizedBox(height: 8), guardSummary],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            infoRow,
            const SizedBox(height: 8),
            _DependencySelectField(
              options: options,
              enabled: onDependencyChanged != null,
              onChanged: onDependencyChanged,
            ),
            const SizedBox(height: 8),
            guardSummary,
          ],
        );
      },
    );
  }
}

class _DependencySelectField extends StatelessWidget {
  const _DependencySelectField({
    required this.options,
    required this.enabled,
    this.onChanged,
  });

  final GanttTaskDependencyOptions options;
  final bool enabled;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentDependencyId = options.currentDependencyId;
    final selectedValue = currentDependencyId ?? _noDependencyValue;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return DropdownButtonFormField<String>(
      key: const ValueKey('gantt-task-dependency-select'),
      initialValue: selectedValue,
      isExpanded: true,
      borderRadius: BorderRadius.circular(8),
      menuMaxHeight: 320,
      decoration: InputDecoration(
        labelText: 'Predecessor',
        prefixIcon: const Icon(Icons.account_tree_outlined, size: 18),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: border,
        enabledBorder: border,
      ),
      items: [
        const DropdownMenuItem<String>(
          value: _noDependencyValue,
          child: Text('No predecessor', overflow: TextOverflow.ellipsis),
        ),
        for (final candidate in options.candidates)
          DropdownMenuItem<String>(
            value: candidate.id,
            child: Text(candidate.title, overflow: TextOverflow.ellipsis),
          ),
        if (options.shouldIncludeCurrentDependencyOption)
          DropdownMenuItem<String>(
            value: currentDependencyId,
            child: Text(
              options.hasMissingDependency
                  ? 'Missing: $currentDependencyId'
                  : 'Guarded: ${options.currentDependencyTask?.title ?? currentDependencyId}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged:
          enabled
              ? (value) {
                if (value == selectedValue) return;
                onChanged?.call(value == _noDependencyValue ? null : value);
              }
              : null,
    );
  }
}

class _DependencyGuardSummary extends StatelessWidget {
  const _DependencyGuardSummary({required this.options});

  final GanttTaskDependencyOptions options;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppStatusPill(
          label: options.availabilityLabel,
          icon: Icons.fact_check_outlined,
          color: colorScheme.primary,
          maxWidth: 150,
        ),
        AppStatusPill(
          label: options.guardLabel,
          icon: Icons.shield_outlined,
          color:
              options.blockedCycleCount > 0
                  ? colorScheme.error
                  : colorScheme.tertiary,
          maxWidth: 160,
        ),
        if (options.hasMissingDependency || options.hasGuardedCurrentDependency)
          AppStatusPill(
            label: options.currentGuardLabel,
            icon:
                options.hasMissingDependency
                    ? Icons.report_problem_outlined
                    : Icons.lock_outline_rounded,
            color:
                options.hasMissingDependency
                    ? colorScheme.error
                    : colorScheme.secondary,
            maxWidth: 180,
          ),
      ],
    );
  }
}
