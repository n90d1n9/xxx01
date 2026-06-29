import '../models/faraid_model.dart';
import 'hanafi_calculator.dart';

class HanbaliCalculator extends SunniHanafiCalculator {
  @override
  FaraidResult calculate(InheritanceCase inheritanceCase) {
    final result = super.calculate(inheritanceCase);
    return result.copyWith(
      calculationSteps: [
        'Hanbali calculation - using Hanafi base with adjustments',
        ...result.calculationSteps,
      ],
    );
  }
}
