import 'package:flutter/material.dart';

class UserAccountsDrawer extends StatelessWidget {
  const UserAccountsDrawer({
    super.key,
    this.accountEmail,
    this.accountName,
    this.imgPath,
  });

  final String? accountName;
  final String? accountEmail;
  final String? imgPath;

  String get _displayName {
    final name = accountName?.trim();
    return name == null || name.isEmpty ? 'Guest' : name;
  }

  String get _displayEmail {
    final email = accountEmail?.trim();
    return email == null || email.isEmpty ? 'No email configured' : email;
  }

  String get _initial {
    final displayName = _displayName;
    return displayName.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = imgPath?.trim();
    final hasImage = imagePath != null && imagePath.isNotEmpty;

    return UserAccountsDrawerHeader(
      accountName: Text(_displayName),
      accountEmail: Text(_displayEmail),
      currentAccountPicture: CircleAvatar(
        backgroundImage: hasImage ? AssetImage(imagePath) : null,
        onBackgroundImageError: hasImage ? (_, _) {} : null,
        child: hasImage ? null : Text(_initial),
      ),
    );
  }
}
