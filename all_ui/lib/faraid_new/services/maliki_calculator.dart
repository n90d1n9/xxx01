// calculators/maliki_calculator.dart
import '../models/faraid_model.dart';
import 'hanafi_calculator.dart';

class MalikiCalculator extends SunniHanafiCalculator {
  @override
  FaraidResult calculate(InheritanceCase inheritanceCase) {
    // Maliki school specific logic can be added here
    final result = super.calculate(inheritanceCase);
    return result.copyWith(
      calculationSteps: [
        'Maliki calculation - using Hanafi base with adjustments',
        ...result.calculationSteps
      ],
    );
  }
}
