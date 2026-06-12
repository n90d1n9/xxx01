import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../scrum_board_palette.dart';

/// Search input used by scrumboard toolbars and compact board surfaces.
class ScrumBoardSearchField extends StatelessWidget {
  const ScrumBoardSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.width,
    this.hintText = 'Search tasks',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final double? width;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: ScrumBoardPalette.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: ScrumBoardPalette.border),
          ),
        ),
      ),
    );
  }
}

/// Preview for the reusable scrumboard search field.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Toolbar search field',
  size: Size(360, 96),
)
Widget scrumBoardSearchFieldPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: ScrumBoardSearchField(
          controller: TextEditingController(text: 'checkout'),
          width: 320,
          onChanged: (_) {},
        ),
      ),
    ),
  );
}
