import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/schema/layout/layout.dart';
import '../models/schema/layout/section.dart';
import '../models/schema/styles/background.dart';
import '../models/schema/styles/gradient_stop.dart';
import '../models/schema/styles/gradient.dart' as g;
import '../models/schema/styles/spacing.dart';
import '../models/schema/styles/styles.dart';
import '../models/template.dart';
import '../services/template_library.dart';

class TemplatePickerDialog extends StatelessWidget {
  const TemplatePickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final templates = TemplateLibrary.templates;

    return Dialog(
      child: SizedBox(
        width: 900,
        height: 700,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Choose a Template',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return _TemplateCard(template: template);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends ConsumerWidget {
  final Template template;

  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Apply template
          for (final section in template.sections) {
            ref.read(builderStateProvider.notifier).addSection(section);
          }
          Navigator.pop(context);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: Center(
                  child: Icon(Icons.web, size: 64, color: Colors.grey[400]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      template.category,
                      style: const TextStyle(fontSize: 10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*  ),
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(
          minWidth: 28,
          minHeight: 28,
        ),
      ),
    );
  }
}
 */
class _AddSectionButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: OutlinedButton.icon(
        onPressed: () {
          _showAddSectionDialog(context, ref);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Section'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          side: BorderSide(color: Colors.grey[400]!),
        ),
      ),
    );
  }

  void _showAddSectionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Section'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SectionTypeCard(
                  title: 'Header',
                  icon: Icons.view_day,
                  onTap: () {
                    _addSection(ref, 'header');
                    Navigator.pop(context);
                  },
                ),
                _SectionTypeCard(
                  title: 'Hero',
                  icon: Icons.panorama,
                  onTap: () {
                    _addSection(ref, 'hero');
                    Navigator.pop(context);
                  },
                ),
                _SectionTypeCard(
                  title: 'Content',
                  icon: Icons.view_agenda,
                  onTap: () {
                    _addSection(ref, 'content');
                    Navigator.pop(context);
                  },
                ),
                _SectionTypeCard(
                  title: 'Footer',
                  icon: Icons.horizontal_rule,
                  onTap: () {
                    _addSection(ref, 'footer');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _addSection(WidgetRef ref, String type) {
    final section = Section(
      id: 'section-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      layout: Layout(type: 'flex', direction: 'column', alignment: 'center'),
      components: [],
      styles: _getDefaultSectionStyles(type),
    );
    ref.read(builderStateProvider.notifier).addSection(section);
  }

  Styles _getDefaultSectionStyles(String type) {
    switch (type) {
      case 'header':
        return Styles(
          padding: Spacing(all: '16px'),
          background: Background(color: '#FFFFFF'),
        );
      case 'hero':
        return Styles(
          padding: Spacing(all: '64px'),
          background: Background(
            gradient: g.Gradient(
              type: 'linear',
              stops: [
                GradientStop(color: '#667eea', position: '0%'),
                GradientStop(color: '#764ba2', position: '100%'),
              ],
            ),
          ),
        );
      case 'footer':
        return Styles(
          padding: Spacing(all: '32px'),
          background: Background(color: '#1F2937'),
        );
      default:
        return Styles(padding: Spacing(all: '32px'));
    }
  }
}

class _SectionTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _SectionTypeCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
