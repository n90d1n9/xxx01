import 'package:flutter/material.dart';

import '../models/registry_diagnostics.dart';

IconData registryIssueSourceIcon(RegistryIssueSource source) {
  return switch (source) {
    RegistryIssueSource.profile => Icons.view_quilt_outlined,
    RegistryIssueSource.module => Icons.extension_outlined,
    RegistryIssueSource.action => Icons.bolt_outlined,
  };
}
