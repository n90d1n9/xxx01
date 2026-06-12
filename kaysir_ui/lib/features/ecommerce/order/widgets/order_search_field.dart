import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';

class OrderSearchField extends StatefulWidget {
  final String query;
  final ValueChanged<String> onChanged;

  const OrderSearchField({
    super.key,
    required this.query,
    required this.onChanged,
  });

  @override
  State<OrderSearchField> createState() => _OrderSearchFieldState();
}

class _OrderSearchFieldState extends State<OrderSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant OrderSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query && _controller.text != widget.query) {
      _controller.text = widget.query;
      _controller.selection = TextSelection.collapsed(
        offset: widget.query.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      key: const ValueKey('order_search_field'),
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: 'Search order, customer, product, payment, or destination',
        prefixIcon: const Icon(Icons.search_outlined),
        suffixIcon:
            widget.query.trim().isEmpty
                ? null
                : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close),
                  onPressed: () => widget.onChanged(''),
                ),
        isDense: true,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.38,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
      ),
    );
  }
}
