import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

import '../models/product.dart';
import '../utils/product_count_capture_view.dart';
import '../utils/product_form_draft.dart';
import 'product_count_capture_preview_panel.dart';
import 'product_count_capture_target_card.dart';
import 'product_stock_count_state_widgets.dart';

typedef ProductCountCaptureSave =
    void Function(Product product, int actualStock, String? notes);

class ProductCountCaptureForm extends StatefulWidget {
  const ProductCountCaptureForm({
    super.key,
    required this.products,
    required this.onSave,
    this.initialQuery = '',
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
  });

  final List<Product> products;
  final String initialQuery;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final ProductCountCaptureSave onSave;

  @override
  State<ProductCountCaptureForm> createState() =>
      _ProductCountCaptureFormState();
}

class _ProductCountCaptureFormState extends State<ProductCountCaptureForm> {
  final _formKey = GlobalKey<FormState>();
  final _lookupController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _applyInitialQuery(widget.initialQuery);
  }

  @override
  void didUpdateWidget(ProductCountCaptureForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery) {
      _applyInitialQuery(widget.initialQuery);
    }
  }

  @override
  void dispose() {
    _lookupController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasProducts = widget.products.isNotEmpty;
    final errorMessage = widget.errorMessage?.trim();

    if (widget.isLoading && !hasProducts) {
      return ProductStockCountState(
        icon: Icons.document_scanner_rounded,
        title: 'Loading products',
        message: 'Preparing products for count capture.',
        showProgress: true,
        onRefresh: widget.onRefresh,
      );
    }

    if (!hasProducts && errorMessage != null && errorMessage.isNotEmpty) {
      return ProductStockCountState(
        icon: Icons.cloud_off_rounded,
        title: 'Products unavailable',
        message: errorMessage,
        onRefresh: widget.onRefresh,
      );
    }

    if (!hasProducts) {
      return ProductStockCountState(
        icon: Icons.inventory_2_outlined,
        title: 'No products ready to count',
        message: 'Add products before capturing stock opname counts.',
        onRefresh: widget.onRefresh,
      );
    }

    final query = _lookupController.text;
    final selectedTarget = _selectedTarget;
    final suggestions = buildProductCountCaptureTargets(
      products: widget.products,
      query: query,
      limit: query.trim().isEmpty ? 4 : 6,
    );
    final preview = buildProductCountCaptureDraftPreview(
      target: selectedTarget,
      actualStockInput: _quantityController.text,
    );

    return Form(
      key: _formKey,
      child: AppListSurface(
        padding: const EdgeInsets.all(16),
        sectionSpacing: 16,
        itemSpacing: 12,
        header: AppContentPanel(
          title: 'Capture Count',
          subtitle: 'Scan a barcode, enter SKU, or choose a product',
          leadingIcon: Icons.document_scanner_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (errorMessage != null && errorMessage.isNotEmpty) ...[
                ProductStockCountNotice(
                  message: errorMessage,
                  onRefresh: widget.onRefresh,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _lookupController,
                decoration: const InputDecoration(
                  labelText: 'Barcode, SKU, product ID, or name',
                  prefixIcon: Icon(Icons.search_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: _validateLookup,
                onChanged: _handleLookupChanged,
              ),
              const SizedBox(height: 12),
              ProductCountCaptureSelectedTargetPanel(target: selectedTarget),
            ],
          ),
        ),
        filters: AppContentPanel(
          title: 'Count details',
          subtitle: 'Record the physical stock found during opname',
          leadingIcon: Icons.edit_note_rounded,
          elevated: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Actual quantity',
                  prefixIcon: Icon(Icons.numbers_rounded),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: validateProductStockInput,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              ProductCountCapturePreviewPanel(preview: preview),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.notes_rounded),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: AppActionButton(
                  label: 'Save count',
                  icon: Icons.save_rounded,
                  onPressed: selectedTarget == null ? null : _handleSave,
                ),
              ),
            ],
          ),
        ),
        children: [
          AppContentPanel(
            title: 'Product suggestions',
            subtitle: _suggestionSubtitle(query, suggestions.length),
            leadingIcon: Icons.manage_search_rounded,
            elevated: false,
            child:
                suggestions.isEmpty
                    ? const ProductStockCountState(
                      icon: Icons.search_off_rounded,
                      title: 'No products match this scan',
                      message: 'Try another barcode, SKU, name, or product id.',
                      compact: true,
                    )
                    : Column(
                      children: [
                        for (final target in suggestions) ...[
                          ProductCountCaptureSuggestionTile(
                            target: target,
                            isSelected: target.id == selectedTarget?.id,
                            onSelected: () => _selectTarget(target),
                          ),
                          if (target != suggestions.last)
                            const SizedBox(height: 10),
                        ],
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  ProductCountCaptureTarget? get _selectedTarget {
    if (_selectedProductId != null) {
      return resolveProductCountCaptureTarget(
        widget.products,
        _selectedProductId!,
      );
    }

    return resolveProductCountCaptureTarget(
      widget.products,
      _lookupController.text,
    );
  }

  String? _validateLookup(String? value) {
    final requiredError = validateRequiredProductField(value, 'a product');
    if (requiredError != null) return requiredError;

    final target = resolveProductCountCaptureTarget(widget.products, value!);
    if (target == null) return 'Product was not found';
    return null;
  }

  void _handleLookupChanged(String value) {
    final target = resolveProductCountCaptureTarget(widget.products, value);
    setState(() => _selectedProductId = target?.id);
  }

  void _applyInitialQuery(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return;

    _lookupController.text = normalizedQuery;
    _selectedProductId =
        resolveProductCountCaptureTarget(widget.products, normalizedQuery)?.id;
  }

  void _selectTarget(ProductCountCaptureTarget target) {
    setState(() {
      _selectedProductId = target.id;
      _lookupController.text = target.id;
      if (target.actualStock != null) {
        _quantityController.text = '${target.actualStock}';
      }
    });
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final target = _selectedTarget;
    if (target == null) return;

    final actualStock = parseProductStockInput(_quantityController.text);
    final notes = _notesController.text.trim();
    widget.onSave(target.product, actualStock, notes.isEmpty ? null : notes);
  }
}

String _suggestionSubtitle(String query, int count) {
  if (query.trim().isEmpty) return 'Showing $count priority products to count';
  return 'Showing $count matches for this scan';
}
