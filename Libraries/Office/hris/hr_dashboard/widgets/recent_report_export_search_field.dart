import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

class RecentReportExportSearchField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const RecentReportExportSearchField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<RecentReportExportSearchField> createState() =>
      _RecentReportExportSearchFieldState();
}

class _RecentReportExportSearchFieldState
    extends State<RecentReportExportSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant RecentReportExportSearchField oldWidget) {
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
    final hasSearch = widget.value.trim().isNotEmpty;

    return TextField(
      key: const Key('recent-export-search-field'),
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon:
            hasSearch
                ? IconButton(
                  tooltip: 'Clear export search',
                  onPressed: () => widget.onChanged(''),
                  icon: const Icon(Icons.close_rounded),
                )
                : null,
        hintText: 'Search exports',
        isDense: true,
        filled: true,
        fillColor: HrisColors.surface,
        border: _inputBorder(HrisColors.border),
        enabledBorder: _inputBorder(HrisColors.border),
        focusedBorder: _inputBorder(HrisColors.primary),
      ),
    );
  }
}

OutlineInputBorder _inputBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color),
  );
}
