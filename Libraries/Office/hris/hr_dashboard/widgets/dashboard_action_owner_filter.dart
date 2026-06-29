import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_owner_summary.dart';

class DashboardActionOwnerFilter extends StatelessWidget {
  final List<DashboardActionOwnerSummary> owners;
  final String selectedOwner;
  final ValueChanged<String> onChanged;

  const DashboardActionOwnerFilter({
    super.key,
    required this.owners,
    required this.selectedOwner,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount = owners.fold<int>(
      0,
      (total, owner) => total + owner.totalCount,
    );

    return HrisListSurface(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _OwnerFilterLabel(),
          ChoiceChip(
            avatar: const Icon(Icons.groups_2_outlined, size: 18),
            label: Text('$dashboardActionAllOwners ($totalCount)'),
            selected: selectedOwner == dashboardActionAllOwners,
            onSelected: (_) => onChanged(dashboardActionAllOwners),
          ),
          ...owners.map(
            (owner) => ChoiceChip(
              avatar: const Icon(Icons.account_circle_outlined, size: 18),
              label: Text('${owner.ownerLabel} (${owner.totalCount})'),
              selected: selectedOwner == owner.ownerLabel,
              onSelected: (_) => onChanged(owner.ownerLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerFilterLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 116),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.supervisor_account_outlined,
            size: 18,
            color: HrisColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Owner focus',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
