import 'package:flutter/material.dart';

import '../models/dashboard_item.dart';

class ChartForm extends StatefulWidget {
  final DashboardItemType type;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const ChartForm({
    super.key,
    required this.type,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<ChartForm> createState() => _ChartFormState();
}

class _ChartFormState extends State<ChartForm> {
  late Map<String, dynamic> _chartData;
  List<String> _labels = [];
  List<Map<String, dynamic>> _datasets = [];

  @override
  void initState() {
    super.initState();
    _chartData = Map<String, dynamic>.from(widget.initialData);

    // Initialize labels
    _labels = List<String>.from(_chartData['labels'] ?? []);
    if (_labels.isEmpty && widget.type != DashboardItemType.pieChart) {
      _labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    }

    // Initialize datasets
    if (_chartData['datasets'] != null) {
      _datasets = List<Map<String, dynamic>>.from(_chartData['datasets']);
    } else {
      if (widget.type == DashboardItemType.lineChart ||
          widget.type == DashboardItemType.barChart) {
        _datasets = [
          {
            'label': 'Series 1',
            'data': [10, 15, 20, 25, 30, 35],
            'color': 0xFF4CAF50,
          },
        ];
      } else if (widget.type == DashboardItemType.pieChart) {
        _datasets = [
          {
            'data': [30, 25, 15, 20, 10],
            'colors': [
              0xFF4CAF50,
              0xFF2196F3,
              0xFFFFC107,
              0xFFFF5722,
              0xFF9E9E9E,
            ],
            'labels': [
              'Segment 1',
              'Segment 2',
              'Segment 3',
              'Segment 4',
              'Segment 5',
            ],
          },
        ];
      }
    }

    _updateChartData();
  }

  void _updateChartData() {
    if (widget.type == DashboardItemType.pieChart) {
      _chartData = {'datasets': _datasets};
    } else {
      _chartData = {'labels': _labels, 'datasets': _datasets};
    }
    widget.onDataChanged(_chartData);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == DashboardItemType.pieChart) {
      return _buildPieChartForm();
    } else {
      return _buildChartForm();
    }
  }

  Widget _buildChartForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Labels', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _buildLabelEditor(),
        const SizedBox(height: 16),
        Text('Datasets', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ..._buildDatasetEditors(),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Series'),
            onPressed: _addDataset,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartForm() {
    // Pie charts have a single dataset with data, colors, and labels
    final dataset =
        _datasets.isNotEmpty
            ? _datasets[0]
            : {
              'data': [30, 25, 15, 20, 10],
              'colors': [
                0xFF4CAF50,
                0xFF2196F3,
                0xFFFFC107,
                0xFFFF5722,
                0xFF9E9E9E,
              ],
              'labels': [
                'Segment 1',
                'Segment 2',
                'Segment 3',
                'Segment 4',
                'Segment 5',
              ],
            };

    final data = List<double>.from(dataset['data'] ?? []);
    final colors = List<int>.from(dataset['colors'] ?? []);
    final labels = List<String>.from(dataset['labels'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pie Chart Segments',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...List.generate(data.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: labels[index],
                    decoration: InputDecoration(
                      labelText: 'Label ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        labels[index] = value;
                        dataset['labels'] = labels;
                        _updateChartData();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: data[index].toString(),
                    decoration: InputDecoration(
                      labelText: 'Value ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        data[index] = double.tryParse(value) ?? 0;
                        dataset['data'] = data;
                        _updateChartData();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(colors[index]),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      data.removeAt(index);
                      colors.removeAt(index);
                      labels.removeAt(index);
                      dataset['data'] = data;
                      dataset['colors'] = colors;
                      dataset['labels'] = labels;
                      _updateChartData();
                    });
                  },
                ),
              ],
            ),
          );
        }),
        Center(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Segment'),
            onPressed: () {
              setState(() {
                data.add(10);
                colors.add(0xFF9E9E9E);
                labels.add('New Segment');
                dataset['data'] = data;
                dataset['colors'] = colors;
                dataset['labels'] = labels;
                _datasets = [dataset];
                _updateChartData();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLabelEditor() {
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(text: _labels.join(', ')),
                    decoration: const InputDecoration(
                      labelText: 'X-Axis Labels (comma-separated)',
                      border: OutlineInputBorder(),
                      hintText: 'Jan, Feb, Mar, Apr...',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _labels =
                            value.split(',').map((e) => e.trim()).toList();
                        _updateChartData();
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDatasetEditors() {
    return List.generate(_datasets.length, (index) {
      final dataset = _datasets[index];
      final label = dataset['label'] ?? 'Series ${index + 1}';
      final data = List<double>.from(dataset['data'] ?? []);
      final color = Color(dataset['color'] as int? ?? 0xFF4CAF50);

      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 0,
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Series ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _datasets.removeAt(index);
                        _updateChartData();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      initialValue: label,
                      decoration: const InputDecoration(
                        labelText: 'Series Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          dataset['label'] = value;
                          _updateChartData();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: data.join(', '),
                decoration: const InputDecoration(
                  labelText: 'Values (comma-separated)',
                  border: OutlineInputBorder(),
                  hintText: '10, 15, 20, 25, 30...',
                ),
                onChanged: (value) {
                  setState(() {
                    dataset['data'] =
                        value
                            .split(',')
                            .map((e) => double.tryParse(e.trim()) ?? 0)
                            .toList();
                    _updateChartData();
                  });
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  void _addDataset() {
    setState(() {
      _datasets.add({
        'label': 'New Series',
        'data': List.generate(_labels.length, (index) => 0.0),
        'color': 0xFF2196F3,
      });
      _updateChartData();
    });
  }
}
