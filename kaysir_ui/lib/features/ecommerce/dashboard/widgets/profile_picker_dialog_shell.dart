import 'package:flutter/material.dart';

import 'dialog_close_button.dart';
import 'dialog_header.dart';
import 'tone.dart';

const _profilePickerDialogMaxWidth = 640.0;
const _profilePickerDialogMinHeight = 360.0;
const _profilePickerDialogMaxHeight = 560.0;
const _profilePickerDialogVerticalChrome = 180.0;

class ProfilePickerDialogShell extends StatelessWidget {
  const ProfilePickerDialogShell({
    required this.height,
    required this.child,
    super.key,
  });

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const ValueKey('profile_picker_dialog'),
      insetPadding: const EdgeInsets.all(16),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      title: const DialogHeader(
        icon: Icons.view_quilt_outlined,
        title: 'Commerce profile',
        tone: VisualTone.primary,
      ),
      content: SizedBox(
        width: _profilePickerDialogMaxWidth,
        height: height,
        child: child,
      ),
      actions: const [DialogCloseButton()],
    );
  }
}

double profilePickerDialogHeightFor(Size viewportSize) {
  return (viewportSize.height - _profilePickerDialogVerticalChrome)
      .clamp(_profilePickerDialogMinHeight, _profilePickerDialogMaxHeight)
      .toDouble();
}
