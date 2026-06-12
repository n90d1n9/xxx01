import 'package:flutter/material.dart';

import '../models/product_profile.dart';
import 'action_button.dart';
import 'current_profile_badge.dart';
import 'dialog_close_button.dart';
import 'dialog_header.dart';
import 'product_profile_details.dart';
import 'product_profile_icon_badge.dart';
import 'tone.dart';

Future<void> showProductProfileDetailsDialog({
  required BuildContext context,
  required ProductProfile profile,
  bool selected = false,
  ValueChanged<String>? onProfileSelected,
  ValueChanged<String>? onOpenOrderWorkspace,
}) {
  return showDialog<void>(
    context: context,
    builder:
        (context) => ProductProfileDetailsDialog(
          profile: profile,
          selected: selected,
          onProfileSelected: onProfileSelected,
          onOpenOrderWorkspace: onOpenOrderWorkspace,
        ),
  );
}

class ProductProfileDetailsDialog extends StatelessWidget {
  final ProductProfile profile;
  final bool selected;
  final ValueChanged<String>? onProfileSelected;
  final ValueChanged<String>? onOpenOrderWorkspace;

  const ProductProfileDetailsDialog({
    super.key,
    required this.profile,
    this.selected = false,
    this.onProfileSelected,
    this.onOpenOrderWorkspace,
  });

  @override
  Widget build(BuildContext context) {
    final canSelectProfile = !selected && onProfileSelected != null;
    final onOpenOrderWorkspace = this.onOpenOrderWorkspace;
    final contentHeight = (MediaQuery.sizeOf(context).height - 220).clamp(
      320.0,
      620.0,
    );

    return AlertDialog(
      key: const ValueKey('product_profile_details_dialog'),
      insetPadding: const EdgeInsets.all(16),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      title: DialogHeader(
        icon: productProfileIcon(profile),
        title: 'Profile details',
        tone: VisualTone.primary,
        trailing: selected ? const CurrentProfileBadge() : null,
      ),
      content: SizedBox(
        width: 680,
        height: contentHeight,
        child: SingleChildScrollView(
          child: ProductProfileDetails(
            profile: profile,
            onOpenOrderWorkspace:
                onOpenOrderWorkspace == null
                    ? null
                    : (routePath) {
                      Navigator.of(context).pop();
                      onOpenOrderWorkspace(routePath);
                    },
          ),
        ),
      ),
      actions: [
        const DialogCloseButton(),
        if (canSelectProfile)
          ActionButton(
            key: ValueKey('product_profile_use_${profile.id}'),
            variant: ActionButtonVariant.primary,
            onPressed: () {
              onProfileSelected?.call(profile.id);
              Navigator.of(context).pop();
            },
            icon: Icons.check_circle_outline,
            label: 'Use profile',
          ),
      ],
    );
  }
}
