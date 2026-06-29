import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_work_authorization_models.dart';

class EmployeeWorkAuthorizationForm extends StatelessWidget {
  final EmployeeWorkAuthorizationDraft draft;
  final TextEditingController titleController;
  final TextEditingController countryController;
  final TextEditingController ownerController;
  final TextEditingController notesController;
  final ValueChanged<EmployeeWorkAuthorizationType> onTypeChanged;
  final ValueChanged<EmployeeWorkAuthorizationSponsorship> onSponsorshipChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSelectExpiryDate;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onSubmit;

  const EmployeeWorkAuthorizationForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.countryController,
    required this.ownerController,
    required this.notesController,
    required this.onTypeChanged,
    required this.onSponsorshipChanged,
    required this.onTitleChanged,
    required this.onCountryChanged,
    required this.onOwnerChanged,
    required this.onNotesChanged,
    required this.onSelectExpiryDate,
    required this.onSelectReviewDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResponsiveFieldPair(
            first: DropdownButtonFormField<EmployeeWorkAuthorizationType>(
              initialValue: draft.type,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Authorization type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.assignment_ind_outlined),
              ),
              items:
                  EmployeeWorkAuthorizationType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            type.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) onTypeChanged(value);
              },
            ),
            second:
                DropdownButtonFormField<EmployeeWorkAuthorizationSponsorship>(
                  initialValue: draft.sponsorship,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Sponsorship',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.handshake_outlined),
                  ),
                  items:
                      EmployeeWorkAuthorizationSponsorship.values
                          .map(
                            (sponsorship) => DropdownMenuItem(
                              value: sponsorship,
                              child: Text(
                                sponsorship.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) onSponsorshipChanged(value);
                  },
                ),
          ),
          const SizedBox(height: 12),
          _ResponsiveFieldPair(
            first: _AuthorizationDateField(
              label: 'Expiry',
              date: draft.expiryDate,
              onTap: onSelectExpiryDate,
            ),
            second: _AuthorizationDateField(
              label: 'Review',
              date: draft.reviewDate,
              onTap: onSelectReviewDate,
            ),
          ),
          const SizedBox(height: 12),
          _AuthorizationTextField(
            controller: titleController,
            label: 'Document title',
            icon: Icons.short_text_outlined,
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          _ResponsiveFieldPair(
            first: _AuthorizationTextField(
              controller: countryController,
              label: 'Country',
              icon: Icons.public_outlined,
              onChanged: onCountryChanged,
            ),
            second: _AuthorizationTextField(
              controller: ownerController,
              label: 'Owner',
              icon: Icons.person_outline,
              onChanged: onOwnerChanged,
            ),
          ),
          const SizedBox(height: 12),
          _AuthorizationTextField(
            controller: notesController,
            label: 'Notes',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: onNotesChanged,
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: draft.completionRatio,
            color:
                draft.isReadyToSubmit
                    ? const Color(0xFF15803D)
                    : HrisColors.primary,
            label: '${(draft.completionRatio * 100).round()}% ready',
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              errors.first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: draft.isReadyToSubmit ? onSubmit : null,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Submit authorization'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveFieldPair extends StatelessWidget {
  final Widget first;
  final Widget second;

  const _ResponsiveFieldPair({required this.first, required this.second});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return Column(children: [first, const SizedBox(height: 12), second]);
        }

        return Row(
          children: [
            Expanded(child: first),
            const SizedBox(width: 12),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _AuthorizationDateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _AuthorizationDateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_outlined),
        ),
        child: Text(
          DateFormat('MMM d, yyyy').format(date),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _AuthorizationTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;

  const _AuthorizationTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : 4,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      onChanged: onChanged,
    );
  }
}
