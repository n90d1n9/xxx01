import 'package:flutter/material.dart';

import 'release_profile_contract.dart';

/// Visual treatment for a release workspace profile contract status.
class BillingReleaseWorkspaceProfileContractStatusVisuals {
  final IconData icon;
  final Color color;

  const BillingReleaseWorkspaceProfileContractStatusVisuals({
    required this.icon,
    required this.color,
  });

  factory BillingReleaseWorkspaceProfileContractStatusVisuals.fromStatus(
    BillingReleaseWorkspaceProfileContractStatus status,
  ) {
    return switch (status) {
      BillingReleaseWorkspaceProfileContractStatus.standard =>
        const BillingReleaseWorkspaceProfileContractStatusVisuals(
          icon: Icons.verified_outlined,
          color: Color(0xFF059669),
        ),
      BillingReleaseWorkspaceProfileContractStatus.extended =>
        const BillingReleaseWorkspaceProfileContractStatusVisuals(
          icon: Icons.extension_outlined,
          color: Color(0xFF7C3AED),
        ),
      BillingReleaseWorkspaceProfileContractStatus.constrained =>
        const BillingReleaseWorkspaceProfileContractStatusVisuals(
          icon: Icons.visibility_off_outlined,
          color: Color(0xFFD97706),
        ),
      BillingReleaseWorkspaceProfileContractStatus.tailored =>
        const BillingReleaseWorkspaceProfileContractStatusVisuals(
          icon: Icons.tune_outlined,
          color: Color(0xFF2563EB),
        ),
    };
  }
}
