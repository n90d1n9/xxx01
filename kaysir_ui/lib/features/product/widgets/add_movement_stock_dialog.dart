// Stock Movement Dialog
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../inventory/models/movement_type.dart';
import '../../inventory/models/stock_movement.dart';
import '../models/product.dart';
import '../states/product_provider.dart';
import '../states/stock_movement_provider.dart';

class AddStockMovementDialog extends ConsumerStatefulWidget {
  final Product product;
  final MovementType type;
  //final void Function()? onPressed;

  const AddStockMovementDialog({
    super.key,
    required this.product,
    required this.type,
    // required this.onPressed,
  });

  @override
  ConsumerState<AddStockMovementDialog> createState() =>
      _AddStockMovementDialogState();
}

class _AddStockMovementDialogState
    extends ConsumerState<AddStockMovementDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  late TextEditingController _referenceController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _referenceController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.type == MovementType.inbound
            ? 'Add Stock'
            : widget.type == MovementType.outbound
            ? 'Remove Stock'
            : 'Adjust Stock';

    final actionText =
        widget.type == MovementType.inbound
            ? 'Add'
            : widget.type == MovementType.outbound
            ? 'Remove'
            : 'Adjust';

    return AlertDialog(
      title: Text(title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text('Current Stock: ${widget.product.currentStock} units'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  prefixIcon: Icon(Icons.inventory),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final quantity = int.tryParse(value?.trim() ?? '');
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (quantity == null || quantity <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  if (widget.type == MovementType.outbound &&
                      quantity > widget.product.currentStock) {
                    return 'Not enough stock available';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference',
                  prefixIcon: Icon(Icons.notes),
                  hintText: 'e.g., Order #123, Manual Adjustment',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a reference';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                widget.type == MovementType.inbound
                    ? Colors.green
                    : widget.type == MovementType.outbound
                    ? Colors.red
                    : Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: Text('$actionText Stock'),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final quantity = int.parse(_quantityController.text.trim());
    final notes = _notesController.text.trim();
    final uuid = const Uuid();
    final movement = StockMovement(
      id: uuid.v4(),
      productId: widget.product.id,
      quantity: quantity,
      type: widget.type,
      reference: _referenceController.text.trim(),
      date: DateTime.now(),
      notes: notes,
    );

    ref.read(stockMovementsProvider.notifier).addMovement(movement);
    ref
        .read(productsProvider.notifier)
        .applyStockMovement(
          productId: widget.product.id,
          type: widget.type,
          quantity: quantity,
          notes: notes.isEmpty ? null : notes,
        );

    Navigator.pop(context);
  }
}
