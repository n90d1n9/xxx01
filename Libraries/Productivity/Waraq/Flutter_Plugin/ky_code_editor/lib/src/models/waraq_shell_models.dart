import 'package:flutter/material.dart';

/// Stable sidebar destination identifiers for Waraq editor surfaces.
enum WaraqShellDestination {
  /// The live editor surface.
  editor,

  /// Host-facing artifact API discovery and result-envelope surface.
  artifactApi,

  /// Shared artifact readiness and lifecycle checks.
  readiness,

  /// Shared Waraq artifact contract summary.
  contract,
}

/// Presentation metadata for one Waraq shell destination.
@immutable
class WaraqDestinationSpec {
  /// Creates a stable destination description for sidebar and routing UI.
  const WaraqDestinationSpec({
    required this.destination,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.infoScreen,
  });

  /// Stable destination id.
  final WaraqShellDestination destination;

  /// Human-readable destination label.
  final String label;

  /// Icon shown when the destination is not selected.
  final IconData icon;

  /// Icon shown when the destination is selected.
  final IconData selectedIcon;

  /// Optional static information screen rendered for non-editor panes.
  final WaraqInfoScreenSpec? infoScreen;
}

/// Immutable content model rendered by a Waraq information screen.
@immutable
class WaraqInfoScreenSpec {
  /// Creates content for a compact label/value information screen.
  const WaraqInfoScreenSpec({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  /// Leading icon for the information screen header.
  final IconData icon;

  /// App bar title.
  final String title;

  /// Header subtitle shown above the detail rows.
  final String subtitle;

  /// Stable label/value rows for this information screen.
  final List<WaraqInfoItem> items;
}

/// Immutable label/value row rendered on a Waraq information screen.
@immutable
class WaraqInfoItem {
  /// Creates one compact information row.
  const WaraqInfoItem({
    required this.label,
    required this.value,
    required this.accent,
  });

  /// Short row label.
  final String label;

  /// Row value, usually a stable API name or count.
  final String value;

  /// Accent color used on the row edge.
  final Color accent;
}

/// Default sidebar destinations for the Waraq editor package shell.
const List<WaraqDestinationSpec> defaultWaraqDestinations = [
  WaraqDestinationSpec(
    destination: WaraqShellDestination.editor,
    label: 'Editor',
    icon: Icons.code_outlined,
    selectedIcon: Icons.code,
  ),
  WaraqDestinationSpec(
    destination: WaraqShellDestination.artifactApi,
    label: 'Artifact API',
    icon: Icons.api_outlined,
    selectedIcon: Icons.api,
    infoScreen: defaultWaraqArtifactApiInfo,
  ),
  WaraqDestinationSpec(
    destination: WaraqShellDestination.readiness,
    label: 'Readiness',
    icon: Icons.fact_check_outlined,
    selectedIcon: Icons.fact_check,
    infoScreen: defaultWaraqReadinessInfo,
  ),
  WaraqDestinationSpec(
    destination: WaraqShellDestination.contract,
    label: 'Contract',
    icon: Icons.description_outlined,
    selectedIcon: Icons.description,
    infoScreen: defaultWaraqContractInfo,
  ),
];

/// Default host-facing artifact API summary for the Waraq shell.
const defaultWaraqArtifactApiInfo = WaraqInfoScreenSpec(
  icon: Icons.api,
  title: 'Artifact API',
  subtitle: 'waraq.editor / API v25',
  items: [
    WaraqInfoItem(
      label: 'Result envelope',
      value: 'ok_value_error',
      accent: Color(0xFF8BE9FD),
    ),
    WaraqInfoItem(
      label: 'Restore preflight',
      value: 'editor_artifact_restore_preflight_result_json',
      accent: Color(0xFF50FA7B),
    ),
    WaraqInfoItem(
      label: 'Legacy restore',
      value: 'EditorHandle* after preflight',
      accent: Color(0xFFF1FA8C),
    ),
  ],
);

/// Default shared artifact readiness summary for the Waraq shell.
const defaultWaraqReadinessInfo = WaraqInfoScreenSpec(
  icon: Icons.fact_check,
  title: 'Readiness',
  subtitle: 'Shared artifact lifecycle checks',
  items: [
    WaraqInfoItem(
      label: 'Conformance',
      value: '10 checks',
      accent: Color(0xFF50FA7B),
    ),
    WaraqInfoItem(
      label: 'Replay harness',
      value: '4 checks',
      accent: Color(0xFF8BE9FD),
    ),
    WaraqInfoItem(
      label: 'Compaction harness',
      value: '8 checks',
      accent: Color(0xFFFFB86C),
    ),
    WaraqInfoItem(
      label: 'Lifecycle total',
      value: '22 checks',
      accent: Color(0xFFBD93F9),
    ),
  ],
);

/// Default shared contract summary for Waraq-family engine authors.
const defaultWaraqContractInfo = WaraqInfoScreenSpec(
  icon: Icons.description,
  title: 'Contract',
  subtitle: 'Shared core + specialized engines',
  items: [
    WaraqInfoItem(
      label: 'Operation',
      value: 'OperationEnvelope<Edit>',
      accent: Color(0xFF8BE9FD),
    ),
    WaraqInfoItem(
      label: 'Operation log',
      value: 'OperationLog<Edit>',
      accent: Color(0xFF50FA7B),
    ),
    WaraqInfoItem(
      label: 'Artifact',
      value: 'OperationArtifact<Snapshot, Edit>',
      accent: Color(0xFFF1FA8C),
    ),
  ],
);
