import 'package:flutter/material.dart';

import '../../models/option.dart';

class ChoiceOptionsEditor extends StatefulWidget {
  final List<Option> options;
  final ValueChanged<Option> onOptionChanged;
  final ValueChanged<Option> onOptionRemoved;
  final VoidCallback onOptionAdded;

  const ChoiceOptionsEditor({
    super.key,
    required this.options,
    required this.onOptionChanged,
    required this.onOptionRemoved,
    required this.onOptionAdded,
  });

  @override
  State<ChoiceOptionsEditor> createState() => _ChoiceOptionsEditorState();
}

class _ChoiceOptionsEditorState extends State<ChoiceOptionsEditor> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant ChoiceOptionsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.options.map(_buildOptionRow),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Option'),
          onPressed: widget.onOptionAdded,
        ),
      ],
    );
  }

  Widget _buildOptionRow(Option option) {
    return Padding(
      key: ValueKey(option.id),
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controllers[option.id],
              decoration: const InputDecoration(
                labelText: 'Option',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                widget.onOptionChanged(option.copyWith(text: value));
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Remove option',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => widget.onOptionRemoved(option),
          ),
        ],
      ),
    );
  }

  void _syncControllers() {
    final optionIds = widget.options.map((option) => option.id).toSet();
    final staleIds = _controllers.keys
        .where((controllerId) => !optionIds.contains(controllerId))
        .toList();

    for (final staleId in staleIds) {
      _controllers.remove(staleId)?.dispose();
    }

    for (final option in widget.options) {
      final controller = _controllers.putIfAbsent(
        option.id,
        () => TextEditingController(text: option.text),
      );

      if (controller.text != option.text) {
        controller.value = controller.value.copyWith(
          text: option.text,
          selection: TextSelection.collapsed(offset: option.text.length),
          composing: TextRange.empty,
        );
      }
    }
  }
}
