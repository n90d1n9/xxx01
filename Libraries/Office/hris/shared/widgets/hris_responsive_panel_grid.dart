import 'package:flutter/material.dart';

class HrisResponsivePanelGrid extends StatelessWidget {
  final List<Widget> panels;
  final double breakpoint;

  const HrisResponsivePanelGrid({
    super.key,
    required this.panels,
    this.breakpoint = 980,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(children: _spaced(panels, vertical: true));
        }

        final rows = <Widget>[];
        for (var i = 0; i < panels.length; i += 2) {
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: panels[i]),
                if (i + 1 < panels.length) ...[
                  const SizedBox(width: 16),
                  Expanded(child: panels[i + 1]),
                ] else
                  const Spacer(),
              ],
            ),
          );
        }

        return Column(children: _spaced(rows, vertical: true));
      },
    );
  }

  List<Widget> _spaced(List<Widget> children, {required bool vertical}) {
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        spaced.add(
          vertical ? const SizedBox(height: 16) : const SizedBox(width: 16),
        );
      }
      spaced.add(children[i]);
    }
    return spaced;
  }
}
