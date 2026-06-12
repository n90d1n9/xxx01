import 'package:flutter/material.dart';

import '../config/config.dart';
import 'dropdown_widget.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.accountName,
    this.onTap,
    this.onProfileTap,
    this.imagePath = 'assets/images/profile.png',
  });
  final String accountName;
  final String imagePath;
  final void Function()? onTap;
  final void Function()? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final profileMenu = <DropdownItem>[
      DropdownItem(title: accountName, icon: "person", onTap: onProfileTap),
      DropdownItem(title: "Sign out", icon: "logout", onTap: onTap),
    ];
    return Container(
      margin: const EdgeInsets.only(left: defaultPadding),
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: Dropdown(items: profileMenu),
    );
  }
}
