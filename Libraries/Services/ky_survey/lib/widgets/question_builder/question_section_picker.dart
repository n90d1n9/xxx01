import 'package:flutter/material.dart';

import '../../models/survey_section.dart';

class QuestionSectionPicker extends StatelessWidget {
  final List<SurveySection> sections;
  final String? selectedSectionId;
  final ValueChanged<String?> onChanged;

  const QuestionSectionPicker({
    super.key,
    required this.sections,
    required this.selectedSectionId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    final validSelectedSectionId =
        sections.any((section) => section.id == selectedSectionId)
        ? selectedSectionId
        : null;

    return DropdownButtonFormField<String?>(
      initialValue: validSelectedSectionId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Section',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('No section')),
        ...sections.map((section) {
          return DropdownMenuItem<String?>(
            value: section.id,
            child: Text(
              section.titleOrFallback,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }
}
