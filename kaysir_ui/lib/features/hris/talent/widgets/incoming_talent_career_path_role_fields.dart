import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_career_path_models.dart';
import '../states/incoming_talent_career_path_provider.dart';
import 'incoming_talent_career_path_text_input.dart';

class IncomingTalentCareerPathRoleFields extends ConsumerWidget {
  final TextEditingController currentRoleController;
  final TextEditingController targetRoleController;
  final TextEditingController competencyController;

  const IncomingTalentCareerPathRoleFields({
    super.key,
    required this.currentRoleController,
    required this.targetRoleController,
    required this.competencyController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(incomingTalentCareerPathDraftProvider.notifier);
    final fields = [
      IncomingTalentCareerPathTextInput(
        controller: currentRoleController,
        label: 'Current role',
        icon: Icons.work_outline,
        onChanged: notifier.setCurrentRole,
        validator:
            (value) => validateIncomingTalentCareerPathRequired(
              value,
              'a current role',
            ),
      ),
      IncomingTalentCareerPathTextInput(
        controller: targetRoleController,
        label: 'Target role',
        icon: Icons.trending_up_outlined,
        onChanged: notifier.setTargetRole,
        validator:
            (value) => validateIncomingTalentCareerPathRequired(
              value,
              'a target role',
            ),
      ),
      IncomingTalentCareerPathTextInput(
        controller: competencyController,
        label: 'Competency',
        icon: Icons.center_focus_strong_outlined,
        onChanged: notifier.setCompetencyName,
        validator: validateIncomingTalentCareerPathFocus,
      ),
    ];

    return _ResponsiveFieldRow(fields: fields, breakpoint: 760);
  }
}

class IncomingTalentCareerPathOwnerFields extends ConsumerWidget {
  final TextEditingController ownerController;
  final TextEditingController mentorController;

  const IncomingTalentCareerPathOwnerFields({
    super.key,
    required this.ownerController,
    required this.mentorController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(incomingTalentCareerPathDraftProvider.notifier);
    final fields = [
      IncomingTalentCareerPathTextInput(
        controller: ownerController,
        label: 'Career owner',
        icon: Icons.badge_outlined,
        onChanged: notifier.setOwnerName,
        validator:
            (value) =>
                validateIncomingTalentCareerPathRequired(value, 'an owner'),
      ),
      IncomingTalentCareerPathTextInput(
        controller: mentorController,
        label: 'Mentor',
        icon: Icons.supervisor_account_outlined,
        onChanged: notifier.setMentorName,
        validator:
            (value) =>
                validateIncomingTalentCareerPathRequired(value, 'a mentor'),
      ),
    ];

    return _ResponsiveFieldRow(fields: fields, breakpoint: 620);
  }
}

class _ResponsiveFieldRow extends StatelessWidget {
  final List<Widget> fields;
  final double breakpoint;

  const _ResponsiveFieldRow({required this.fields, required this.breakpoint});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            children: [
              for (var index = 0; index < fields.length; index++) ...[
                fields[index],
                if (index < fields.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < fields.length; index++) ...[
              Expanded(child: fields[index]),
              if (index < fields.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}
