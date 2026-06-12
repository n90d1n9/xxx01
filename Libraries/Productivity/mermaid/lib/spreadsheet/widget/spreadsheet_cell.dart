import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/cell/cell_address.dart';
import '../model/cell/cell_data.dart';
import '../model/cell/cell_selection.dart';
import '../state/spreadsheet_provider.dart';

class SpreadsheetCell extends ConsumerWidget {
  final CellAddress address;

  const SpreadsheetCell({super.key, required this.address});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(spreadsheetProvider);
    final selection = ref.watch(selectedCellProvider);
    final cellData = data[address] ?? CellData();

    final isSelected =
        selection != null &&
        selection.getCells().any((addr) => addr == address);
    final isRangeStart = selection?.start == address;

    final hasComment = cellData.comment != null && cellData.comment!.isNotEmpty;
    final hasHyperlink =
        cellData.hyperlink != null && cellData.hyperlink!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        ref.read(selectedCellProvider.notifier).state = CellSelection(address);
      },
      onDoubleTap: () {
        _showEditDialog(context, ref);
      },
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.1)
              : (cellData.style.backgroundColor ?? Colors.white),
          border: Border.all(
            color: isRangeStart
                ? Colors.blue
                : (isSelected
                      ? Colors.blue.withOpacity(0.5)
                      : Colors.grey[400]!),
            width: isRangeStart ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        alignment: _getAlignment(cellData.style.align),
        child: Stack(
          children: [
            Text(
              cellData.value,
              style: TextStyle(
                fontWeight: cellData.style.bold
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontStyle: cellData.style.italic
                    ? FontStyle.italic
                    : FontStyle.normal,
                decoration: cellData.style.underline
                    ? TextDecoration.underline
                    : null,
                color: hasHyperlink ? Colors.blue : cellData.style.textColor,
                fontSize: cellData.style.fontSize,
                fontFamily: cellData.style.fontFamily,
              ),
              overflow: cellData.style.wrapText
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              maxLines: cellData.style.wrapText ? null : 1,
            ),
            if (hasComment)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.comment, size: 12, color: Colors.orange[700]),
              ),
          ],
        ),
      ),
    );
  }

  Alignment _getAlignment(TextAlign align) {
    switch (align) {
      case TextAlign.left:
        return Alignment.centerLeft;
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.right:
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final data = ref.read(spreadsheetProvider);
    final cellData = data[address] ?? CellData();
    final controller = TextEditingController(
      text: cellData.formula ?? cellData.value,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Cell ${address.label}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Enter value or formula',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onSubmitted: (value) {
                ref
                    .read(spreadsheetProvider.notifier)
                    .updateCellValue(address, value);
                Navigator.pop(context);
              },
            ),
            if (cellData.comment != null && cellData.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  border: Border.all(color: Colors.orange[200]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.comment, size: 16, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cellData.comment!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(spreadsheetProvider.notifier)
                  .updateCellValue(address, controller.text);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
