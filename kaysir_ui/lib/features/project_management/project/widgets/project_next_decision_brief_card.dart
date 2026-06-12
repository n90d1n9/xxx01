import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_copy_brief_card.dart';

class ProjectNextDecisionBriefCard extends StatelessWidget {
  const ProjectNextDecisionBriefCard({
    required this.briefText,
    required this.onCopy,
    this.copied = false,
    super.key,
  });

  final String briefText;
  final VoidCallback? onCopy;
  final bool copied;

  @override
  Widget build(BuildContext context) {
    return AppCopyBriefCard(
      title: 'Decision brief',
      text: briefText,
      icon: Icons.assignment_outlined,
      copied: copied,
      onCopy: onCopy,
    );
  }
}
