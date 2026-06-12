import 'package:flutter/material.dart';

import '../theme/hris_theme.dart';

class HrisCommandHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> departments;
  final String departmentLabel;
  final String selectedDepartment;
  final bool attentionOnly;
  final String attentionLabel;
  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<bool> onAttentionChanged;

  const HrisCommandHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.departments,
    this.departmentLabel = 'Department',
    required this.selectedDepartment,
    required this.attentionOnly,
    this.attentionLabel = 'Needs attention',
    required this.onDepartmentChanged,
    required this.onAttentionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: hrisPanelDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 760;
          final heading = Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: HrisColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: HrisColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          );
          final controls = Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: isNarrow ? double.infinity : 220,
                child: DropdownButtonFormField<String>(
                  key: ValueKey(selectedDepartment),
                  initialValue: selectedDepartment,
                  decoration: InputDecoration(
                    labelText: departmentLabel,
                    prefixIcon: const Icon(Icons.apartment_outlined),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items:
                      departments
                          .map(
                            (department) => DropdownMenuItem(
                              value: department,
                              child: Text(department),
                            ),
                          )
                          .toList(),
                  onChanged: onDepartmentChanged,
                ),
              ),
              FilterChip(
                avatar: Icon(
                  attentionOnly
                      ? Icons.priority_high_rounded
                      : Icons.visibility_outlined,
                  size: 18,
                ),
                label: Text(attentionLabel),
                selected: attentionOnly,
                onSelected: onAttentionChanged,
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [heading, const SizedBox(height: 16), controls],
            );
          }

          return Row(
            children: [
              Expanded(child: heading),
              const SizedBox(width: 18),
              controls,
            ],
          );
        },
      ),
    );
  }
}
