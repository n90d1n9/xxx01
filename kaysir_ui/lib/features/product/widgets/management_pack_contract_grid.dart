import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/management_pack.dart';
import '../models/management_pack_contribution_bundle.dart';

/// Two-column view of pack data and behavior contracts.
class ProductManagementPackContractGrid extends StatelessWidget {
  const ProductManagementPackContractGrid({super.key, required this.bundle});

  final ProductManagementPackContributionBundle bundle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dataSection = _ContractSection(
          title: 'Data contract',
          rows: [
            _ContractRow(
              icon: Icons.star_rounded,
              label: 'Required fields',
              value: _fieldPreview(bundle.requiredFields),
              color: Colors.indigo.shade700,
            ),
            _ContractRow(
              icon: Icons.tune_rounded,
              label: 'Optional fields',
              value: _fieldPreview(bundle.optionalFields),
              color: Colors.blueGrey.shade700,
            ),
          ],
        );
        final behaviorSection = _ContractSection(
          title: 'Behavior contract',
          rows: [
            _ContractRow(
              icon: Icons.layers_rounded,
              label: 'Channel packs',
              value: _profilePackPreview(bundle),
              color: Colors.teal.shade700,
            ),
            _ContractRow(
              icon: Icons.bolt_rounded,
              label: 'Workspace groups',
              value: _actionGroupPreview(bundle),
              color: Colors.deepOrange.shade700,
            ),
          ],
        );

        if (constraints.maxWidth < 720) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              dataSection,
              const SizedBox(height: 16),
              behaviorSection,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: dataSection),
            const SizedBox(width: 24),
            Expanded(child: behaviorSection),
          ],
        );
      },
    );
  }
}

@Preview(name: 'Management pack contract grid')
Widget productManagementPackContractGridPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackContractGrid(bundle: _previewBundle),
      ),
    ),
  );
}

/// Contract subsection with one or more labeled rows.
class _ContractSection extends StatelessWidget {
  const _ContractSection({required this.title, required this.rows});

  final String title;
  final List<_ContractRow> rows;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        for (var index = 0; index < rows.length; index += 1) ...[
          _ContractLine(row: rows[index]),
          if (index != rows.length - 1) ...[
            const SizedBox(height: 10),
            Divider(color: colorScheme.outlineVariant, height: 1),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

/// Immutable display row for one contract detail.
class _ContractRow {
  const _ContractRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

/// Rendered contract detail row with icon and copy.
class _ContractLine extends StatelessWidget {
  const _ContractLine({required this.row});

  final _ContractRow row;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(row.icon, size: 18, color: row.color),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                row.value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _fieldPreview(List<ProductManagementPackField> fields) {
  if (fields.isEmpty) return 'None';
  if (fields.length <= 3) {
    return fields.map((field) => field.label).join(', ');
  }

  return '${fields.take(3).map((field) => field.label).join(', ')} '
      '+${fields.length - 3} more';
}

String _profilePackPreview(ProductManagementPackContributionBundle bundle) {
  final packs = bundle.managementPack.profilePacks;
  if (packs.isEmpty) return 'No channel packs';
  if (packs.length == 1) return packs.first.title;

  return '${packs.first.title} +${packs.length - 1} more';
}

String _actionGroupPreview(ProductManagementPackContributionBundle bundle) {
  final groups = bundle.workspaceActionGroups;
  if (groups.isEmpty) return 'No workspace groups';
  if (groups.length <= 2) return groups.map((group) => group.title).join(', ');

  return '${groups.take(2).map((group) => group.title).join(', ')} '
      '+${groups.length - 2} more';
}

final _previewBundle = ProductManagementPackContributionBundle(
  managementPack: coreProductManagementPack,
  workspaceActionGroups: const [],
  actionContributions: const [],
  recommendationContributions: const [],
);
