// Context for variables and their types
class CELContext {
  final Map<String, Type> variables;
  final List<String> availableFunctions;

  CELContext({Map<String, Type>? variables, List<String>? availableFunctions})
    : variables = variables ?? {},
      availableFunctions = availableFunctions ?? [];
}
