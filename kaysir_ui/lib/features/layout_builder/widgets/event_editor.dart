import 'package:flutter/material.dart';

class EventsEditor extends StatelessWidget {
  final Map<String, String> events;
  final ValueChanged<Map<String, String>> onEventsChanged;

  const EventsEditor({
    super.key,
    required this.events,
    required this.onEventsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sortedEntries =
        events.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Events',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (events.isNotEmpty)
              Chip(
                label: Text('${events.length}'),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (events.isEmpty) const _EmptyEventsHint(),
        if (events.isNotEmpty) ...[
          for (final entry in sortedEntries)
            _EventField(
              eventName: entry.key,
              handler: entry.value,
              events: events,
              onEventsChanged: onEventsChanged,
            ),
          const SizedBox(height: 4),
        ],
        _QuickEventPresets(events: events, onEventsChanged: onEventsChanged),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add event'),
            onPressed: () => _showAddEventDialog(context),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddEventDialog(BuildContext context) async {
    final nameController = TextEditingController(text: _firstAvailableEvent());
    final handlerController = TextEditingController(
      text: _handlerPresets.first.value,
    );

    try {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add event'),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: nameController.text,
                    decoration: const InputDecoration(
                      labelText: 'Common event',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final eventName in _commonEventNames)
                        DropdownMenuItem(
                          value: eventName,
                          child: Text(_eventLabel(eventName)),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) nameController.text = value;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Event name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: handlerController.text,
                    decoration: const InputDecoration(
                      labelText: 'Handler preset',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final preset in _handlerPresets)
                        DropdownMenuItem(
                          value: preset.value,
                          child: Text(preset.label),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) handlerController.text = value;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: handlerController,
                    decoration: const InputDecoration(
                      labelText: 'Handler',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final eventName = nameController.text.trim();
                  final handler = handlerController.text.trim();
                  if (eventName.isEmpty || handler.isEmpty) return;

                  final nextEvents = Map<String, String>.from(events);
                  nextEvents[eventName] = handler;
                  onEventsChanged(nextEvents);
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    } finally {
      nameController.dispose();
      handlerController.dispose();
    }
  }

  String _firstAvailableEvent() {
    for (final eventName in _commonEventNames) {
      if (!events.containsKey(eventName)) return eventName;
    }

    return 'onTap';
  }
}

class _EventField extends StatelessWidget {
  final String eventName;
  final String handler;
  final Map<String, String> events;
  final ValueChanged<Map<String, String>> onEventsChanged;

  const _EventField({
    required this.eventName,
    required this.handler,
    required this.events,
    required this.onEventsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final eventOptions =
        {
          ..._commonEventNames,
          if (!_commonEventNames.contains(eventName)) eventName,
        }.toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: eventName,
                      decoration: const InputDecoration(
                        labelText: 'Event',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final option in eventOptions)
                          DropdownMenuItem(
                            value: option,
                            child: Text(_eventLabel(option)),
                          ),
                      ],
                      onChanged: (value) => _renameEvent(value),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove event',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _removeEvent,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: handler,
                decoration: InputDecoration(
                  labelText: 'Handler',
                  isDense: true,
                  border: const OutlineInputBorder(),
                  suffixIcon: PopupMenuButton<String>(
                    tooltip: 'Handler presets',
                    icon: const Icon(Icons.bolt_outlined),
                    onSelected: _updateHandler,
                    itemBuilder:
                        (context) => [
                          for (final preset in _handlerPresets)
                            PopupMenuItem(
                              value: preset.value,
                              child: _HandlerPresetMenuItem(preset: preset),
                            ),
                        ],
                  ),
                ),
                onChanged: _updateHandler,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _renameEvent(String? nextName) {
    final normalized = nextName?.trim();
    if (normalized == null || normalized.isEmpty || normalized == eventName) {
      return;
    }

    final nextEvents = Map<String, String>.from(events);
    nextEvents.remove(eventName);
    nextEvents[normalized] = handler;
    onEventsChanged(nextEvents);
  }

  void _updateHandler(String value) {
    final nextEvents = Map<String, String>.from(events);
    nextEvents[eventName] = value.trim();
    onEventsChanged(nextEvents);
  }

  void _removeEvent() {
    final nextEvents = Map<String, String>.from(events);
    nextEvents.remove(eventName);
    onEventsChanged(nextEvents);
  }
}

class _QuickEventPresets extends StatelessWidget {
  final Map<String, String> events;
  final ValueChanged<Map<String, String>> onEventsChanged;

  const _QuickEventPresets({
    required this.events,
    required this.onEventsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final availablePresets = _eventPresets
        .where((preset) => !events.containsKey(preset.eventName))
        .toList(growable: false);

    if (availablePresets.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final preset in availablePresets)
          ActionChip(
            avatar: Icon(preset.icon, size: 18),
            label: Text(preset.label),
            onPressed: () => _applyPreset(preset),
          ),
      ],
    );
  }

  void _applyPreset(_EventPreset preset) {
    final nextEvents = Map<String, String>.from(events);
    nextEvents[preset.eventName] = preset.handler;
    onEventsChanged(nextEvents);
  }
}

class _EmptyEventsHint extends StatelessWidget {
  const _EmptyEventsHint();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(Icons.bolt_outlined, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Add an event to document how this component should behave in POS flows.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HandlerPresetMenuItem extends StatelessWidget {
  final _HandlerPreset preset;

  const _HandlerPresetMenuItem({required this.preset});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(preset.icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(preset.label)),
      ],
    );
  }
}

class _EventPreset {
  final String label;
  final String eventName;
  final String handler;
  final IconData icon;

  const _EventPreset({
    required this.label,
    required this.eventName,
    required this.handler,
    required this.icon,
  });
}

class _HandlerPreset {
  final String label;
  final String value;
  final IconData icon;

  const _HandlerPreset({
    required this.label,
    required this.value,
    required this.icon,
  });
}

const _commonEventNames = [
  'onTap',
  'onLongPress',
  'onSubmit',
  'onFocus',
  'onValueChanged',
];

const _eventPresets = [
  _EventPreset(
    label: 'Pay',
    eventName: 'onTap',
    handler: 'pos.pay',
    icon: Icons.payments_outlined,
  ),
  _EventPreset(
    label: 'Discount',
    eventName: 'onLongPress',
    handler: 'pos.discount.open',
    icon: Icons.discount_outlined,
  ),
  _EventPreset(
    label: 'Print',
    eventName: 'onSubmit',
    handler: 'pos.receipt.print',
    icon: Icons.print_outlined,
  ),
];

const _handlerPresets = [
  _HandlerPreset(
    label: 'Add selected product',
    value: 'pos.product.add',
    icon: Icons.add_shopping_cart_outlined,
  ),
  _HandlerPreset(
    label: 'Open payment',
    value: 'pos.pay',
    icon: Icons.payments_outlined,
  ),
  _HandlerPreset(
    label: 'Open discount',
    value: 'pos.discount.open',
    icon: Icons.discount_outlined,
  ),
  _HandlerPreset(
    label: 'Void order',
    value: 'pos.order.void',
    icon: Icons.block_outlined,
  ),
  _HandlerPreset(
    label: 'Print receipt',
    value: 'pos.receipt.print',
    icon: Icons.print_outlined,
  ),
  _HandlerPreset(
    label: 'Clear input',
    value: 'pos.input.clear',
    icon: Icons.backspace_outlined,
  ),
  _HandlerPreset(
    label: 'Open customer picker',
    value: 'pos.customer.select',
    icon: Icons.person_search_outlined,
  ),
];

String _eventLabel(String eventName) {
  switch (eventName) {
    case 'onTap':
      return 'Tap';
    case 'onLongPress':
      return 'Long press';
    case 'onSubmit':
      return 'Submit';
    case 'onFocus':
      return 'Focus';
    case 'onValueChanged':
      return 'Value changed';
    default:
      return eventName;
  }
}
