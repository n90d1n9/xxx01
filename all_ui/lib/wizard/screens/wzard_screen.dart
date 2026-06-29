// Example Usage
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wizard_step.dart';
import '../widgets/multipurpuse_wizard.dart';

class ExampleWizardScreen extends ConsumerWidget {
  const ExampleWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = [
      WizardStep(
        title: 'Welcome',
        subtitle: 'Let\'s get started with the setup',
        content: const Center(child: Text('Welcome to the wizard!')),
      ),
      WizardStep(
        title: 'Enter Information',
        subtitle: 'Please provide your details',
        content: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        canProceed: () => true, // Add validation logic
      ),
      WizardStep(
        title: 'Confirmation',
        subtitle: 'Review your information',
        content: const Center(child: Text('Please confirm your details')),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Multipurpose Wizard')),
      body: MultipurposeWizard(
        steps: steps,
        onComplete: () {
          // Handle completion
          Navigator.pop(context);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
