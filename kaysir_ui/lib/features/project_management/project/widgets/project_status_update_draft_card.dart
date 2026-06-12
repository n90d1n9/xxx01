import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_copy_brief_card.dart';

class ProjectStatusUpdateDraftCard extends StatelessWidget {
  const ProjectStatusUpdateDraftCard({
    required this.draftText,
    required this.onCopy,
    this.copied = false,
    super.key,
  });

  final String draftText;
  final VoidCallback? onCopy;
  final bool copied;

  @override
  Widget build(BuildContext context) {
    return AppCopyBriefCard(
      title: 'Briefing draft',
      text: draftText,
      icon: Icons.edit_note_outlined,
      copied: copied,
      onCopy: onCopy,
    );
  }
}
