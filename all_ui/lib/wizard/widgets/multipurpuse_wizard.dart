// Multipurpose Wizard Widget
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wizard_step.dart';
import '../states/wizard_provider.dart';

class MultipurposeWizard extends ConsumerWidget {
  final List<WizardStep> steps;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;
  final bool showStepIndicator;
  final bool allowStepNavigation;
  final Color? primaryColor;
  final String? completeButtonText;
  final String? nextButtonText;
  final String? previousButtonText;
  final String? cancelButtonText;

  const MultipurposeWizard({
    super.key,
    required this.steps,
    this.onComplete,
    this.onCancel,
    this.showStepIndicator = true,
    this.allowStepNavigation = true,
    this.primaryColor,
    this.completeButtonText,
    this.nextButtonText,
    this.previousButtonText,
    this.cancelButtonText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizardState = ref.watch(wizardControllerProvider(steps));
    final controller = ref.read(wizardControllerProvider(steps).notifier);
    final theme = Theme.of(context);
    final effectivePrimaryColor = primaryColor ?? theme.primaryColor;

    if (wizardState.isCompleted) {
      return _CompletionScreen(
        onComplete: onComplete,
        primaryColor: effectivePrimaryColor,
      );
    }

    final currentStep = steps[wizardState.currentStep];
    final isFirstStep = wizardState.currentStep == 0;
    final isLastStep = wizardState.currentStep == steps.length - 1;

    return Column(
      children: [
        if (showStepIndicator)
          _StepIndicator(
            steps: steps,
            currentStep: wizardState.currentStep,
            primaryColor: effectivePrimaryColor,
            onStepTap:
                allowStepNavigation
                    ? (step) => controller.goToStep(step)
                    : null,
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentStep.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (currentStep.subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    currentStep.subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                currentStep.content,
              ],
            ),
          ),
        ),
        _NavigationButtons(
          isFirstStep: isFirstStep,
          isLastStep: isLastStep,
          canProceed: controller.canProceed(),
          onNext: controller.nextStep,
          onPrevious: controller.previousStep,
          onCancel: onCancel,
          primaryColor: effectivePrimaryColor,
          completeButtonText: completeButtonText,
          nextButtonText: nextButtonText,
          previousButtonText: previousButtonText,
          cancelButtonText: cancelButtonText,
        ),
      ],
    );
  }
}

// Step Indicator Widget
class _StepIndicator extends StatelessWidget {
  final List<WizardStep> steps;
  final int currentStep;
  final Color primaryColor;
  final void Function(int)? onStepTap;

  const _StepIndicator({
    required this.steps,
    required this.currentStep,
    required this.primaryColor,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                color:
                    index ~/ 2 < currentStep ? primaryColor : Colors.grey[300],
              ),
            );
          }
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentStep;
          final isCurrent = stepIndex == currentStep;

          return GestureDetector(
            onTap: onStepTap != null ? () => onStepTap!(stepIndex) : null,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isCompleted || isCurrent ? primaryColor : Colors.grey[300],
                border:
                    isCurrent
                        ? Border.all(color: primaryColor, width: 3)
                        : null,
              ),
              child: Center(
                child:
                    isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Navigation Buttons Widget
class _NavigationButtons extends StatelessWidget {
  final bool isFirstStep;
  final bool isLastStep;
  final bool canProceed;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback? onCancel;
  final Color primaryColor;
  final String? completeButtonText;
  final String? nextButtonText;
  final String? previousButtonText;
  final String? cancelButtonText;

  const _NavigationButtons({
    required this.isFirstStep,
    required this.isLastStep,
    required this.canProceed,
    required this.onNext,
    required this.onPrevious,
    this.onCancel,
    required this.primaryColor,
    this.completeButtonText,
    this.nextButtonText,
    this.previousButtonText,
    this.cancelButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (onCancel != null)
            TextButton(
              onPressed: onCancel,
              child: Text(cancelButtonText ?? 'Cancel'),
            ),
          const Spacer(),
          if (!isFirstStep)
            OutlinedButton(
              onPressed: onPrevious,
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor),
              ),
              child: Text(previousButtonText ?? 'Previous'),
            ),
          if (!isFirstStep) const SizedBox(width: 12),
          ElevatedButton(
            onPressed: canProceed ? onNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: Text(
              isLastStep
                  ? (completeButtonText ?? 'Complete')
                  : (nextButtonText ?? 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}

// Completion Screen
class _CompletionScreen extends StatelessWidget {
  final VoidCallback? onComplete;
  final Color primaryColor;

  const _CompletionScreen({this.onComplete, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withOpacity(0.1),
            ),
            child: Icon(Icons.check_circle, size: 60, color: primaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            'Completed!',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'You have successfully completed all steps',
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (onComplete != null) ...[
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Finish'),
            ),
          ],
        ],
      ),
    );
  }
}
