import 'package:flutter/material.dart';

import '../models/project_form_draft.dart';
import 'project_domain_pack_summary_panel.dart';
import 'project_draft_preview_panel.dart';

class ProjectFormSupportPanels extends StatelessWidget {
  const ProjectFormSupportPanels({required this.draft, super.key});

  static const double wideBreakpoint = 860;

  final ProjectFormDraft draft;

  @override
  Widget build(BuildContext context) {
    final domainPackPanel = KeyedSubtree(
      key: const ValueKey('project-form-support-domain-pack'),
      child: ProjectDomainPackSummaryPanel(
        businessDomain: draft.businessDomain,
      ),
    );
    final draftPreviewPanel = KeyedSubtree(
      key: const ValueKey('project-form-support-draft-preview'),
      child: ProjectDraftPreviewPanel(draft: draft),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= wideBreakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: domainPackPanel),
              const SizedBox(width: 16),
              Expanded(child: draftPreviewPanel),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            domainPackPanel,
            const SizedBox(height: 16),
            draftPreviewPanel,
          ],
        );
      },
    );
  }
}
