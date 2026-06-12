import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../scrum_board_palette.dart';

/// Compact colored pill used for task detail summary attributes.
class ScrumTaskDetailPill extends StatelessWidget {
  const ScrumTaskDetailPill({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Preview for task detail summary pills.
@Preview(group: 'Ky Scrumboard', name: 'Task detail pill', size: Size(220, 90))
Widget scrumTaskDetailPillPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: ScrumTaskDetailPill(label: 'Critical', color: Color(0xFFDC2626)),
      ),
    ),
  );
}

/// Label/value pair used by task detail metadata rows.
class ScrumTaskDetailValue extends StatelessWidget {
  const ScrumTaskDetailValue({
    super.key,
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: ScrumBoardPalette.mutedInk,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: ScrumBoardPalette.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// Preview for a task detail metadata value.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Task detail value',
  size: Size(260, 100),
)
Widget scrumTaskDetailValuePreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: ScrumTaskDetailValue(label: 'Assignee', value: 'Alya Rahman'),
      ),
    ),
  );
}

/// Initials avatar used by task detail metadata.
class ScrumTaskDetailAvatar extends StatelessWidget {
  const ScrumTaskDetailAvatar({
    super.key,
    required this.name,
    required this.color,
  });

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: color.withValues(alpha: .12),
      child: Text(
        scrumTaskDetailInitials(name),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

/// Preview for a task detail assignee avatar.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Task detail avatar',
  size: Size(160, 100),
)
Widget scrumTaskDetailAvatarPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: ScrumTaskDetailAvatar(
          name: 'Alya Rahman',
          color: Color(0xFF2563EB),
        ),
      ),
    ),
  );
}

/// Returns display initials for an assignee name.
String scrumTaskDetailInitials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}
