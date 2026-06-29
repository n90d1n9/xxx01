import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/template.dart';
import 'package:go_router/go_router.dart';
import '../states/template_service_provider.dart';
import 'template_service.dart';

class TemplateListItem extends ConsumerWidget {
  final Template template;

  const TemplateListItem({super.key, required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the provider
    final templateService = ref.watch(templateServiceProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            template.icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          template.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: _buildTemplateInfo(),
        trailing: _buildStatusIndicator(),
        children: [_buildTemplateDetails(ref, context, templateService)],
      ),
    );
  }

  Widget _buildTemplateDetails(
    WidgetRef ref,
    BuildContext context,
    TemplateService templateService,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... existing fields code ...

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Edit template action
                    context.push('/templates/${template.id}/edit');
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Execute template using the service
                    templateService.executeTemplate(template);
                  },
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Execute'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          template.description,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            Chip(
              label: Text(template.category),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            if (!template.isActive)
              Chip(
                label: const Text('Inactive'),
                backgroundColor: Colors.grey[300],
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: template.isActive ? Colors.green : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  /* 
  Widget _buildTemplateDetails(WidgetRef ref, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template Fields
          if (template.fields.isNotEmpty) ...[
            const Text(
              'Template Fields:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children:
                  template.fields.map((field) {
                    return Chip(
                      label: Text('${field.label} (${field.key})'),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Default Context
          if (template.defaultContext.isNotEmpty) ...[
            const Text(
              'Default Context:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                template.defaultContext.toString(),
                style: const TextStyle(fontFamily: 'Monospace', fontSize: 10),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Tags
          if (template.tags.isNotEmpty) ...[
            const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children:
                  template.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Edit template action
                    context.push('/templates/${template.id}/edit');
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Execute template action
                    ref.read(templateServiceProvider).executeTemplate(template);
                  },
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Execute'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} */
}
