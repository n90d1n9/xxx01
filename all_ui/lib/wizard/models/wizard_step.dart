// Wizard Step Model
import 'package:flutter/material.dart';

class WizardStep {
  final String title;
  final String? subtitle;
  final Widget content;
  final bool Function()? canProceed;
  final VoidCallback? onStepEnter;
  final VoidCallback? onStepExit;

  WizardStep({
    required this.title,
    this.subtitle,
    required this.content,
    this.canProceed,
    this.onStepEnter,
    this.onStepExit,
  });
}
