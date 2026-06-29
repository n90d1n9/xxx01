import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/docs_provider.dart';

class WidgetGalleryPanel extends ConsumerStatefulWidget {
  const WidgetGalleryPanel({super.key});

  @override
  ConsumerState<WidgetGalleryPanel> createState() => _WidgetGalleryPanelState();
}

class _WidgetGalleryPanelState extends ConsumerState<WidgetGalleryPanel> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.widgets),
                    const SizedBox(width: 12),
                    Text(
                      'Insert Block or Widget',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CategoryChip('all', 'All'),
                      _CategoryChip('basic', 'Basic Blocks'),
                      _CategoryChip('media', 'Media'),
                      _CategoryChip('embed', 'Embeds'),
                      _CategoryChip('chart', 'Charts'),
                      _CategoryChip('advanced', 'Advanced'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _getFilteredWidgets().length,
                  itemBuilder: (context, index) {
                    final widget = _getFilteredWidgets()[index];
                    return _WidgetCard(
                      widget: widget,
                      onTap: () {
                        _insertWidget(widget.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<InsertableWidget> _getFilteredWidgets() {
    final allWidgets = [
      // Basic Blocks
      InsertableWidget(
        id: 'heading1',
        name: 'Heading 1',
        icon: Icons.title,
        category: 'basic',
        color: Colors.blue,
      ),
      InsertableWidget(
        id: 'heading2',
        name: 'Heading 2',
        icon: Icons.title,
        category: 'basic',
        color: Colors.blue,
      ),
      InsertableWidget(
        id: 'paragraph',
        name: 'Paragraph',
        icon: Icons.text_fields,
        category: 'basic',
        color: Colors.grey,
      ),
      InsertableWidget(
        id: 'bullet',
        name: 'Bullet List',
        icon: Icons.format_list_bulleted,
        category: 'basic',
        color: Colors.grey,
      ),
      InsertableWidget(
        id: 'numbered',
        name: 'Numbered List',
        icon: Icons.format_list_numbered,
        category: 'basic',
        color: Colors.grey,
      ),
      InsertableWidget(
        id: 'checkbox',
        name: 'Checklist',
        icon: Icons.check_box,
        category: 'basic',
        color: Colors.green,
      ),
      InsertableWidget(
        id: 'quote',
        name: 'Quote',
        icon: Icons.format_quote,
        category: 'basic',
        color: Colors.purple,
      ),
      InsertableWidget(
        id: 'code',
        name: 'Code Block',
        icon: Icons.code,
        category: 'basic',
        color: Colors.orange,
      ),
      InsertableWidget(
        id: 'divider',
        name: 'Divider',
        icon: Icons.horizontal_rule,
        category: 'basic',
        color: Colors.grey,
      ),
      InsertableWidget(
        id: 'callout',
        name: 'Callout',
        icon: Icons.campaign,
        category: 'basic',
        color: Colors.amber,
      ),
      InsertableWidget(
        id: 'table',
        name: 'Table',
        icon: Icons.table_chart,
        category: 'basic',
        color: Colors.teal,
      ),
      // Media
      InsertableWidget(
        id: 'image',
        name: 'Image',
        icon: Icons.image,
        category: 'media',
        color: Colors.pink,
      ),
      InsertableWidget(
        id: 'video',
        name: 'Video',
        icon: Icons.videocam,
        category: 'media',
        color: Colors.red,
      ),
      InsertableWidget(
        id: 'audio',
        name: 'Audio',
        icon: Icons.audiotrack,
        category: 'media',
        color: Colors.deepPurple,
      ),
      InsertableWidget(
        id: 'file',
        name: 'File',
        icon: Icons.attach_file,
        category: 'media',
        color: Colors.blueGrey,
      ),
      // Embeds
      InsertableWidget(
        id: 'youtube',
        name: 'YouTube',
        icon: Icons.play_circle,
        category: 'embed',
        color: Colors.red,
      ),
      InsertableWidget(
        id: 'twitter',
        name: 'Twitter',
        icon: Icons.chat_bubble,
        category: 'embed',
        color: Colors.lightBlue,
      ),
      InsertableWidget(
        id: 'maps',
        name: 'Google Maps',
        icon: Icons.map,
        category: 'embed',
        color: Colors.green,
      ),
      InsertableWidget(
        id: 'iframe',
        name: 'Embed URL',
        icon: Icons.web,
        category: 'embed',
        color: Colors.indigo,
      ),
      // Charts
      InsertableWidget(
        id: 'chart_bar',
        name: 'Bar Chart',
        icon: Icons.bar_chart,
        category: 'chart',
        color: Colors.blue,
      ),
      InsertableWidget(
        id: 'chart_line',
        name: 'Line Chart',
        icon: Icons.show_chart,
        category: 'chart',
        color: Colors.green,
      ),
      InsertableWidget(
        id: 'chart_pie',
        name: 'Pie Chart',
        icon: Icons.pie_chart,
        category: 'chart',
        color: Colors.orange,
      ),
      InsertableWidget(
        id: 'chart_area',
        name: 'Area Chart',
        icon: Icons.area_chart,
        category: 'chart',
        color: Colors.purple,
      ),
      // Advanced
      InsertableWidget(
        id: 'math',
        name: 'Math Equation',
        icon: Icons.functions,
        category: 'advanced',
        color: Colors.deepOrange,
      ),
      InsertableWidget(
        id: 'mermaid',
        name: 'Diagram',
        icon: Icons.account_tree,
        category: 'advanced',
        color: Colors.cyan,
      ),
      InsertableWidget(
        id: 'calendar',
        name: 'Calendar',
        icon: Icons.calendar_month,
        category: 'advanced',
        color: Colors.red,
      ),
      InsertableWidget(
        id: 'kanban',
        name: 'Kanban Board',
        icon: Icons.view_column,
        category: 'advanced',
        color: Colors.deepPurple,
      ),
    ];

    if (_selectedCategory == 'all') return allWidgets;
    return allWidgets.where((w) => w.category == _selectedCategory).toList();
  }

  Widget _CategoryChip(String value, String label) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedCategory = value;
          });
        },
      ),
    );
  }

  void _insertWidget(String widgetId) {
    if (widgetId == 'youtube') {
      _showYoutubeDialog();
    } else if (widgetId == 'image') {
      _showImageDialog();
    } else if (widgetId == 'chart_bar' ||
        widgetId == 'chart_line' ||
        widgetId == 'chart_pie' ||
        widgetId == 'chart_area') {
      _showChartDialog(widgetId);
    } else if (widgetId == 'maps') {
      _showMapsDialog();
    } else {
      // Insert basic block
      ref.read(documentControllerProvider.notifier).insertBlock(widgetId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Inserted $widgetId')));
    }
  }

  void _showYoutubeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.play_circle, color: Colors.red),
                SizedBox(width: 8),
                Text('Embed YouTube Video'),
              ],
            ),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Location or Google Maps URL',
                hintText: 'Enter address or maps URL',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    final index =
                        ref
                            .read(documentControllerProvider)
                            .controller
                            .selection
                            .baseOffset;
                    ref
                        .read(documentControllerProvider)
                        .controller
                        .document
                        .insert(index, '\n[Maps: ${controller.text}]\n');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Map embedded')),
                    );
                  }
                },
                child: const Text('Insert'),
              ),
            ],
          ),
    );
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.image, color: Colors.pink),
                SizedBox(width: 8),
                Text('Insert Image'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.upload),
                  title: const Text('Upload from device'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image uploaded')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Insert from URL'),
                  onTap: () {
                    Navigator.pop(context);
                    _showUrlDialog('image');
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showUrlDialog(String type) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Insert $type URL'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'URL',
                hintText: 'https://...',
                border: const OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    final index =
                        ref
                            .read(documentControllerProvider)
                            .controller
                            .selection
                            .baseOffset;
                    ref
                        .read(documentControllerProvider)
                        .controller
                        .document
                        .insert(index, '\n[$type: ${controller.text}]\n');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('$type inserted')));
                  }
                },
                child: const Text('Insert'),
              ),
            ],
          ),
    );
  }

  void _showChartDialog(String chartType) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Insert ${chartType.split('_').last} Chart'),
              ],
            ),
            content: const Text('Chart data can be edited after insertion'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final index =
                      ref
                          .read(documentControllerProvider)
                          .controller
                          .selection
                          .baseOffset;
                  ref
                      .read(documentControllerProvider)
                      .controller
                      .document
                      .insert(index, '\n[Chart: $chartType - Sample Data]\n');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chart inserted')),
                  );
                },
                child: const Text('Insert'),
              ),
            ],
          ),
    );
  }

  void _showMapsDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.map, color: Colors.green),
                SizedBox(width: 8),
                Text('Embed Google Maps'),
              ],
            ),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'YouTube URL',
                hintText: 'https://www.youtube.com/watch?v=...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    final docController = ref.read(
                      documentControllerProvider.notifier,
                    );
                    final index =
                        ref
                            .read(documentControllerProvider)
                            .controller
                            .selection
                            .baseOffset;
                    ref
                        .read(documentControllerProvider)
                        .controller
                        .document
                        .insert(index, '\n[YouTube: ${controller.text}]\n');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('YouTube video embedded')),
                    );
                  }
                },
                child: const Text('Insert'),
              ),
            ],
          ),
    );
  }
}

class InsertableWidget {
  final String id;
  final String name;
  final IconData icon;
  final String category;
  final Color color;

  InsertableWidget({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.color,
  });
}

class _WidgetCard extends StatelessWidget {
  final InsertableWidget widget;
  final VoidCallback onTap;

  const _WidgetCard({required this.widget, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                widget.name,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
