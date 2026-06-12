import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../scrum_board_palette.dart';

/// Responsive side-sheet shell used by task detail and inspector panels.
class TaskDetailPanelShell extends StatelessWidget {
  const TaskDetailPanelShell({
    super.key,
    required this.header,
    required this.content,
    required this.actions,
    this.contentPadding = const EdgeInsets.fromLTRB(20, 18, 20, 20),
  });

  final Widget header;
  final Widget content;
  final Widget actions;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final padding = compact
              ? const EdgeInsets.fromLTRB(12, 72, 12, 12)
              : const EdgeInsets.all(24);
          final panelWidth = (constraints.maxWidth - padding.horizontal)
              .clamp(280.0, 560.0)
              .toDouble();
          final panelHeight = constraints.maxHeight - padding.vertical;

          return Align(
            alignment: compact
                ? AlignmentDirectional.bottomCenter
                : AlignmentDirectional.centerEnd,
            child: Padding(
              padding: padding,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 24,
                shadowColor: Colors.black.withValues(alpha: .22),
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: panelWidth,
                  height: panelHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      header,
                      const Divider(height: 1),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: contentPadding,
                          child: content,
                        ),
                      ),
                      const Divider(height: 1),
                      actions,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Preview for the responsive task detail panel shell.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Task detail panel shell',
  size: Size(820, 560),
)
Widget taskDetailPanelShellPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: TaskDetailPanelShell(
        header: const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 12, 14),
          child: Text('Checkout readiness review'),
        ),
        content: const Text(
          'Validate release handoff, blockers, activity, and ownership signals.',
        ),
        actions: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            children: [
              TextButton(onPressed: () {}, child: const Text('Close')),
              FilledButton(onPressed: () {}, child: const Text('Edit')),
            ],
          ),
        ),
      ),
    ),
  );
}
