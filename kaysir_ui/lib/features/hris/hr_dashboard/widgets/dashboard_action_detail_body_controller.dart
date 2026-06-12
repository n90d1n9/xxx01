import 'package:flutter/foundation.dart';

enum DashboardActionDetailBodyCommand {
  returnToOverview,
  goToPreviousSection,
  goToNextSection,
}

class DashboardActionDetailBodyController extends ChangeNotifier {
  DashboardActionDetailBodyCommand? _command;

  DashboardActionDetailBodyCommand? get command => _command;

  void returnToOverview() {
    _dispatch(DashboardActionDetailBodyCommand.returnToOverview);
  }

  void goToPreviousSection() {
    _dispatch(DashboardActionDetailBodyCommand.goToPreviousSection);
  }

  void goToNextSection() {
    _dispatch(DashboardActionDetailBodyCommand.goToNextSection);
  }

  void _dispatch(DashboardActionDetailBodyCommand command) {
    _command = command;
    notifyListeners();
  }
}
