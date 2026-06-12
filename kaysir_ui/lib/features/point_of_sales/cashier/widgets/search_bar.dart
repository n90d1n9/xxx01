import 'package:flutter/material.dart';

import 'pos_ui.dart';

class POSSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final String hintText;

  const POSSearchBar({
    super.key,
    required this.onSearch,
    this.onSubmitted,
    this.focusNode,
    this.hintText = 'Search products by name or barcode',
  });

  @override
  State<POSSearchBar> createState() => _POSSearchBarState();
}

class _POSSearchBarState extends State<POSSearchBar> {
  final TextEditingController _controller = TextEditingController();
  late FocusNode _focusNode;
  late bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _attachFocusNode(widget.focusNode);
  }

  @override
  void didUpdateWidget(covariant POSSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _detachFocusNode();
      _attachFocusNode(widget.focusNode);
    }
  }

  @override
  void dispose() {
    _detachFocusNode();
    _controller.dispose();
    super.dispose();
  }

  void _attachFocusNode(FocusNode? focusNode) {
    _ownsFocusNode = focusNode == null;
    _focusNode = focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChanged);
  }

  void _detachFocusNode() {
    _focusNode.removeListener(_handleFocusChanged);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
  }

  void _handleFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFocus = _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: 44,
      decoration: BoxDecoration(
        color:
            hasFocus
                ? theme.colorScheme.surface
                : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(
          color:
              hasFocus
                  ? theme.colorScheme.primary.withValues(alpha: 0.55)
                  : theme.dividerColor,
        ),
        boxShadow:
            hasFocus
                ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
                : null,
      ),
      padding: const EdgeInsets.only(left: 14),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: InputBorder.none,
          isDense: true,
          icon: Icon(
            Icons.search,
            color:
                hasFocus
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
          ),
          suffixIcon:
              _controller.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      setState(() {});
                      widget.onSearch('');
                    },
                  )
                  : _ShortcutHint(label: 'F2', focused: hasFocus),
        ),
        onChanged: (value) {
          setState(() {});
          widget.onSearch(value);
        },
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}

class _ShortcutHint extends StatelessWidget {
  final String label;
  final bool focused;

  const _ShortcutHint({required this.label, required this.focused});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Center(
        widthFactor: 1,
        child: Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color:
                focused
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(POSUiTokens.radius),
            border: Border.all(color: theme.dividerColor),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color:
                  focused
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
