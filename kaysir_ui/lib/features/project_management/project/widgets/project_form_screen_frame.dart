import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Shared scaffold and app-bar frame for all project form screen states.
class ProjectFormScreenFrame extends StatelessWidget {
  const ProjectFormScreenFrame({
    required this.child,
    this.actions = const [],
    this.title = 'Project Form',
    this.centerBody = false,
    this.safeArea = true,
    super.key,
  });

  final Widget child;
  final List<Widget> actions;
  final String title;
  final bool centerBody;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final framedChild = centerBody ? Center(child: child) : child;

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: safeArea ? SafeArea(child: framedChild) : framedChild,
    );
  }
}

@Preview(name: 'Project form screen frame')
Widget projectFormScreenFramePreview() {
  return const MaterialApp(
    home: ProjectFormScreenFrame(
      centerBody: true,
      actions: [
        IconButton(
          tooltip: 'Open project table',
          onPressed: null,
          icon: Icon(Icons.table_chart_outlined),
        ),
      ],
      child: Text('Project form workspace'),
    ),
  );
}
