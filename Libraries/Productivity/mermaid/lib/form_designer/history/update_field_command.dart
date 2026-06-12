import '../model/field_config.dart';
import '../states/form_field_provider.dart';
import 'form_command.dart';

class UpdateFieldCommand extends FormCommand {
  final FormFieldsNotifier notifier;
  final FieldConfig oldField;
  final FieldConfig newField;

  UpdateFieldCommand(this.notifier, this.oldField, this.newField);

  @override
  void execute() => notifier.updateFieldDirect(newField.id, newField);

  @override
  void undo() => notifier.updateFieldDirect(oldField.id, oldField);

  @override
  String get description => 'Update ${newField.type}';
}
