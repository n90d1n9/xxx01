import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/component_template_list.dart';
import '../models/component_template.dart';
import '../schema/component_category.dart';
import 'component_detail_dialog.dart';

class ComponentPalette extends ConsumerStatefulWidget {
  const ComponentPalette({super.key});

  @override
  ConsumerState<ComponentPalette> createState() => _ComponentPaletteState();
}

class _ComponentPaletteState extends ConsumerState<ComponentPalette> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredComponents = _getFilteredComponents();

    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: theme.dividerColor)),
        color: theme.cardColor,
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          _buildSearchBar(theme),
          _buildCategoryTabs(theme),
          Expanded(child: _buildComponentList(filteredComponents, theme)),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Icon(Icons.widgets, color: theme.primaryColor),
          const SizedBox(width: 8),
          Text(
            'Components',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search components...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildCategoryTabs(ThemeData theme) {
    final categories = ComponentCategories.getCategories();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip('All', null, theme);
          }
          final category = categories[index - 1];
          return _buildCategoryChip(category.name, category.id, theme);
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? categoryId, ThemeData theme) {
    final isSelected = _selectedCategory == categoryId;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = selected ? categoryId : null);
        },
        selectedColor: theme.primaryColor.withOpacity(0.2),
      ),
    );
  }

  Widget _buildComponentList(
    List<ComponentTemplate> components,
    ThemeData theme,
  ) {
    if (components.isEmpty) {
      return Center(
        child: Text(
          'No components found',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.disabledColor,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: components.length,
      itemBuilder: (context, index) {
        return _buildComponentCard(components[index], theme);
      },
    );
  }

  Widget _buildComponentCard(ComponentTemplate component, ThemeData theme) {
    return Draggable<ComponentTemplate>(
      data: component,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: component.color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(component.icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  component.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCard(component, theme),
      ),
      child: _buildCard(component, theme),
    );
  }

  Widget _buildCard(ComponentTemplate component, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showComponentDetails(component),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: component.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      component.icon,
                      color: component.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          component.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (component.eipPattern != null)
                          Text(
                            component.eipPattern!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.disabledColor,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (component.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  component.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.disabledColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<ComponentTemplate> _getFilteredComponents() {
    var components = ComponentTemplates.getAllComponents();

    if (_selectedCategory != null) {
      components =
          components.where((c) => c.categoryId == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      components =
          components.where((c) {
            return c.name.toLowerCase().contains(query) ||
                c.description.toLowerCase().contains(query) ||
                (c.eipPattern?.toLowerCase().contains(query) ?? false);
          }).toList();
    }

    return components;
  }

  void _showComponentDetails(ComponentTemplate component) {
    showDialog(
      context: context,
      builder: (context) => ComponentDetailsDialog(component: component),
    );
  }
}
