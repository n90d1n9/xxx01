import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/cell/cell_address.dart';
import '../model/cell/cell_data.dart';
import '../model/cell/cell_validation.dart';
import '../state/spreadsheet_provider.dart';

class QuickActionsSheet extends ConsumerWidget {
  const QuickActionsSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.comment),
            title: const Text('Add Comment'),
            onTap: () {
              Navigator.pop(context);
              _addComment(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Insert Hyperlink'),
            onTap: () {
              Navigator.pop(context);
              _addHyperlink(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_box),
            title: const Text('Data Validation'),
            onTap: () {
              Navigator.pop(context);
              _addValidation(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.format_paint),
            title: const Text('Format Painter'),
            onTap: () {
              Navigator.pop(context);
              _formatPainter(ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.functions),
            title: const Text('Insert Chart'),
            onTap: () {
              Navigator.pop(context);
              _showMessage(context, 'Chart feature coming soon');
            },
          ),
        ],
      ),
    );
  }

  void _addComment(BuildContext context, WidgetRef ref) {
    final selection = ref.read(selectedCellProvider);
    if (selection == null) return;

    showDialog(
      context: context,
      builder: (context) => _CommentDialog(address: selection.start),
    );
  }

  void _addHyperlink(BuildContext context, WidgetRef ref) {
    final selection = ref.read(selectedCellProvider);
    if (selection == null) return;

    showDialog(
      context: context,
      builder: (context) => _HyperlinkDialog(address: selection.start),
    );
  }

  void _addValidation(BuildContext context, WidgetRef ref) {
    final selection = ref.read(selectedCellProvider);
    if (selection == null) return;

    showDialog(
      context: context,
      builder: (context) => _ValidationDialog(address: selection.start),
    );
  }

  void _formatPainter(WidgetRef ref) {
    final selection = ref.read(selectedCellProvider);
    if (selection == null) return;

    final data = ref.read(spreadsheetProvider);
    final sourceStyle = data[selection.start]?.style;
    if (sourceStyle != null) {
      ref.read(clipboardProvider.notifier).state = {
        CellAddress(0, 0): CellData(style: sourceStyle),
      };
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CommentDialog extends ConsumerStatefulWidget {
  final CellAddress address;

  const _CommentDialog({required this.address});

  @override
  ConsumerState<_CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends ConsumerState<_CommentDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final data = ref.read(spreadsheetProvider);
    _controller.text = data[widget.address]?.comment ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Comment for ${widget.address.label}'),
      content: TextField(
        controller: _controller,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: 'Enter comment',
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
            final data = ref.read(spreadsheetProvider);
            final current = data[widget.address] ?? CellData();
            ref
                .read(spreadsheetProvider.notifier)
                .updateCell(
                  widget.address,
                  current.copyWith(comment: _controller.text),
                );
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _HyperlinkDialog extends ConsumerStatefulWidget {
  final CellAddress address;

  const _HyperlinkDialog({required this.address});

  @override
  ConsumerState<_HyperlinkDialog> createState() => _HyperlinkDialogState();
}

class _HyperlinkDialogState extends ConsumerState<_HyperlinkDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final data = ref.read(spreadsheetProvider);
    _controller.text = data[widget.address]?.hyperlink ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Hyperlink for ${widget.address.label}'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'https://example.com',
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
            final data = ref.read(spreadsheetProvider);
            final current = data[widget.address] ?? CellData();
            ref
                .read(spreadsheetProvider.notifier)
                .updateCell(
                  widget.address,
                  current.copyWith(hyperlink: _controller.text),
                );
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ValidationDialog extends ConsumerStatefulWidget {
  final CellAddress address;

  const _ValidationDialog({required this.address});

  @override
  ConsumerState<_ValidationDialog> createState() => _ValidationDialogState();
}

class _ValidationDialogState extends ConsumerState<_ValidationDialog> {
  ValidationType _type = ValidationType.none;
  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  final _optionsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Data Validation for ${widget.address.label}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<ValidationType>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Validation Type'),
            items: ValidationType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) => setState(() => _type = value!),
          ),
          if (_type == ValidationType.number) ...[
            TextField(
              controller: _minController,
              decoration: const InputDecoration(labelText: 'Min Value'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _maxController,
              decoration: const InputDecoration(labelText: 'Max Value'),
              keyboardType: TextInputType.number,
            ),
          ],
          if (_type == ValidationType.list)
            TextField(
              controller: _optionsController,
              decoration: const InputDecoration(
                labelText: 'Options (comma-separated)',
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
            final validation = CellValidation(
              type: _type,
              min: _minController.text.isEmpty ? null : _minController.text,
              max: _maxController.text.isEmpty ? null : _maxController.text,
              options: _type == ValidationType.list
                  ? _optionsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .toList()
                  : null,
            );

            final data = ref.read(spreadsheetProvider);
            final current = data[widget.address] ?? CellData();
            ref
                .read(spreadsheetProvider.notifier)
                .updateCell(
                  widget.address,
                  current.copyWith(validation: validation),
                );
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _optionsController.dispose();
    super.dispose();
  }
}
