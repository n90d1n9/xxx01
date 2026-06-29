// Wizard Controller
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wizard_state.dart';
import '../models/wizard_step.dart';

class WizardController extends StateNotifier<WizardState> {
  final List<WizardStep> steps;

  WizardController(this.steps) : super(WizardState());

  void nextStep() {
    if (state.currentStep < steps.length - 1) {
      steps[state.currentStep].onStepExit?.call();
      state = state.copyWith(currentStep: state.currentStep + 1);
      steps[state.currentStep].onStepEnter?.call();
    } else {
      state = state.copyWith(isCompleted: true);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      steps[state.currentStep].onStepExit?.call();
      state = state.copyWith(currentStep: state.currentStep - 1);
      steps[state.currentStep].onStepEnter?.call();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < steps.length) {
      steps[state.currentStep].onStepExit?.call();
      state = state.copyWith(currentStep: step);
      steps[state.currentStep].onStepEnter?.call();
    }
  }

  void saveStepData(int step, dynamic data) {
    final newData = Map<int, dynamic>.from(state.stepData);
    newData[step] = data;
    state = state.copyWith(stepData: newData);
  }

  T? getStepData<T>(int step) {
    return state.stepData[step] as T?;
  }

  void reset() {
    state = WizardState();
    steps[0].onStepEnter?.call();
  }

  bool canProceed() {
    final step = steps[state.currentStep];
    return step.canProceed?.call() ?? true;
  }
}

// Provider
/* final wizardControllerProvider = StateNotifierProvider.family
    WizardController, WizardState, List<w.WizardStep>>(
  (ref, steps) => WizardController(steps),
);
 */
