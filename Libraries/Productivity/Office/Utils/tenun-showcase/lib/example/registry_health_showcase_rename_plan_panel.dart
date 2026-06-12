import 'package:flutter/material.dart';

import 'registry_health_showcase_naming.dart';
import 'registry_health_showcase_rename_plan.dart';

class RegistryHealthShowcaseRenamePlanPanel extends StatelessWidget {
  const RegistryHealthShowcaseRenamePlanPanel({
    super.key,
    required this.report,
    this.renamePlan,
    this.visibleLimit = 8,
  });

  final RegistryHealthShowcaseNamingReport report;
  final RegistryHealthShowcaseRenamePlanReport? renamePlan;
  final int visibleLimit;

  @override
  Widget build(BuildContext context) {
    final plan = renamePlan ?? registryHealthShowcaseRenamePlanReport(report);
    final allItems = plan.items;
    final visibleItems = plan.visibleItems(limit: visibleLimit);
    final visiblePatchPreviewLines = plan.visiblePatchPreviewLines(
      limit: visibleLimit,
    );
    final allBlockers = plan.blockers;
    final visibleBlockers = plan.visibleBlockers();
    final hiddenCount = allItems.length - visibleItems.length;
    final hiddenBlockerCount = allBlockers.length - visibleBlockers.length;
    final renameLabel = allItems.length == 1 ? 'rename' : 'renames';
    final blockerLabel = allBlockers.length == 1
        ? 'manifest task'
        : 'manifest tasks';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${allItems.length} known type key $renameLabel ready; ${allBlockers.length} $blockerLabel need manifest work first.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PlanMetricChip(
              label: 'Ready',
              value: allItems.length.toString(),
              color: allItems.isEmpty
                  ? Colors.blueGrey.shade700
                  : Colors.green.shade700,
            ),
            _PlanMetricChip(
              label: 'Manifest Work',
              value: allBlockers.length.toString(),
              color: allBlockers.isEmpty
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
            _PlanMetricChip(
              label: 'Patch Ops',
              value: plan.patchOperationCount.toString(),
              color: plan.patchIsValid
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (visibleItems.isEmpty)
          const Text('No canonical-key rename plan needed.')
        else
          _RenamePlanTable(items: visibleItems),
        if (hiddenCount > 0) ...[
          const SizedBox(height: 6),
          Text(
            '+$hiddenCount more planned renames',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (visiblePatchPreviewLines.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Patch Preview', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          _PatchPreviewList(lines: visiblePatchPreviewLines),
        ],
        if (visibleBlockers.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Manifest Work', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          _ManifestWorkTable(items: visibleBlockers),
        ],
        if (hiddenBlockerCount > 0) ...[
          const SizedBox(height: 6),
          Text(
            '+$hiddenBlockerCount more manifest tasks',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _PatchPreviewList extends StatelessWidget {
  const _PatchPreviewList({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _MonoText(line),
            ),
        ],
      ),
    );
  }
}

class _RenamePlanTable extends StatelessWidget {
  const _RenamePlanTable({required this.items});

  final List<RegistryHealthShowcaseRenamePlanItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowHeight: 34,
              dataRowMinHeight: 42,
              dataRowMaxHeight: 56,
              columns: const [
                DataColumn(label: Text('Sample')),
                DataColumn(label: Text('Target')),
                DataColumn(label: Text('From')),
                DataColumn(label: Text('To')),
                DataColumn(label: Text('Match')),
              ],
              rows: [
                for (final item in items)
                  DataRow(
                    cells: [
                      DataCell(
                        Text('${item.familyTitle} / ${item.sampleTitle}'),
                      ),
                      DataCell(_MonoText(item.targetPath)),
                      DataCell(_MonoText(item.fromType)),
                      DataCell(_MonoText(item.toType)),
                      DataCell(_RenamePlanStatusChip(item.status)),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ManifestWorkTable extends StatelessWidget {
  const _ManifestWorkTable({required this.items});

  final List<RegistryHealthShowcaseRenameBlocker> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowHeight: 34,
              dataRowMinHeight: 42,
              dataRowMaxHeight: 64,
              columns: const [
                DataColumn(label: Text('Sample')),
                DataColumn(label: Text('Path')),
                DataColumn(label: Text('Provided')),
                DataColumn(label: Text('Reason')),
                DataColumn(label: Text('Action')),
              ],
              rows: [
                for (final item in items)
                  DataRow(
                    cells: [
                      DataCell(
                        Text('${item.familyTitle} / ${item.sampleTitle}'),
                      ),
                      DataCell(Text(item.jsonPath)),
                      DataCell(
                        _MonoText(
                          item.providedType.isEmpty ? '-' : item.providedType,
                        ),
                      ),
                      DataCell(Text(item.reason)),
                      DataCell(Text(item.suggestedAction)),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlanMetricChip extends StatelessWidget {
  const _PlanMetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        radius: 11,
        backgroundColor: color.withValues(alpha: 0.12),
        foregroundColor: color,
        child: Text(value, style: const TextStyle(fontSize: 10)),
      ),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _MonoText extends StatelessWidget {
  const _MonoText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
    );
  }
}

class _RenamePlanStatusChip extends StatelessWidget {
  const _RenamePlanStatusChip(this.status);

  final RegistryHealthShowcaseNamingStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      RegistryHealthShowcaseNamingStatus.canonical => Colors.green.shade700,
      RegistryHealthShowcaseNamingStatus.normalized => Colors.orange.shade800,
      RegistryHealthShowcaseNamingStatus.alias => Colors.blueGrey.shade700,
      RegistryHealthShowcaseNamingStatus.unknown => Colors.red.shade700,
    };

    return Chip(
      label: Text(registryHealthShowcaseNamingStatusLabel(status)),
      backgroundColor: color.withValues(alpha: 0.08),
      visualDensity: VisualDensity.compact,
    );
  }
}
