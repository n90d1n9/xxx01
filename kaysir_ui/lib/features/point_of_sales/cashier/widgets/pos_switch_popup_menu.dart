import 'package:flutter/material.dart';

import 'pos_switch_interaction.dart';

typedef POSSwitchPopupSectionHeaderBuilder<TSection> =
    Widget Function(TSection section);

typedef POSSwitchPopupSectionEntriesBuilder<TValue, TSection> =
    Iterable<PopupMenuEntry<TValue>> Function(TSection section);

class POSSwitchAdaptiveMenuButton<T> extends StatelessWidget {
  final String tooltip;
  final Widget icon;
  final Widget? label;
  final double viewportWidth;
  final double compactBreakpoint;
  final VoidCallback onCompactPressed;
  final T? initialValue;
  final PopupMenuItemSelected<T> onSelected;
  final PopupMenuItemBuilder<T> itemBuilder;

  const POSSwitchAdaptiveMenuButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.viewportWidth,
    required this.onCompactPressed,
    required this.onSelected,
    required this.itemBuilder,
    this.label,
    this.compactBreakpoint = kPOSSwitchCompactSheetBreakpoint,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    if (viewportWidth < compactBreakpoint) {
      return POSSwitchTriggerButton(
        tooltip: tooltip,
        icon: icon,
        label: label,
        onPressed: onCompactPressed,
      );
    }

    return POSSwitchPopupMenuButton<T>(
      tooltip: tooltip,
      icon: icon,
      label: label,
      initialValue: initialValue,
      onSelected: onSelected,
      itemBuilder: itemBuilder,
    );
  }
}

class POSSwitchTriggerButton extends StatelessWidget {
  final String tooltip;
  final Widget icon;
  final Widget? label;
  final VoidCallback onPressed;

  const POSSwitchTriggerButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final label = this.label;

    if (label != null) {
      return Tooltip(
        message: tooltip,
        child: OutlinedButton.icon(
          icon: icon,
          label: label,
          onPressed: onPressed,
        ),
      );
    }

    return IconButton(tooltip: tooltip, icon: icon, onPressed: onPressed);
  }
}

class POSSwitchPopupMenuButton<T> extends StatelessWidget {
  final String tooltip;
  final Widget icon;
  final Widget? label;
  final T? initialValue;
  final PopupMenuItemSelected<T> onSelected;
  final PopupMenuItemBuilder<T> itemBuilder;

  const POSSwitchPopupMenuButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onSelected,
    required this.itemBuilder,
    this.label,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final label = this.label;

    if (label != null) {
      return PopupMenuButton<T>(
        tooltip: tooltip,
        initialValue: initialValue,
        onSelected: onSelected,
        itemBuilder: itemBuilder,
        child: OutlinedButton.icon(icon: icon, label: label, onPressed: null),
      );
    }

    return PopupMenuButton<T>(
      tooltip: tooltip,
      icon: icon,
      initialValue: initialValue,
      onSelected: onSelected,
      itemBuilder: itemBuilder,
    );
  }
}

List<PopupMenuEntry<TValue>> buildPOSSwitchPopupMenuEntries<TValue, TSection>({
  Widget? title,
  required Iterable<TSection> sections,
  required POSSwitchPopupSectionEntriesBuilder<TValue, TSection>
  itemEntriesBuilder,
  POSSwitchPopupSectionHeaderBuilder<TSection>? sectionHeaderBuilder,
  double headerHeight = 34,
  double dividerHeight = 8,
}) {
  final entries = <PopupMenuEntry<TValue>>[];

  if (title != null) {
    entries.add(
      PopupMenuItem<TValue>(enabled: false, height: headerHeight, child: title),
    );
  }

  for (final section in sections) {
    if (entries.isNotEmpty) {
      entries.add(PopupMenuDivider(height: dividerHeight));
    }

    final sectionHeader = sectionHeaderBuilder?.call(section);
    if (sectionHeader != null) {
      entries.add(
        PopupMenuItem<TValue>(
          enabled: false,
          height: headerHeight,
          child: sectionHeader,
        ),
      );
    }

    entries.addAll(itemEntriesBuilder(section));
  }

  return entries;
}
