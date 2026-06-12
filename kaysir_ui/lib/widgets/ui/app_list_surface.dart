import 'package:flutter/material.dart';

class AppListSurface extends StatelessWidget {
  const AppListSurface({
    super.key,
    required this.children,
    this.header,
    this.metrics,
    this.filters,
    this.emptyState,
    this.padding = const EdgeInsets.all(16),
    this.sectionSpacing = 16,
    this.itemSpacing = 16,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.controller,
  });

  final Widget? header;
  final Widget? metrics;
  final Widget? filters;
  final Widget? emptyState;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double sectionSpacing;
  final double itemSpacing;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[];

    void addSection(Widget? section) {
      if (section == null) return;
      if (sections.isNotEmpty) {
        sections.add(SizedBox(height: sectionSpacing));
      }
      sections.add(section);
    }

    addSection(header);
    addSection(metrics);
    addSection(filters);

    if (children.isEmpty) {
      addSection(emptyState);
    } else {
      if (sections.isNotEmpty) {
        sections.add(SizedBox(height: sectionSpacing));
      }
      for (var index = 0; index < children.length; index += 1) {
        sections.add(children[index]);
        if (index != children.length - 1) {
          sections.add(SizedBox(height: itemSpacing));
        }
      }
    }

    return ListView(
      controller: controller,
      physics: physics,
      padding: padding,
      children: sections,
    );
  }
}
