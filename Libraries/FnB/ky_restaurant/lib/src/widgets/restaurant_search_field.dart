import 'package:flutter/material.dart';

class RestaurantSearchField extends StatefulWidget {
  const RestaurantSearchField({
    super.key,
    required this.value,
    required this.onChanged,
    this.hintText = 'Search',
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  State<RestaurantSearchField> createState() => _RestaurantSearchFieldState();
}

class _RestaurantSearchFieldState extends State<RestaurantSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant RestaurantSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == _controller.text) return;
    _controller.value = TextEditingValue(
      text: widget.value,
      selection: TextSelection.collapsed(offset: widget.value.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasQuery = widget.value.trim().isNotEmpty;

    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: hasQuery
            ? IconButton(
                onPressed: () => widget.onChanged(''),
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Clear search',
              )
            : null,
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: .32),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        isDense: true,
      ),
    );
  }
}
