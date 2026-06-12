import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

import '../data/project_custom_attribute_templates.dart';
import '../models/project_form_draft.dart';
import '../models/project_portfolio_item.dart';
import 'project_form_date_range_editor.dart';
import 'project_form_draft_text_controllers.dart';
import 'project_form_layout.dart';
import 'project_form_percent_slider.dart';

class ProjectFormDraftFieldsSection extends StatelessWidget {
  const ProjectFormDraftFieldsSection({
    required this.draft,
    required this.textControllers,
    required this.onDraftChanged,
    super.key,
  });

  final ProjectFormDraft draft;
  final ProjectFormDraftTextControllers textControllers;
  final ValueChanged<ProjectFormDraft> onDraftChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProjectResponsiveFormGrid(
          children: [
            ProjectFormTextField(
              label: 'Project name',
              controller: textControllers.name,
              icon: Icons.work_outline,
              onChanged: (value) => onDraftChanged(draft.copyWith(name: value)),
            ),
            ProjectFormTextField(
              label: 'Client or business unit',
              controller: textControllers.client,
              icon: Icons.apartment_outlined,
              onChanged:
                  (value) => onDraftChanged(draft.copyWith(client: value)),
            ),
            ProjectFormTextField(
              label: 'Owner',
              controller: textControllers.owner,
              icon: Icons.person_outline,
              onChanged:
                  (value) => onDraftChanged(draft.copyWith(owner: value)),
            ),
            ProjectFormTextField(
              label: 'Sponsor',
              controller: textControllers.sponsor,
              icon: Icons.verified_user_outlined,
              onChanged:
                  (value) => onDraftChanged(draft.copyWith(sponsor: value)),
            ),
            AppSelectField<String>(
              label: 'Business domain',
              value: draft.businessDomain,
              icon: Icons.business_center_outlined,
              options: [
                for (final domain in projectBusinessDomainOptions)
                  AppSelectOption(value: domain, label: domain),
              ],
              onChanged: _changeBusinessDomain,
            ),
            AppSelectField<ProjectHealth>(
              label: 'Initial health',
              value: draft.health,
              icon: Icons.monitor_heart_outlined,
              options: [
                for (final health in ProjectHealth.values)
                  AppSelectOption(value: health, label: health.label),
              ],
              onChanged:
                  (value) => onDraftChanged(draft.copyWith(health: value)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ProjectFormTextField(
          label: 'Business outcome summary',
          controller: textControllers.summary,
          icon: Icons.notes_outlined,
          maxLines: 3,
          onChanged: (value) => onDraftChanged(draft.copyWith(summary: value)),
        ),
        const SizedBox(height: 16),
        ProjectFormDateRangeEditor(
          startDate: draft.startDate,
          endDate: draft.endDate,
          onStartChanged:
              (value) => onDraftChanged(draft.copyWith(startDate: value)),
          onEndChanged:
              (value) => onDraftChanged(draft.copyWith(endDate: value)),
        ),
        const SizedBox(height: 16),
        ProjectResponsiveFormGrid(
          children: [
            ProjectFormPercentSlider(
              label: 'Planned progress',
              value: draft.progress,
              color: colorScheme.primary,
              onChanged:
                  (value) => onDraftChanged(draft.copyWith(progress: value)),
            ),
            ProjectFormPercentSlider(
              label: 'Budget used',
              value: draft.budgetUsed,
              color: Colors.orange.shade700,
              onChanged:
                  (value) => onDraftChanged(draft.copyWith(budgetUsed: value)),
            ),
          ],
        ),
      ],
    );
  }

  void _changeBusinessDomain(String value) {
    onDraftChanged(
      draft.copyWith(
        businessDomain: value,
        customAttributes: mergeProjectCustomAttributesForDomain(
          domain: value,
          currentAttributes: draft.customAttributes,
        ),
      ),
    );
  }
}
