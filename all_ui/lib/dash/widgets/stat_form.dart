import 'package:flutter/material.dart';

class StatForm extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const StatForm({
    super.key,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<StatForm> createState() => _StatFormState();
}

class _StatFormState extends State<StatForm> {
  late Map<String, dynamic> _statData;
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _changeController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  bool _isPositive = true;
  String _selectedIcon = 'trending_up';

  @override
  void initState() {
    super.initState();
    _statData = Map<String, dynamic>.from(widget.initialData);

    _valueController.text = _statData['value'] ?? '0';
    _changeController.text = _statData['change'] ?? '0%';
    _subtitleController.text = _statData['subtitle'] ?? 'vs last period';
    _isPositive = _statData['isPositive'] ?? true;
    _selectedIcon = _statData['icon'] ?? 'trending_up';
  }

  void _updateStatData() {
    _statData = {
      'value': _valueController.text,
      'change': _changeController.text,
      'isPositive': _isPositive,
      'icon': _selectedIcon,
      'subtitle': _subtitleController.text,
    };
    widget.onDataChanged(_statData);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _valueController,
          decoration: const InputDecoration(
            labelText: 'Value',
            border: OutlineInputBorder(),
            hintText: 'e.g. 2,451',
          ),
          onChanged: (value) {
            _updateStatData();
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _changeController,
                decoration: const InputDecoration(
                  labelText: 'Change',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 15.3%',
                ),
                onChanged: (value) {
                  _updateStatData();
                },
              ),
            ),
            const SizedBox(width: 16),
            ToggleButtons(
              isSelected: [_isPositive, !_isPositive],
              onPressed: (index) {
                setState(() {
                  _isPositive = index == 0;
                  _updateStatData();
                });
              },
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward, color: Colors.green),
                      SizedBox(width: 4),
                      Text('Up', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_downward, color: Colors.red),
                      SizedBox(width: 4),
                      Text('Down', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _subtitleController,
          decoration: const InputDecoration(
            labelText: 'Subtitle',
            border: OutlineInputBorder(),
            hintText: 'e.g. vs last month',
          ),
          onChanged: (value) {
            _updateStatData();
          },
        ),
        const SizedBox(height: 16),
        Text('Icon', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildIconOption('trending_up', Icons.trending_up),
            _buildIconOption('people', Icons.people),
            _buildIconOption('money', Icons.attach_money),
            _buildIconOption('shopping', Icons.shopping_cart),
            _buildIconOption('analytics', Icons.analytics),
          ],
        ),
      ],
    );
  }

  Widget _buildIconOption(String value, IconData icon) {
    final isSelected = _selectedIcon == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIcon = value;
          _updateStatData();
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border:
              isSelected
                  ? Border.all(color: Theme.of(context).colorScheme.primary)
                  : null,
        ),
        child: Icon(
          icon,
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    _changeController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }
}
