import '../states/form_field_provider.dart';
import 'form_command.dart';

class ReorderFieldCommand extends FormCommand {
  final FormFieldsNotifier notifier;
  final int oldIndex;
  final int newIndex;

  ReorderFieldCommand(this.notifier, this.oldIndex, this.newIndex);

  @override
  void execute() => notifier.reorderFieldDirect(oldIndex, newIndex);

  @override
  void undo() => notifier.reorderFieldDirect(newIndex, oldIndex);

  @override
  String get description => 'Reorder field';
}
