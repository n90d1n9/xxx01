import '../model/field_config.dart';
import '../states/form_field_provider.dart';
import 'form_command.dart';

class AddFieldCommand extends FormCommand {
  final FormFieldsNotifier notifier;
  final FieldConfig field;
  final String? parentId;

  AddFieldCommand(this.notifier, this.field, {this.parentId});

  @override
  void execute() => notifier.addFieldDirect(field, parentId: parentId);

  @override
  void undo() => notifier.deleteFieldDirect(field.id);

  @override
  String get description => 'Add ${field.type}';
}
