import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

class EssQuickActions extends StatelessWidget {
  final VoidCallback onUpdateProfile;
  final VoidCallback onViewPayStubs;
  final VoidCallback onRequestTimeOff;
  final VoidCallback onSubmitFeedback;

  const EssQuickActions({
    super.key,
    required this.onUpdateProfile,
    required this.onViewPayStubs,
    required this.onRequestTimeOff,
    required this.onSubmitFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Quick Actions',
      icon: Icons.bolt_outlined,
      subtitle: 'Common self-service tasks',
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760 ? 4 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 4 ? 1.35 : 1.55,
              children: [
                _ActionTile(
                  icon: Icons.person_outline,
                  title: 'Update Profile',
                  color: const Color(0xFF2563EB),
                  onTap: onUpdateProfile,
                ),
                _ActionTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'View Pay Stubs',
                  color: const Color(0xFF059669),
                  onTap: onViewPayStubs,
                ),
                _ActionTile(
                  icon: Icons.event_available_outlined,
                  title: 'Request Time Off',
                  color: const Color(0xFFD97706),
                  onTap: onRequestTimeOff,
                ),
                _ActionTile(
                  icon: Icons.feedback_outlined,
                  title: 'Submit Feedback',
                  color: const Color(0xFF7C3AED),
                  onTap: onSubmitFeedback,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
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
