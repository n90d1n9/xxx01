import 'package:flutter/material.dart';


class ProfileMenu extends StatelessWidget {
  final String? avatarPath;
  final List<PopupMenuItem>? items;
  const ProfileMenu({super.key, this.avatarPath, this.items});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      child:  CircleAvatar(
        backgroundImage: AssetImage(avatarPath!),
      ),
      itemBuilder: (context) => [
        ...items!
      ],
    );
  }
}
