// Wizard State
class WizardState {
  final int currentStep;
  final Map<int, dynamic> stepData;
  final bool isCompleted;

  WizardState({
    this.currentStep = 0,
    this.stepData = const {},
    this.isCompleted = false,
  });

  WizardState copyWith({
    int? currentStep,
    Map<int, dynamic>? stepData,
    bool? isCompleted,
  }) {
    return WizardState(
      currentStep: currentStep ?? this.currentStep,
      stepData: stepData ?? this.stepData,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
