import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component_type.dart';
import '../services/designer_service.dart';
import '../states/provider.dart';

class ComponentPalette extends ConsumerStatefulWidget {
  const ComponentPalette({super.key});

  @override
  ConsumerState<ComponentPalette> createState() => _ComponentPaletteState();
}

class _ComponentPaletteState extends ConsumerState<ComponentPalette> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final Map<String, List<Map<String, dynamic>>> _categories = {
    'Layout': [
      {
        'type': ComponentType.container,
        'icon': Icons.crop_square,
        'label': 'Container',
      },
      {
        'type': ComponentType.column,
        'icon': Icons.view_column,
        'label': 'Column',
      },
      {'type': ComponentType.row, 'icon': Icons.view_week, 'label': 'Row'},
      {'type': ComponentType.stack, 'icon': Icons.layers, 'label': 'Stack'},
    ],
    'Modern UI': [
      {
        'type': ComponentType.hero,
        'icon': Icons.photo_size_select_large,
        'label': 'Hero',
      },
      {
        'type': ComponentType.glassmorphism,
        'icon': Icons.blur_on,
        'label': 'Glassmorphism',
      },
      {
        'type': ComponentType.neumorphism,
        'icon': Icons.circle,
        'label': 'Neumorphism',
      },
      {'type': ComponentType.card, 'icon': Icons.credit_card, 'label': 'Card'},
      {'type': ComponentType.chip, 'icon': Icons.label, 'label': 'Chip'},
      {
        'type': ComponentType.badge,
        'icon': Icons.notifications,
        'label': 'Badge',
      },
    ],
    'Forms': [
      {'type': ComponentType.text, 'icon': Icons.text_fields, 'label': 'Text'},
      {
        'type': ComponentType.button,
        'icon': Icons.smart_button,
        'label': 'Button',
      },
      {'type': ComponentType.input, 'icon': Icons.input, 'label': 'Input'},
      {
        'type': ComponentType.checkbox,
        'icon': Icons.check_box,
        'label': 'Checkbox',
      },
      {'type': ComponentType.slider, 'icon': Icons.tune, 'label': 'Slider'},
      {
        'type': ComponentType.dropdown,
        'icon': Icons.arrow_drop_down_circle,
        'label': 'Dropdown',
      },
    ],
    'Media': [
      {'type': ComponentType.image, 'icon': Icons.image, 'label': 'Image'},
      {'type': ComponentType.video, 'icon': Icons.videocam, 'label': 'Video'},
      {
        'type': ComponentType.imageCarousel,
        'icon': Icons.view_carousel,
        'label': 'Carousel',
      },
      {'type': ComponentType.qrCode, 'icon': Icons.qr_code, 'label': 'QR Code'},
    ],
    'Data': [
      {
        'type': ComponentType.dataTable,
        'icon': Icons.table_chart,
        'label': 'Table',
      },
      {'type': ComponentType.chart, 'icon': Icons.bar_chart, 'label': 'Chart'},
      {
        'type': ComponentType.timeline,
        'icon': Icons.timeline,
        'label': 'Timeline',
      },
      {
        'type': ComponentType.progressBar,
        'icon': Icons.linear_scale,
        'label': 'Progress',
      },
    ],
    'E-commerce': [
      {
        'type': ComponentType.productCard,
        'icon': Icons.shopping_bag,
        'label': 'Product Card',
      },
      {
        'type': ComponentType.priceTag,
        'icon': Icons.sell,
        'label': 'Price Tag',
      },
      {'type': ComponentType.rating, 'icon': Icons.star, 'label': 'Rating'},
      {
        'type': ComponentType.addToCart,
        'icon': Icons.add_shopping_cart,
        'label': 'Add to Cart',
      },
    ],
    'Effects': [
      {
        'type': ComponentType.shimmer,
        'icon': Icons.auto_awesome,
        'label': 'Shimmer',
      },
      {
        'type': ComponentType.particles,
        'icon': Icons.blur_circular,
        'label': 'Particles',
      },
      {
        'type': ComponentType.gradient,
        'icon': Icons.gradient,
        'label': 'Gradient',
      },
      {'type': ComponentType.blur, 'icon': Icons.blur_on, 'label': 'Blur'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(designerProvider);
    final notifier = ref.read(designerProvider.notifier);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: state.isDarkMode ? Colors.grey.shade900 : Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search components...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged:
                  (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children:
                  ['All', ..._categories.keys].map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat, style: const TextStyle(fontSize: 12)),
                        selected: isSelected,
                        onSelected:
                            (selected) =>
                                setState(() => _selectedCategory = cat),
                      ),
                    );
                  }).toList(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _getFilteredComponents(notifier),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getFilteredComponents(DesignerNotifier notifier) {
    final List<Widget> widgets = [];

    _categories.forEach((category, items) {
      if (_selectedCategory != 'All' && _selectedCategory != category) return;

      final filtered =
          items.where((item) {
            if (_searchQuery.isEmpty) return true;
            return (item['label'] as String).toLowerCase().contains(
              _searchQuery,
            );
          }).toList();

      if (filtered.isEmpty) return;

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
      );

      widgets.addAll(
        filtered.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  size: 20,
                  color: Colors.blue,
                ),
              ),
              title: Text(
                item['label'] as String,
                style: const TextStyle(fontSize: 13),
              ),
              trailing: const Icon(Icons.add_circle_outline, size: 20),
              onTap: () => notifier.addComponent(item['type'] as ComponentType),
            ),
          ),
        ),
      );
    });

    return widgets;
  }
}
