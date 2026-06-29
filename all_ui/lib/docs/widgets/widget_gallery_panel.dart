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
  final _searchController = TextEditingController();
  String _searchQuery = '';

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
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.widgets,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Insert Block or Widget',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search widgets...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              // Categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CategoryChip('all', 'All', Icons.apps),
                      _CategoryChip('basic', 'Basic', Icons.text_fields),
                      _CategoryChip('media', 'Media', Icons.image),
                      _CategoryChip('embed', 'Embeds', Icons.language),
                      _CategoryChip('chart', 'Charts', Icons.bar_chart),
                      _CategoryChip('advanced', 'Advanced', Icons.auto_awesome),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Widget grid
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
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
        description: 'Large section heading',
        icon: Icons.title,
        category: 'basic',
        color: Colors.blue,
      ),
      InsertableWidget(
        id: 'heading2',
        name: 'Heading 2',
        description: 'Medium section heading',
        icon: Icons.title,
        category: 'basic',
        color: Colors.blue.shade400,
      ),
      InsertableWidget(
        id: 'heading3',
        name: 'Heading 3',
        description: 'Small section heading',
        icon: Icons.title,
        category: 'basic',
        color: Colors.blue.shade300,
      ),
      InsertableWidget(
        id: 'paragraph',
        name: 'Paragraph',
        description: 'Plain text block',
        icon: Icons.text_fields,
        category: 'basic',
        color: Colors.grey,
      ),
      InsertableWidget(
        id: 'bullet',
        name: 'Bullet List',
        description: 'Simple bulleted list',
        icon: Icons.format_list_bulleted,
        category: 'basic',
        color: Colors.grey.shade700,
      ),
      InsertableWidget(
        id: 'numbered',
        name: 'Numbered List',
        description: 'Numbered list',
        icon: Icons.format_list_numbered,
        category: 'basic',
        color: Colors.grey.shade700,
      ),
      InsertableWidget(
        id: 'checkbox',
        name: 'Checklist',
        description: 'To-do list with checkboxes',
        icon: Icons.check_box,
        category: 'basic',
        color: Colors.green,
      ),
      InsertableWidget(
        id: 'quote',
        name: 'Quote',
        description: 'Highlight a quote',
        icon: Icons.format_quote,
        category: 'basic',
        color: Colors.purple,
      ),
      InsertableWidget(
        id: 'code',
        name: 'Code Block',
        description: 'Code with syntax highlighting',
        icon: Icons.code,
        category: 'basic',
        color: Colors.orange,
      ),
      InsertableWidget(
        id: 'divider',
        name: 'Divider',
        description: 'Visual separator',
        icon: Icons.horizontal_rule,
        category: 'basic',
        color: Colors.grey,
      ),
      InsertableWidget(
        id: 'callout',
        name: 'Callout',
        description: 'Highlighted information',
        icon: Icons.campaign,
        category: 'basic',
        color: Colors.amber,
      ),
      InsertableWidget(
        id: 'table',
        name: 'Table',
        description: 'Insert a table',
        icon: Icons.table_chart,
        category: 'basic',
        color: Colors.teal,
      ),
      // Media
      InsertableWidget(
        id: 'image',
        name: 'Image',
        description: 'Upload or embed image',
        icon: Icons.image,
        category: 'media',
        color: Colors.pink,
      ),
      InsertableWidget(
        id: 'video',
        name: 'Video',
        description: 'Embed video file',
        icon: Icons.videocam,
        category: 'media',
        color: Colors.red,
      ),
      InsertableWidget(
        id: 'audio',
        name: 'Audio',
        description: 'Embed audio file',
        icon: Icons.audiotrack,
        category: 'media',
        color: Colors.deepPurple,
      ),
      InsertableWidget(
        id: 'file',
        name: 'File',
        description: 'Attach any file',
        icon: Icons.attach_file,
        category: 'media',
        color: Colors.blueGrey,
      ),
      // Embeds
      InsertableWidget(
        id: 'youtube',
        name: 'YouTube',
        description: 'Embed YouTube video',
        icon: Icons.play_circle_filled,
        category: 'embed',
        color: Colors.red,
      ),
      InsertableWidget(
        id: 'twitter',
        name: 'Twitter/X',
        description: 'Embed tweet',
        icon: Icons.chat_bubble,
        category: 'embed',
        color: Colors.lightBlue,
      ),
      InsertableWidget(
        id: 'maps',
        name: 'Google Maps',
        description: 'Embed location map',
        icon: Icons.map,
        category: 'embed',
        color: Colors.green,
      ),
      InsertableWidget(
        id: 'iframe',
        name: 'Web Embed',
        description: 'Embed any website',
        icon: Icons.web,
        category: 'embed',
        color: Colors.indigo,
      ),
      InsertableWidget(
        id: 'figma',
        name: 'Figma',
        description: 'Embed Figma design',
        icon: Icons.design_services,
        category: 'embed',
        color: Colors.purple,
      ),
      // Charts
      InsertableWidget(
        id: 'chart_bar',
        name: 'Bar Chart',
        description: 'Vertical bar chart',
        icon: Icons.bar_chart,
        category: 'chart',
        color: Colors.blue,
      ),
      InsertableWidget(
        id: 'chart_line',
        name: 'Line Chart',
        description: 'Line graph',
        icon: Icons.show_chart,
        category: 'chart',
        color: Colors.green,
      ),
      InsertableWidget(
        id: 'chart_pie',
        name: 'Pie Chart',
        description: 'Circular pie chart',
        icon: Icons.pie_chart,
        category: 'chart',
        color: Colors.orange,
      ),
      InsertableWidget(
        id: 'chart_area',
        name: 'Area Chart',
        description: 'Filled area graph',
        icon: Icons.area_chart,
        category: 'chart',
        color: Colors.purple,
      ),
      // Advanced
      InsertableWidget(
        id: 'math',
        name: 'Math Equation',
        description: 'LaTeX math formula',
        icon: Icons.functions,
        category: 'advanced',
        color: Colors.deepOrange,
      ),
      InsertableWidget(
        id: 'mermaid',
        name: 'Diagram',
        description: 'Flowchart/diagram',
        icon: Icons.account_tree,
        category: 'advanced',
        color: Colors.cyan,
      ),
      InsertableWidget(
        id: 'calendar',
        name: 'Calendar',
        description: 'Date picker/calendar',
        icon: Icons.calendar_month,
        category: 'advanced',
        color: Colors.red.shade400,
      ),
      InsertableWidget(
        id: 'kanban',
        name: 'Kanban Board',
        description: 'Task board',
        icon: Icons.view_column,
        category: 'advanced',
        color: Colors.deepPurple,
      ),
      InsertableWidget(
        id: 'button',
        name: 'Button',
        description: 'Interactive button',
        icon: Icons.smart_button,
        category: 'advanced',
        color: Colors.blue.shade600,
      ),
    ];

    var filtered = allWidgets;

    // Filter by category
    if (_selectedCategory != 'all') {
      filtered =
          filtered.where((w) => w.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((w) {
            return w.name.toLowerCase().contains(_searchQuery) ||
                w.description.toLowerCase().contains(_searchQuery);
          }).toList();
    }

    return filtered;
  }

  Widget _CategoryChip(String value, String label, IconData icon) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedCategory = value;
          });
        },
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  void _insertWidget(String widgetId) {
    if (widgetId == 'youtube') {
      _showYoutubeDialog();
    } else if (widgetId == 'image') {
      _showImageDialog();
    } else if (widgetId.startsWith('chart_')) {
      _showChartDialog(widgetId);
    } else if (widgetId == 'maps') {
      _showMapsDialog();
    } else if (widgetId == 'iframe') {
      _showIframeDialog();
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'YouTube URL',
                    hintText: 'https://www.youtube.com/watch?v=...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Paste the YouTube video URL',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
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
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.upload, color: Colors.blue),
                  ),
                  title: const Text('Upload from device'),
                  subtitle: const Text('Choose from gallery or camera'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image uploaded')),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.link, color: Colors.green),
                  ),
                  title: const Text('Insert from URL'),
                  subtitle: const Text('Paste image link'),
                  onTap: () {
                    Navigator.pop(context);
                    _showUrlDialog('Image', Icons.image);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showUrlDialog(String type, IconData icon) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text('Insert $type URL'),
              ],
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'URL',
                hintText: 'https://...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.link),
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
    final chartName = chartType.split('_').last;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Insert ${chartName.toUpperCase()} Chart'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A sample chart will be inserted. You can edit the data after insertion.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Double-click the chart to edit data',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                child: const Text('Insert Chart'),
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Location or Maps URL',
                    hintText: 'Enter address or Google Maps link',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
              ],
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

  void _showIframeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.web, color: Colors.indigo),
                SizedBox(width: 8),
                Text('Embed Website'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Website URL',
                    hintText: 'https://...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Embed any website as an iframe',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
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
                        .insert(index, '\n[Embed: ${controller.text}]\n');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Website embedded')),
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
  final String description;
  final IconData icon;
  final String category;
  final Color color;

  InsertableWidget({
    required this.id,
    required this.name,
    required this.description,
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                widget.name,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
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
