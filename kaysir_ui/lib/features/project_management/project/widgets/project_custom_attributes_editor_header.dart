import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';

class ProjectCustomAttributesEditorHeader extends StatelessWidget {
  const ProjectCustomAttributesEditorHeader({
    required this.businessDomain,
    required this.canAddAttribute,
    required this.onApplyDomainDefaults,
    required this.onAddAttribute,
    super.key,
  });

  final String businessDomain;
  final bool canAddAttribute;
  final VoidCallback onApplyDomainDefaults;
  final VoidCallback onAddAttribute;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      key: const ValueKey('project-custom-attributes-editor-header'),
      spacing: 12,
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.extension_outlined,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Domain Extensions',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$businessDomain fields and custom attributes',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppActionButton(
              key: const ValueKey('project-custom-attributes-domain-defaults'),
              label: 'Domain Defaults',
              icon: Icons.auto_fix_high_outlined,
              variant: AppActionButtonVariant.secondary,
              compact: true,
              onPressed: onApplyDomainDefaults,
            ),
            AppActionButton(
              key: const ValueKey('project-custom-attributes-add-field'),
              label: 'Add Field',
              icon: Icons.add_rounded,
              variant: AppActionButtonVariant.secondary,
              compact: true,
              onPressed: canAddAttribute ? onAddAttribute : null,
            ),
          ],
        ),
      ],
    );
  }
}
