import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_board_filter.dart';
import '../../models/scrum_board_view_preset.dart';
import '../scrum_board_palette.dart';
import 'scrum_board_filter_surface.dart';

/// Popup button for applying saved board filter presets.
class ScrumBoardViewPresetButton extends StatelessWidget {
  const ScrumBoardViewPresetButton({
    super.key,
    required this.filter,
    required this.viewPresets,
    required this.onFilterChanged,
  });

  final ScrumBoardFilter filter;
  final List<ScrumBoardViewPreset> viewPresets;
  final ValueChanged<ScrumBoardFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final selectedPreset = _selectedPresetFor(viewPresets, filter);
    final enabled = viewPresets.isNotEmpty;

    return PopupMenuButton<ScrumBoardViewPreset>(
      tooltip: 'Board views',
      enabled: enabled,
      onSelected: (preset) => onFilterChanged(preset.filter),
      itemBuilder: (context) {
        if (viewPresets.isEmpty) {
          return [
            const PopupMenuItem<ScrumBoardViewPreset>(
              enabled: false,
              child: Text('No saved views'),
            ),
          ];
        }

        return [
          for (final preset in viewPresets)
            CheckedPopupMenuItem<ScrumBoardViewPreset>(
              value: preset,
              checked: selectedPreset?.id == preset.id,
              child: _ScrumBoardPresetMenuLabel(preset: preset),
            ),
        ];
      },
      child: ScrumBoardFilterSurface(
        enabled: enabled,
        selected: selectedPreset != null,
        icon: Icons.bookmarks_outlined,
        label: selectedPreset?.label ?? 'Views',
      ),
    );
  }
}

/// Preview for the saved-view popup trigger.
@Preview(
  group: 'Ky Scrumboard',
  name: 'View preset button',
  size: Size(240, 90),
)
Widget scrumBoardViewPresetButtonPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: ScrumBoardViewPresetButton(
          filter: const ScrumBoardFilter(),
          viewPresets: defaultScrumBoardViewPresets,
          onFilterChanged: (_) {},
        ),
      ),
    ),
  );
}

/// Menu row content for a saved board preset.
class _ScrumBoardPresetMenuLabel extends StatelessWidget {
  const _ScrumBoardPresetMenuLabel({required this.preset});

  final ScrumBoardViewPreset preset;

  @override
  Widget build(BuildContext context) {
    final description = preset.description.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(preset.label),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: ScrumBoardPalette.mutedInk),
          ),
        ],
      ],
    );
  }
}

ScrumBoardViewPreset? _selectedPresetFor(
  List<ScrumBoardViewPreset> presets,
  ScrumBoardFilter filter,
) {
  for (final preset in presets) {
    if (preset.matches(filter)) return preset;
  }
  return null;
}
