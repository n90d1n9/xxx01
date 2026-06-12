import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../state/spreadsheet_provider.dart';

class FormulaBar extends ConsumerStatefulWidget {
  const FormulaBar({super.key});

  @override
  ConsumerState<FormulaBar> createState() => _FormulaBarState();
}

class _FormulaBarState extends ConsumerState<FormulaBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(selectedCellProvider);
    final data = ref.watch(spreadsheetProvider);

    final cellData = selection != null ? data[selection.start] : null;
    final displayValue = cellData?.formula ?? cellData?.value ?? '';

    if (_controller.text != displayValue && !_focusNode.hasFocus) {
      _controller.text = displayValue;
      _controller.selection = TextSelection.collapsed(
        offset: displayValue.length,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[50],
            ),
            child: Text(
              selection?.start.label ?? '',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Enter value or formula (e.g., =SUM(A1:A10))',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
              onSubmitted: (value) {
                if (selection != null) {
                  ref
                      .read(spreadsheetProvider.notifier)
                      .updateCellValue(selection.start, value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
