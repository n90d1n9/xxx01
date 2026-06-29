import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'admin_icon.dart';
import 'admin_drawer.dart';


class AdminOverlayDrawer extends StatelessWidget {
  final bool isOpen;
  final void Function(PointerExitEvent)? onExit;
  final void Function(PointerEnterEvent)? onEnter;
  const AdminOverlayDrawer({super.key, this.isOpen = false, this.onEnter, this.onExit});

  @override
  Widget build(BuildContext context) {
    
    return MouseRegion(
     // onEnter: (_) => onEnter,
     onEnter: onEnter,
      onExit: onExit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isOpen ? 250 : 70,
        child: Drawer(
          child: isOpen
              ? const AdminDrawer()
              : const AdminIconDrawer(),
        ),
      ),
    );
  }
}
