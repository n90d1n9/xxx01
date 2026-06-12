import 'package:flutter/material.dart';

class ProjectResponsiveFormGrid extends StatelessWidget {
  const ProjectResponsiveFormGrid({
    required this.children,
    this.breakpoint = 760,
    this.spacing = 12,
    super.key,
  });

  final List<Widget> children;
  final double breakpoint;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= breakpoint ? 2 : 1;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class ProjectFormTextField extends StatelessWidget {
  const ProjectFormTextField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.icon,
    this.maxLines = 1,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final IconData? icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon, size: 18),
        filled: true,
        fillColor: colorScheme.surface,
        border: border,
        enabledBorder: border,
      ),
      onChanged: onChanged,
    );
  }
}
