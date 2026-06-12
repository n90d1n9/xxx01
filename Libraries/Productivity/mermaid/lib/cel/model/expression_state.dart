import 'cel_context.dart';
import 'expression_node.dart';
import 'expression_template.dart';
import 'history_entry.dart';
import 'validation_result.dart';

class ExpressionState {
  final ExpressionNode? rootNode;
  final String script;
  final bool isVisualMode;
  final CELContext context;
  final CELValidationResult? validationResult;
  final List<HistoryEntry> undoStack;
  final List<HistoryEntry> redoStack;
  final String? selectedNodeId;
  final List<ExpressionTemplate> templates;

  ExpressionState({
    this.rootNode,
    this.script = '',
    this.isVisualMode = true,
    CELContext? context,
    this.validationResult,
    List<HistoryEntry>? undoStack,
    List<HistoryEntry>? redoStack,
    this.selectedNodeId,
    List<ExpressionTemplate>? templates,
  }) : context = context ?? CELContext(),
       undoStack = undoStack ?? [],
       redoStack = redoStack ?? [],
       templates = templates ?? [];

  ExpressionState copyWith({
    ExpressionNode? rootNode,
    String? script,
    bool? isVisualMode,
    CELContext? context,
    CELValidationResult? validationResult,
    List<HistoryEntry>? undoStack,
    List<HistoryEntry>? redoStack,
    String? selectedNodeId,
    List<ExpressionTemplate>? templates,
  }) {
    return ExpressionState(
      rootNode: rootNode ?? this.rootNode,
      script: script ?? this.script,
      isVisualMode: isVisualMode ?? this.isVisualMode,
      context: context ?? this.context,
      validationResult: validationResult ?? this.validationResult,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      selectedNodeId: selectedNodeId,
      templates: templates ?? this.templates,
    );
  }
}
