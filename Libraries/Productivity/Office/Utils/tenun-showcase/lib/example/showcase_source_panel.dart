import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String showcasePrettyJson(Object? value) {
  return const JsonEncoder.withIndent('  ').convert(value);
}

class ShowcaseSourceTextItem {
  const ShowcaseSourceTextItem({
    required this.title,
    required this.text,
    required this.copyLabel,
  });

  final String title;
  final String text;
  final String copyLabel;
}

class ShowcaseSourceTextPanelGroup extends StatelessWidget {
  const ShowcaseSourceTextPanelGroup({
    super.key,
    required this.items,
    this.panelHeight = 180,
    this.minPanelWidth = 360,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  final List<ShowcaseSourceTextItem> items;
  final double panelHeight;
  final double minPanelWidth;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = math.min(items.length, 2);
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : minPanelWidth * columnCount + spacing * (columnCount - 1);
        final twoColumnWidth = minPanelWidth * 2 + spacing;
        final panelWidth = availableWidth >= twoColumnWidth
            ? (availableWidth - spacing) / 2
            : availableWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (final item in items)
              ShowcaseSourceTextPanel(
                title: item.title,
                text: item.text,
                copyLabel: item.copyLabel,
                width: math.max(1, panelWidth),
                height: panelHeight,
              ),
          ],
        );
      },
    );
  }
}

class ShowcaseSourceTextPanel extends StatelessWidget {
  const ShowcaseSourceTextPanel({
    super.key,
    required this.title,
    required this.text,
    required this.copyLabel,
    this.width = 360,
    this.height = 180,
  });

  final String title;
  final String text;
  final String copyLabel;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title, style: const TextStyle(fontSize: 12)),
                  ),
                  IconButton(
                    tooltip: 'Copy',
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: text));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$copyLabel copied')),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    text,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
