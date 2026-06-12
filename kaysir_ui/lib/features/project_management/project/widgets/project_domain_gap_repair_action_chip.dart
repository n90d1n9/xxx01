import 'package:flutter/material.dart';

class ProjectDomainGapRepairActionChip extends StatelessWidget {
  const ProjectDomainGapRepairActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.tooltip,
    this.chipKey,
    this.maxWidth = 220,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String? tooltip;
  final Key? chipKey;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final chip = ActionChip(
      key: chipKey,
      avatar: Icon(icon, size: 16, color: color),
      label: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w900,
      ),
      onPressed: onPressed,
    );

    if (tooltip == null || tooltip!.trim().isEmpty) return chip;
    return Tooltip(message: tooltip!, child: chip);
  }
}
