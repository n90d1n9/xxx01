/// Base class for all filter primitives
abstract class FilterPrimitive {
  final String? input;
  final String? result;

  FilterPrimitive({this.input, this.result});

  @override
  String toString() => '$runtimeType(in: $input, result: $result)';
}
