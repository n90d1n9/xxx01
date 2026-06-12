import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_health_dashboard_models.dart';

class IncomingTalentHealthSignalTile extends StatelessWidget {
  final IncomingTalentHealthSignal signal;

  const IncomingTalentHealthSignalTile({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentHealthSignalSeverityColor(signal.severity);

    return HrisListSurface(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              signal.value,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signal.label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  signal.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          HrisStatusPill(label: signal.severity.label, color: color),
        ],
      ),
    );
  }
}

Color incomingTalentHealthSignalSeverityColor(
  IncomingTalentHealthSignalSeverity severity,
) {
  return switch (severity) {
    IncomingTalentHealthSignalSeverity.stable => const Color(0xFF15803D),
    IncomingTalentHealthSignalSeverity.watch => const Color(0xFFD97706),
    IncomingTalentHealthSignalSeverity.critical => const Color(0xFFDC2626),
  };
}
