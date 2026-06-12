import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/dashboard_item.dart';
import '../states/dashboard_provider.dart';
import '../widgets/chart_form.dart';
import '../widgets/stat_form.dart';

class DashboardBuilder extends ConsumerStatefulWidget {
  final DashboardItem? initialItem;

  const DashboardBuilder({super.key, this.initialItem});

  @override
  ConsumerState<DashboardBuilder> createState() => _DashboardBuilderState();
}

class _DashboardBuilderState extends ConsumerState<DashboardBuilder> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late DashboardItemType _selectedType;
  late Map<String, dynamic> _formData;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _title = widget.initialItem?.title ?? '';
    _selectedType = widget.initialItem?.type ?? DashboardItemType.lineChart;
    _formData = widget.initialItem?.data ?? {};
    _isEditing = widget.initialItem != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Dashboard Item' : 'Add Dashboard Item'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _confirmDelete();
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  hintText: 'Enter a title for this item',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              Text('Item Type', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<DashboardItemType>(
                segments: const [
                  ButtonSegment(
                    value: DashboardItemType.lineChart,
                    icon: Icon(Icons.show_chart),
                    label: Text('Line Chart'),
                  ),
                  ButtonSegment(
                    value: DashboardItemType.barChart,
                    icon: Icon(Icons.bar_chart),
                    label: Text('Bar Chart'),
                  ),
                  ButtonSegment(
                    value: DashboardItemType.pieChart,
                    icon: Icon(Icons.pie_chart),
                    label: Text('Pie Chart'),
                  ),
                  ButtonSegment(
                    value: DashboardItemType.statCard,
                    icon: Icon(Icons.dashboard),
                    label: Text('Stat Card'),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<DashboardItemType> selected) {
                  setState(() {
                    _selectedType = selected.first;
                    // Reset form data when changing type
                    if (!_isEditing) {
                      _formData = {};
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
              _buildFormForType(),
              const SizedBox(height: 24),
              Center(
                child: FilledButton.icon(
                  icon: Icon(_isEditing ? Icons.save : Icons.add),
                  label: Text(_isEditing ? 'Save Changes' : 'Add to Dashboard'),
                  onPressed: _saveItem,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormForType() {
    switch (_selectedType) {
      case DashboardItemType.lineChart:
      case DashboardItemType.barChart:
        return ChartForm(
          type: _selectedType,
          initialData: _formData,
          onDataChanged: (data) {
            _formData = data;
          },
        );
      case DashboardItemType.pieChart:
        return ChartForm(
          type: _selectedType,
          initialData: _formData,
          onDataChanged: (data) {
            _formData = data;
          },
        );
      case DashboardItemType.statCard:
        return StatForm(
          initialData: _formData,
          onDataChanged: (data) {
            _formData = data;
          },
        );
      default:
        return const Text('Unknown item type');
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_isEditing && widget.initialItem != null) {
        final updatedItem = widget.initialItem!.copyWith(
          title: _title,
          type: _selectedType,
          data: _formData,
        );
        ref.read(dashboardItemsProvider.notifier).updateItem(updatedItem);
      } else {
        ref
            .read(dashboardItemsProvider.notifier)
            .addItem(_title, _selectedType, _formData);
      }

      Navigator.pop(context);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text(
          'Are you sure you want to delete this dashboard item?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.initialItem != null) {
                ref
                    .read(dashboardItemsProvider.notifier)
                    .removeItem(widget.initialItem!.id);
                Navigator.pop(context);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
