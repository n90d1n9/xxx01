// Models for Example
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Complete Example Usage
class ExampleWizardScreen extends ConsumerWidget {
  const ExampleWizardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    final steps = [
      WizardStep(
        title: 'Personal Information',
        subtitle: 'Tell us about yourself',
        content: UserProfileForm(onDataChanged: () {}),
        canProceed: () => userProfile != null,
      ),
      WizardStep(
        title: 'Your Skills',
        subtitle: 'Add and manage your skills',
        content: const SkillsListForm(),
      ),
      WizardStep(
        title: 'Preferences',
        subtitle: 'Customize your experience',
        content: const PreferencesForm(),
      ),
      WizardStep(
        title: 'Review & Confirm',
        subtitle: 'Please review your information',
        content: const ReviewConfirmation(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Setup Wizard'), elevation: 0),
      body: MultipurposeWizard(
        steps: steps,
        onComplete: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Setup completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
