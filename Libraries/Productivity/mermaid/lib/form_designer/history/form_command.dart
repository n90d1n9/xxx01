abstract class FormCommand {
  void execute();
  void undo();
  String get description;
}
