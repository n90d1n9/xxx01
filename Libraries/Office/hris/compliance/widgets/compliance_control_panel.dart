import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/compliance_models.dart';
import 'compliance_status_styles.dart';

class ComplianceControlPanel extends StatelessWidget {
  final List<ComplianceControl> controls;

  const ComplianceControlPanel({super.key, required this.controls});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Required Controls',
      subtitle: '${controls.length} controls',
      emptyMessage: 'No matching controls',
      children:
          controls.map((control) => _ControlTile(control: control)).toList(),
    );
  }
}

class _ControlTile extends StatelessWidget {
  final ComplianceControl control;

  const _ControlTile({required this.control});

  @override
  Widget build(BuildContext context) {
    final color = controlStatusColor(control.status);
    final formatter = DateFormat('MMM d');

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  control.controlName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              HrisStatusPill(
                label: controlStatusLabel(control.status),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${control.department} - ${control.ownerName} - due ${formatter.format(control.dueDate)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: control.completionRate / 100,
            color: color,
            label: '${control.completionRate}% complete',
          ),
        ],
      ),
    );
  }
}
