import '../model/field_config.dart';
import '../states/form_field_provider.dart';
import 'form_command.dart';

class DeleteFieldCommand extends FormCommand {
  final FormFieldsNotifier notifier;
  final FieldConfig field;
  final int index;

  DeleteFieldCommand(this.notifier, this.field, this.index);

  @override
  void execute() => notifier.deleteFieldDirect(field.id);

  @override
  void undo() => notifier.insertFieldDirect(field, index);

  @override
  String get description => 'Delete ${field.type}';
}
