import 'package:flutter/material.dart';

import 'app_surface.dart';

class AppFilterBar extends StatelessWidget {
  const AppFilterBar({
    super.key,
    this.search,
    this.filters = const [],
    this.trailing = const [],
    this.contained = true,
    this.elevated = true,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 12,
    this.compactBreakpoint = 720,
    this.trailingWidth = 280,
  });

  final Widget? search;
  final List<Widget> filters;
  final List<Widget> trailing;
  final bool contained;
  final bool elevated;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double compactBreakpoint;
  final double trailingWidth;

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < compactBreakpoint;

        if (isCompact) {
          return _CompactFilterLayout(
            search: search,
            filters: filters,
            trailing: trailing,
            spacing: spacing,
          );
        }

        return _WideFilterLayout(
          search: search,
          filters: filters,
          trailing: trailing,
          spacing: spacing,
          trailingWidth: trailingWidth,
        );
      },
    );

    if (!contained) {
      return content;
    }

    return AppSurface(elevated: elevated, padding: padding, child: content);
  }
}

class _CompactFilterLayout extends StatelessWidget {
  const _CompactFilterLayout({
    required this.search,
    required this.filters,
    required this.trailing,
    required this.spacing,
  });

  final Widget? search;
  final List<Widget> filters;
  final List<Widget> trailing;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    void add(Widget child) {
      if (children.isNotEmpty) {
        children.add(SizedBox(height: spacing));
      }
      children.add(child);
    }

    if (search != null) {
      add(search!);
    }
    if (filters.isNotEmpty) {
      add(Align(alignment: Alignment.centerLeft, child: _FilterWrap(filters)));
    }
    for (final control in trailing) {
      add(control);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _WideFilterLayout extends StatelessWidget {
  const _WideFilterLayout({
    required this.search,
    required this.filters,
    required this.trailing,
    required this.spacing,
    required this.trailingWidth,
  });

  final Widget? search;
  final List<Widget> filters;
  final List<Widget> trailing;
  final double spacing;
  final double trailingWidth;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final topRow = <Widget>[];

    if (search != null) {
      topRow.add(Expanded(child: search!));
    }

    for (final control in trailing) {
      if (topRow.isNotEmpty) {
        topRow.add(SizedBox(width: spacing));
      }
      topRow.add(SizedBox(width: trailingWidth, child: control));
    }

    if (topRow.isNotEmpty) {
      children.add(Row(children: topRow));
    }

    if (filters.isNotEmpty) {
      if (children.isNotEmpty) {
        children.add(SizedBox(height: spacing));
      }
      children.add(
        Align(alignment: Alignment.centerLeft, child: _FilterWrap(filters)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _FilterWrap extends StatelessWidget {
  const _FilterWrap(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.length == 1) {
      return children.single;
    }

    return Wrap(spacing: 12, runSpacing: 12, children: children);
  }
}
