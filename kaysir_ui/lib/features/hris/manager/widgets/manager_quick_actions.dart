import 'package:flutter/material.dart';

import '../../shared/widgets/hris_ui.dart';

class ManagerQuickActions extends StatelessWidget {
  final ValueChanged<String> onActionSelected;

  const ManagerQuickActions({super.key, required this.onActionSelected});

  @override
  Widget build(BuildContext context) {
    const actions = [
      _ManagerAction(
        label: 'Time off',
        icon: Icons.event_available_outlined,
        color: Color(0xFF2563EB),
      ),
      _ManagerAction(
        label: 'Reports',
        icon: Icons.query_stats_outlined,
        color: Color(0xFF7C3AED),
      ),
      _ManagerAction(
        label: 'Recruiting',
        icon: Icons.person_add_alt_1_outlined,
        color: Color(0xFF15803D),
      ),
      _ManagerAction(
        label: 'Budget',
        icon: Icons.account_balance_wallet_outlined,
        color: Color(0xFFD97706),
      ),
    ];

    return HrisSectionPanel(
      icon: Icons.bolt_outlined,
      title: 'Quick actions',
      subtitle: 'Frequent manager workflows',
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 520 ? 4 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 4 ? 1.15 : 1.45,
              ),
              itemCount: actions.length,
              itemBuilder:
                  (context, index) => _ManagerActionTile(
                    action: actions[index],
                    onTap: () => onActionSelected(actions[index].label),
                  ),
            );
          },
        ),
      ],
    );
  }
}

class _ManagerActionTile extends StatelessWidget {
  final _ManagerAction action;
  final VoidCallback onTap;

  const _ManagerActionTile({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: action.color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, color: action.color),
              const SizedBox(height: 8),
              Text(
                action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManagerAction {
  final String label;
  final IconData icon;
  final Color color;

  const _ManagerAction({
    required this.label,
    required this.icon,
    required this.color,
  });
}
