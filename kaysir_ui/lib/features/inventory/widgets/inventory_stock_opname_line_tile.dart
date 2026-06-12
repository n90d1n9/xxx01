import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_stock_opname_session.dart';
import 'inventory_stock_opname_count_stepper.dart';
import 'inventory_stock_opname_line_identity.dart';
import 'inventory_stock_opname_line_layout.dart';
import 'inventory_stock_opname_line_match_action.dart';
import 'inventory_stock_opname_line_notes_field.dart';
import 'inventory_stock_opname_line_tone.dart';
import 'inventory_tile_surface.dart';
import 'stock_opname_line_input_controllers.dart';
import 'stock_opname_line_preview_data.dart';
import 'stock_opname_variance_pill.dart';

/// Editable worksheet row for one stock opname count line.
class InventoryStockOpnameLineTile extends StatefulWidget {
  const InventoryStockOpnameLineTile({
    super.key,
    required this.line,
    this.onActualQuantityChanged,
    this.onNotesChanged,
    this.onMatchSystem,
  });

  final InventoryStockOpnameLine line;
  final ValueChanged<String>? onActualQuantityChanged;
  final ValueChanged<String>? onNotesChanged;
  final VoidCallback? onMatchSystem;

  @override
  State<InventoryStockOpnameLineTile> createState() =>
      _InventoryStockOpnameLineTileState();
}

/// Keeps visible stock opname row inputs synchronized with line model updates.
class _InventoryStockOpnameLineTileState
    extends State<InventoryStockOpnameLineTile> {
  late final InventoryStockOpnameLineInputControllers _controllers;
  bool _controllerSyncScheduled = false;
  bool _syncActualQuantityPending = false;
  bool _syncNotesPending = false;

  @override
  void initState() {
    super.initState();
    _controllers = InventoryStockOpnameLineInputControllers.fromLine(
      widget.line,
    );
  }

  @override
  void didUpdateWidget(covariant InventoryStockOpnameLineTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final lineChanged = oldWidget.line.id != widget.line.id;
    _scheduleControllerSync(
      syncActualQuantity:
          lineChanged ||
          oldWidget.line.actualQuantity != widget.line.actualQuantity,
      syncNotes: lineChanged || oldWidget.line.notes != widget.line.notes,
    );
  }

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tone = inventoryStockOpnameLineTone(context, widget.line);
    final details = InventoryStockOpnameLineIdentity(
      line: widget.line,
      tone: tone,
    );
    final actualField = InventoryStockOpnameCountStepper(
      fieldKey: ValueKey('stock-opname-actual-${widget.line.id}'),
      controller: _controllers.actualQuantityController,
      value: widget.line.actualQuantity,
      productName: widget.line.productName,
      onChanged: widget.onActualQuantityChanged,
    );
    final notesField = InventoryStockOpnameLineNotesField(
      controller: _controllers.notesController,
      lineId: widget.line.id,
      onChanged: widget.onNotesChanged,
    );
    final variance = InventoryStockOpnameVariancePill(line: widget.line);
    final actions = InventoryStockOpnameLineMatchAction(
      productName: widget.line.productName,
      hasVariance: widget.line.discrepancy != 0,
      onPressed: widget.onMatchSystem,
    );

    return InventoryTileSurface(
      backgroundColor: tone.backgroundColor,
      borderColor: tone.borderColor,
      child: InventoryStockOpnameLineLayout(
        identity: details,
        actualField: actualField,
        notesField: notesField,
        variance: variance,
        action: actions,
      ),
    );
  }

  void _scheduleControllerSync({
    required bool syncActualQuantity,
    required bool syncNotes,
  }) {
    if (!syncActualQuantity && !syncNotes) return;

    _syncActualQuantityPending =
        _syncActualQuantityPending || syncActualQuantity;
    _syncNotesPending = _syncNotesPending || syncNotes;
    if (_controllerSyncScheduled) return;

    _controllerSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final syncActualQuantity = _syncActualQuantityPending;
      final syncNotes = _syncNotesPending;
      _controllerSyncScheduled = false;
      _syncActualQuantityPending = false;
      _syncNotesPending = false;

      if (syncActualQuantity) {
        _controllers.syncActualQuantityFromLine(widget.line);
      }
      if (syncNotes) {
        _controllers.syncNotesFromLine(widget.line);
      }
    });
  }
}

@Preview(name: 'Inventory stock opname line tile')
Widget inventoryStockOpnameLineTilePreview() {
  return inventoryStockOpnameLinePreviewScaffold(
    InventoryStockOpnameLineTile(line: inventoryStockOpnamePreviewLine()),
  );
}
