import 'package:flutter/material.dart';

import '../models/admin_account_identity.dart';

class AccountAvatar extends StatelessWidget {
  const AccountAvatar({super.key, required this.identity, this.radius = 18});

  final AdminAccountIdentity identity;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      backgroundImage:
          identity.imageUrl == null ? null : NetworkImage(identity.imageUrl!),
      child:
          identity.imageUrl == null
              ? Text(
                identity.initials,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w900,
                ),
              )
              : null,
    );
  }
}
